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
          "disk"
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
          format = "BAT {capacity}%";
          format-charging = "CHG {capacity}%";
          format-plugged = "FULL {capacity}%";
          states = {
            warning = 30;
            critial = 15;
          };
        };
        disk = {
          path = "/";
          format = "DISK {percentage_used}%";
          tooltip-format = "{used} / {total}";
        };
        memory = {
          format = "MEM {percentage}%";
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
        font-family: "${theme.font.console}";
        font-size: 1rem;
        border: none;
      }

      window#waybar {
        background: none;
        color: ${theme.foreground};
      }

      .modules-left, .modules-right, #window {
        background: ${theme.rgba.background-80};
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
        background: ${theme.foreground};
        color: ${theme.background};
      }

      #workspaces button.focused {
        background: ${theme.semantic.primary};
        color: ${theme.background};
      }

      #workspaces button.urgent {
        background: ${theme.semantic.urgent};
        color: ${theme.background};
      }

      #battery {
        border: 1px solid ${theme.palette.yellow};
        border-radius: 0.5rem;
        padding: 0 0.5rem;
        margin: 0.3rem 0;
      }

      #battery.warning {
        background: ${theme.semantic.warning};
        color: ${theme.background};
      }

      #battery.critial {
        border: 1px solid ${theme.semantic.error};
        background: ${theme.semantic.error};
        color: ${theme.background};
      }

      #disk {
        border: 1px solid ${theme.palette.magenta};
        border-radius: 0.5rem;
        padding: 0 0.5rem;
        margin: 0.3rem 0;
      }

      #memory {
        border: 1px solid ${theme.palette.blue};
        border-radius: 0.5rem;
        padding: 0 0.5rem;
        margin: 0.3rem 0;
      }

      #cpu {
        border: 1px solid ${theme.palette.cyan};
        border-radius: 0.5rem;
        padding: 0 0.5rem;
        margin: 0.3rem 0;
      }

      #network {
        border: 1px solid ${theme.palette.red};
        border-radius: 0.5rem;
        padding: 0 0.5rem;
        margin: 0.3rem 0;
      }

      #clock {
        border: 1px solid ${theme.palette.green};
        border-radius: 0.5rem;
        padding: 0 0.5rem;
        margin: 0.3rem 0;
      }

      #tray {
        border: 1px solid ${theme.palette.magenta};
        border-radius: 0.5rem;
        padding: 0 0.5rem;
        margin: 0.3rem 0;
      }
    '';
  };
}
