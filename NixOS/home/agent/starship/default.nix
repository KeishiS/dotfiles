{ ... }:
{
  programs.starship = {
    enable = true;

    settings.env_var.AGENT_SANDBOX = {
      variable = "AGENT_SANDBOX";
      symbol = "[sandbox]";
      format = "[$symbol]($style) ";
      style = "bold yellow";
    };
  };
}
