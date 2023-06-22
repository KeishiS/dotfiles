#!/usr/bin/env perl

# LaTeX commands
$lualatex       =   'lualatex -shell-escape -synctex=1 -interection=nonstopmode';
$pdflualatex    =   $lualatex;

# bibTeX commands
$biber      = 'biber %O --bblencoding=utf8 -u -U --output_safechars %B';

$makeindex  =   'mendex %O -o %D %S';

# Typeset mode (generate a PDF)
$pdf_mode = 4;

# Other configuration
$pvc_view_file_via_temporary = 0;
$max_repeat                  = 5;
$clean_ext = "run.xml synctex.gz dvi nav snm bbl"
