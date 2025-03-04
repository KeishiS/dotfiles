{ ... }:
let
  theme = (import ../theme);
in
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 32;
        spacing = 10;

        modules-left = [
          "sway/workspaces"
          "sway/mode"
        ];
        modules-center = [ "sway/window" ];
        modules-right = [
          "battery"
          "memory"
          "cpu"
          "network"
          "clock"
          "tray"
        ];

        "sway/window" = {
          max-length = 60;
          tooltip = false;
        };
        memory = {
          format = "MEM {used:0.1f}G/{total:0.1f}G";
          tooltip = false;
        };
        cpu = {
          format = "CPU {usage}%";
          tooltip = false;
        };
        network = {
          format-wifi = "{essid} ({signalStrength}%)";
          format-ethernet = "{ifname} ({ipaddr})";
          format-disconnected = "Disconnected";
          tooltip = false;
        };
        clock = {
          timezone = "Asia/Tokyo";
          format = "{:%Y-%m-%d %H:%M:%S}";
          interval = 1;
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };
        tray = {
          spacing = 6;
        };
      };
    };

    style = ''
      * {
        font-family: "${theme.console-font}";
        font-size: 1rem;
        border: none;
      }

      window#waybar {
        background: ${theme.bg};
        color: ${theme.fg};
      }

      #battery {
        border: 1px solid ${theme.yellow};
        padding: 0 0.5rem;
        margin: 0.3rem 0;
      }

      #memory {
        border: 1px solid ${theme.blue};
        padding: 0 0.5rem;
        margin: 0.3rem 0;
      }

      #cpu {
        border: 1px solid ${theme.cyan};
        padding: 0 0.5rem;
        margin: 0.3rem 0;
      }

      #network {
        border: 1px solid ${theme.red};
        padding: 0 0.5rem;
        margin: 0.3rem 0;
      }

      #clock {
        border: 1px solid ${theme.green};
        padding: 0 0.5rem;
        margin: 0.3rem 0;
      }
    '';
  };
}
