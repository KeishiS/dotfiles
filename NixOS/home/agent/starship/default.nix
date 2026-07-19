{ ... }:
{
  programs.starship = {
    enable = true;

    settings.env_var.AGENT_SANDBOX = {
      variable = "AGENT_SANDBOX";
      format = "[\\[sandbox\\]]($style) ";
      style = "bold yellow";
    };
  };
}
