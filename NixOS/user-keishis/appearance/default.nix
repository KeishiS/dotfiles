{ ... }:
{
  # ============================================================================
  # System-wide Dark Mode Configuration
  # ============================================================================
  # This configuration sets the system preference to dark mode, which is
  # detected by:
  # - Modern browsers (Chrome, Firefox) via FreeDesktop Portal
  # - GTK applications via dconf/gsettings
  # - Applications using prefers-color-scheme CSS media query
  # ============================================================================

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
}
