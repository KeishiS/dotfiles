#!/usr/bin/env perl

$out_dir = 'build/';

# LaTeX commands
## -shell-escape : 処理系による外部コマンド実行を許可
## -synctex=-1 :
##      synctexはtexソースを開いたエディタとPDF viewerとの相互ジャンプを実現する仕組み
##      値が1の時，zlibで圧縮したsynctex用データを出力
##      値が-1の時，圧縮しないデータを出力
## -interection=nonstopmode :
##      エラーに直面したときの動作を決める
##      nonstopmodeはエラーメッセージを表示せず無視して処理を続ける
##      scrollmodeは止まることなく処理するが，エラーは表示される
$lualatex = 'lualatex -shell-escape -synctex=1';
$pdflatex = $lualatex;

# bibTeX commands
## %O : 出力ディレクトリが入るプレースホルダで
##      $out_dirで指定されている場合，その値に置き換えられる
## %S : 現在のソースファイル名が入るプレースホルダ
## %B : 現在のソースファイル名から拡張子を除いた値が入るプレースホルダ
## --bblencoding=utf8 :
##      参考文献リストファイルであるbblのエンコーディングを指定
## -u : 入力ファイルのエンコーディングがutf8
## -U : 出力ファイルのエンコーディングをutf8に指定
## --output_safechars :
##      出力の特定のunicode文字をlatexマクロに置き換えることで
##      unicodeをサポートしていないlatexエンジンへの影響を回避
$biber = 'biber %O %S --bblencoding=utf8 -u -U --output_safechars %B';
## %D : 出力ファイル名が入るプレースホルダ
$makeindex  =   'mendex %O -o %D %S';

# Typeset mode (generate a PDF)
## pdf_mode = 0 : $latexを実行し，pdfは生成されない
## pdf_mode = 1 : $pdflatexを実行し，pdfを生成
## pdf_mode = 2 :
##      $latexを実行後，$dvipsでPSファイルを生成し
##      ps2pdfコマンドでpdfに変換
## pdf_mode = 3 : $latex実行後，$dvipdfコマンドでpdfに変換
## pdf_mode = 4 : $lualatexを実行しpdfを生成
## pdf_mode = 5 : $xelatexを実行後，$xdvipdfmxでpdfに変換
$pdf_mode = 4;

# Other configuration
## pvc_view_file_via_temporary :
##      値が1の時，pdfの閲覧でファイル更新が阻害されないよう
##      一時ファイルを作成する
$pvc_view_file_via_temporary = 1;
$max_repeat = 5;
$clean_ext = "run.xml synctex.gz dvi nav snm bbl";
$ENV{TZ} = 'Asia/Tokyo';
$ENV{OPENTYPEFONTS} = '/usr/share/fonts//:';
$ENV{TTFONTS} = '/usr/share/fonts//:';
