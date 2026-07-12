{ ... }:
{
  programs.vim = {
    enable = true;
    defaultEditor = true;
    extraConfig = ''
      " 自分用マッピングの名前空間（修飾キーゼロで拡張できる一等地）
      let mapleader=" "

      set number hidden
      set ignorecase smartcase incsearch hlsearch
      set expandtab shiftwidth=4 tabstop=4
      if has('clipboard')
        set clipboard=unnamedplus
      endif
      syntax on
      filetype plugin indent on
    '';
  };
}
