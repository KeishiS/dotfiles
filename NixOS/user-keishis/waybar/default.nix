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
        height = 34;
        spacing = 5;

        modules-left = [
          "clock"
          "sway/workspaces"
          "hyprland/workspaces"
          "sway/mode"
        ];
        modules-center = [
          "sway/window"
          "hyprland/window"
        ];
        modules-right = [
          "battery"
          "memory"
          "cpu"
          "network"
          "tray"
        ];

        "sway/window" = {
          max-length = 60;
          tooltip = false;
        };
        battery = {
          states = {
            warning = 30;
            critial = 15;
          };
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
        background: none;
        color: ${theme.fg};
      }

      .modules-left, .modules-right, #window {
        background: ${theme.bg-080};
        margin: 0.2rem 1rem;
        padding: 0 1rem;
        border-radius: 1rem;
      }

      #workspaces {
        background: none;
      }

      #workspaces button {
        border: 1px solid ${theme.border};
        padding: 0 0.3rem;
        background: none;
        margin: 0.3rem 0.1rem;
      }

      #workspaces button:hover {
        background: ${theme.fg};
        color: ${theme.bg};
      }

      #workspaces button.focused {
        background: ${theme.primary};
        color: ${theme.bg};
      }

      #workspaces button.urgent {
        background: ${theme.urgent};
        color: ${theme.bg};
      }

      #battery {
        border: 1px solid ${theme.yellow};
        border-radius: 0.5rem;
        padding: 0 0.5rem;
        margin: 0.3rem 0;
      }

      #battery.warning {
        background: ${theme.yellow};
        color: ${theme.bg};
      }

      #battery.critial {
        border: 1px solid ${theme.red};
        background: ${theme.red};
        color: ${theme.bg};
      }

      #memory {
        border: 1px solid ${theme.blue};
        border-radius: 0.5rem;
        padding: 0 0.5rem;
        margin: 0.3rem 0;
      }

      #cpu {
        border: 1px solid ${theme.cyan};
        border-radius: 0.5rem;
        padding: 0 0.5rem;
        margin: 0.3rem 0;
      }

      #network {
        border: 1px solid ${theme.red};
        border-radius: 0.5rem;
        padding: 0 0.5rem;
        margin: 0.3rem 0;
      }

      #clock {
        border: 1px solid ${theme.green};
        border-radius: 0.5rem;
        padding: 0 0.5rem;
        margin: 0.3rem 0;
      }

      #tray {
        border: 1px solid ${theme.magenta};
        border-radius: 0.5rem;
        padding: 0 0.5rem;
        margin: 0.3rem 0;
      }
    '';
  };
}
