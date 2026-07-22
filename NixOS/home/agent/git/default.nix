{ pkgs, ... }:
{
  programs.git = {
    package = pkgs.git.override { withLibsecret = true; };
    settings = {
      user.name = "KeishiS";
      user.email = "sando.keishi@sp@alumni.tsukuba.ac.jp";
      core = {
        editor = "vim";
        quotepath = false;
      };
      commit.gpgsign = true;
      github.user = "KeishiS";
      init.defaultBranch = "main";
      push.default = "simple";
      pull.rebase = true;
      credential.helper = "libsecret";
    };
  };

  programs.diff-so-fancy = {
    enable = true;
    enableGitIntegration = true;
    settings.stripLeadingSymbols = false;
  };
}
