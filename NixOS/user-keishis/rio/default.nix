{ ... }:
{
  programs.rio = {
    enable = true;
    settings = {
      confirmbefore-quit = false;
      cursor.shape = "beam";
      editor.program = "hx";
    };
  };
}
