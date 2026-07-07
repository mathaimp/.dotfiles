{
  flake.homeModules.wlogout =
    { config, pkgs, lib, ... }:
    let
      c = config.lib.stylix.colors.withHashtag;

      fntSize   = 16;
      buttonRad = 25;
      activeRad = 20;
      mgn       = 20;
      hvr       = 10;

      fontName = config.stylix.fonts.sansSerif.name;
      icons    = "${pkgs.wlogout}/share/wlogout/icons";
    in
    {
      programs.wlogout = {
        enable = true;

        layout = [
          { label = "lock";      action = "loginctl lock-session";                      text = "Lock";      keybind = "l"; }
          { label = "logout";    action = "loginctl terminate-session '$XDG_SESSION_ID'";       text = "Logout";    keybind = "e"; }
          { label = "suspend";   action = "loginctl lock-session && systemctl suspend"; text = "Suspend";   keybind = "u"; }
          { label = "shutdown";  action = "systemctl poweroff";            text = "Shutdown";  keybind = "s"; }
          { label = "hibernate"; action = "systemctl hibernate";           text = "Hibernate"; keybind = "h"; }
          { label = "reboot";    action = "systemctl reboot";              text = "Reboot";    keybind = "r"; }
        ];

        style = ''
          * {
            background-image: none;
            font-size: ${toString fntSize}px;
            font-family: "${fontName}", sans-serif;
          }

          window {
            background-color: rgba(${config.lib.stylix.colors.base01-rgb-r}, ${config.lib.stylix.colors.base01-rgb-g}, ${config.lib.stylix.colors.base01-rgb-b}, 0.9);
          }

          button {
            color: ${c.base05};
            background-color: ${c.base01};
            outline-style: none;
            border: none;
            border-width: 0px;
            background-repeat: no-repeat;
            background-position: center;
            background-size: 20%;
            border-radius: 0px;
            box-shadow: none;
            text-shadow: none;
          }

          button:focus {
            background-color: ${c.base02};
            background-size: 30%;
          }

          button:hover {
            background-color: ${c.base03};
            background-size: 40%;
            border-radius: ${toString activeRad}px;
            transition: all 0.3s cubic-bezier(.55,0.0,.28,1.682);
          }

          button:hover#lock      { border-radius: ${toString activeRad}px; margin: ${toString hvr}px 0px ${toString hvr}px ${toString mgn}px; }
          button:hover#logout,
          button:hover#suspend,
          button:hover#shutdown,
          button:hover#hibernate { border-radius: ${toString activeRad}px; margin: ${toString hvr}px 0px ${toString hvr}px 0px; }
          button:hover#reboot    { border-radius: ${toString activeRad}px; margin: ${toString hvr}px ${toString mgn}px ${toString hvr}px 0px; }

          #lock {
            background-image: image(url("${icons}/lock.png"));
            border-radius: ${toString buttonRad}px 0px 0px ${toString buttonRad}px;
            margin: ${toString mgn}px 0px ${toString mgn}px ${toString mgn}px;
          }
          #logout {
            background-image: image(url("${icons}/logout.png"));
            margin: ${toString mgn}px 0px ${toString mgn}px 0px;
          }
          #suspend {
            background-image: image(url("${icons}/suspend.png"));
            margin: ${toString mgn}px 0px ${toString mgn}px 0px;
          }
          #shutdown {
            background-image: image(url("${icons}/shutdown.png"));
            margin: ${toString mgn}px 0px ${toString mgn}px 0px;
          }
          #hibernate {
            background-image: image(url("${icons}/hibernate.png"));
            margin: ${toString mgn}px 0px ${toString mgn}px 0px;
          }
          #reboot {
            background-image: image(url("${icons}/reboot.png"));
            border-radius: 0px ${toString buttonRad}px ${toString buttonRad}px 0px;
            margin: ${toString mgn}px ${toString mgn}px ${toString mgn}px 0px;
          }
        '';
      };
    };
}
