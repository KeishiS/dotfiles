{ ... }:
{
  programs.helix = {
    enable = true;
    settings = {
      theme = "tokyonight";
      editor = {
        auto-format = true;
        insert-final-newline = true;
        cursorline = true;
        color-modes = true;
      };

      editor.cursor-shape = {
        insert = "bar";
        normal = "block";
        select = "underline";
      };

      editor.soft-wrap = {
        enable = true;
      };

      keys.insert = {
        C-p = "move_line_up";
        C-n = "move_line_down";
        C-e = "goto_line_end_newline";
        C-a = "goto_line_start";
        C-f = "move_char_right";
        C-b = "move_char_left";
      };
    };
  };
}
