#!/usr/bin/env bash
set -euo pipefail

# 実際のホームとGC rootを変更せず、隔離したホームで適用処理を検証します。
script="$(realpath "$(dirname "$0")/../agent-home-switch")"
for command in bwrap flock realpath; do
    command -v "$command" >/dev/null || { echo "$command が必要です。" >&2; exit 1; }
done
bwrap --ro-bind / / -- true || { echo 'この環境ではbwrapを起動できません。' >&2; exit 1; }
test_root="$(mktemp -d)"
cleanup() {
    status=$?
    if [[ $status != 0 && -n ${case_dir:-} ]]; then
        for output in "$case_dir/"*output; do
            [[ ! -f $output ]] || cat "$output" >&2
        done
    fi
    rm -rf -- "$test_root"
}
trap cleanup EXIT
expected_home="/sandbox/by-uid/$(id -u)"
store_target="$(realpath "$(command -v bash)")"
[[ $store_target == /nix/store/* ]] || { echo 'Nix Store内のbashが必要です。' >&2; exit 1; }
store_target="${store_target%/bin/bash}"
# 実ホーム経由のPATHが、テスト用ホームへの置き換えで消えないようにします。
test_path=""
IFS=: read -ra path_entries <<<"$PATH"
for entry in "${path_entries[@]}"; do
    [[ ! -d $entry ]] || test_path+="$(realpath "$entry"):"
done
mkdir -p "$test_root/bin" "$test_root/flake"
touch "$test_root/flake/flake.nix"
cat >"$test_root/bin/home-manager" <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >>"$TEST_CASE/home-manager.log"
[[ ${HM_FAIL:-0} == 0 ]] || exit "$HM_FAIL"
if ! mkdir "$TEST_CASE/active"; then
    touch "$TEST_CASE/overlap"
    exit 90
fi
trap 'rmdir "$TEST_CASE/active"' EXIT
sleep 0.1
profiles="$XDG_STATE_HOME/nix/profiles"
mkdir -p "$profiles"
ln -sfnT "$STORE_TARGET" "$profiles/profile-10-link"
ln -sfnT profile-10-link "$profiles/profile"
ln -sfnT "$profiles/profile" "$HOME/.nix-profile"
MOCK
cat >"$test_root/bin/nix-store" <<'MOCK'
#!/usr/bin/env bash
set -euo pipefail
[[ $# == 5 && $1 == --realise && $2 == "$STORE_TARGET" && $3 == --add-root && $5 == --indirect ]]
[[ $4 == "$HOME/.local/state/nix/profiles/"* ]]
printf '%s\n' "$4" >>"$TEST_CASE/roots.log"
MOCK
chmod +x "$test_root/bin/"*

fail() { printf '失敗しました: %s\n' "$*" >&2; exit 1; }
new_case() {
    case_dir="$test_root/$1"
    mkdir -p "$case_dir/home"
    chmod 700 "$case_dir/home"
    profiles="$case_dir/home/.local/state/nix/profiles"
    mkdir -p "$profiles"
}
run_switch() {
    bwrap --ro-bind / / --dev /dev --bind "$test_root" "$test_root" \
        --bind "$case_dir/home" "$expected_home" \
        --setenv HOME "$expected_home" --setenv AGENT_SANDBOX 1 \
        --setenv TEST_CASE "$case_dir" --setenv STORE_TARGET "$store_target" \
        --setenv HM_FAIL "${HM_FAIL:-0}" --setenv PATH "$test_root/bin:${test_path%:}" \
        -- bash "$script" "$@" "$test_root/flake"
}
assert_count() {
    [[ $(wc -l <"$1") == "$2" ]] || fail "$1 の行数が $2 と異なります。"
}

new_case normal
run_switch >"$case_dir/output" 2>&1
[[ $(readlink "$case_dir/home/.nix-profile") == "$expected_home/.local/state/nix/profiles/profile" ]] || fail '通常適用後のリンク先が不正です。'
assert_count "$case_dir/roots.log" 1
[[ $(cat "$case_dir/home-manager.log") == "switch --impure --flake path:$test_root/flake#sandbox" ]] || fail 'Home Managerの引数が不正です。'

new_case legacy
ln -s /home/agent/.local/state/nix/profiles/profile "$case_dir/home/.nix-profile"
if run_switch >"$case_dir/output" 2>&1; then fail '旧リンクを通常適用で受け入れました。'; fi
[[ ! -e $case_dir/home-manager.log && ! -e $case_dir/roots.log ]] || fail '旧リンク拒否前に外部コマンドを実行しました。'

new_case migration
ln -s /home/agent/.local/state/nix/profiles/profile "$case_dir/home/.nix-profile"
ln -s "$store_target" "$profiles/profile-1-link"
ln -s "$store_target" "$profiles/home-manager-2-link"
ln -s /nix/store/00000000000000000000000000000000-agent-test-missing "$profiles/profile-3-link"
ln -s /nix/store/00000000000000000000000000000000-agent-test-missing "$profiles/home-manager-3-link"
ln -s profile-3-link "$profiles/profile"
ln -s home-manager-3-link "$profiles/home-manager"
run_switch --migrate >"$case_dir/output" 2>&1
assert_count "$case_dir/roots.log" 3
for generation in profile-1-link home-manager-2-link profile-10-link; do
    registered=0
    while IFS= read -r root; do
        if [[ $root == "$expected_home/.local/state/nix/profiles/$generation" ]]; then registered=1; fi
    done <"$case_dir/roots.log"
    [[ $registered == 1 ]] || fail "$generation が登録されませんでした。"
done
[[ -L $profiles/profile-3-link ]] || fail '消失済み世代のリンクが削除されました。'
[[ -L $profiles/home-manager-3-link ]] || fail '消失済みHome Manager世代のリンクが削除されました。'
shopt -s nullglob
saved_profiles=("$case_dir/home/.local/state/"agent-home-migration.*/profile)
saved_hm=("$case_dir/home/.local/state/"agent-home-migration.*/home-manager)
[[ ${#saved_profiles[@]} == 1 && ${#saved_hm[@]} == 1 ]] || fail '消失済み現行リンクが退避されませんでした。'
[[ $(readlink "${saved_profiles[0]}") == profile-3-link && $(readlink "${saved_hm[0]}") == home-manager-3-link ]] || fail '退避先の現行リンクが不正です。'
backup="$case_dir/home/.local/state/agent-nix-profile-before-migration.txt"
[[ $(cat "$backup") == /home/agent/.local/state/nix/profiles/profile ]] || fail '旧リンクの記録が不正です。'
run_switch --migrate >>"$case_dir/output" 2>&1
assert_count "$case_dir/roots.log" 7
[[ $(cat "$backup") == /home/agent/.local/state/nix/profiles/profile ]] || fail '再移行で旧リンクの記録が変わりました。'
run_switch >>"$case_dir/output" 2>&1
assert_count "$case_dir/roots.log" 8

new_case concurrent
run_switch >"$case_dir/first.output" 2>&1 &
first_pid=$!
run_switch >"$case_dir/second.output" 2>&1 &
second_pid=$!
wait "$first_pid"
wait "$second_pid"
[[ ! -e $case_dir/overlap ]] || fail '適用処理が同時に実行されました。'
assert_count "$case_dir/home-manager.log" 2
assert_count "$case_dir/roots.log" 2

new_case failure
status=0
HM_FAIL=42 run_switch >"$case_dir/output" 2>&1 || status=$?
[[ $status == 42 ]] || fail 'Home Managerの終了コードが伝播しませんでした。'
[[ ! -e $case_dir/roots.log ]] || fail '適用失敗後にGC rootを登録しました。'
printf '通常適用、旧リンク拒否、移行、再実行、並列排他、適用失敗の検証に成功しました。\n'
