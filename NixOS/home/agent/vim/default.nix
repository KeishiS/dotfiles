{ ... }:
{
  programs.vim = {
    enable = true;
    defaultEditor = true;
    extraConfig = ''
      let mapleader=" "

      set number hidden
      set ignorecase smartcase incsearch hlsearch
      set expandtab shiftwidth=4 tabstop=4
      syntax on
      filetype plugin indent on
    '';
  };
}
