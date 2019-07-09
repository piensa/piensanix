{ config, lib, pkgs, ... }:

let
  i3statusbarconfig = pkgs.writeText "i3statusbar-config" ''
    theme = "solarized-dark"
    icons = "awesome"

    [[block]]
    block = "battery"
    upower = true
    format = "{percentage}% {time}"

    [[block]]
    block = "focused_window"
    max_width = 21
 
    [[block]]
    block = "backlight"

    [[block]]
    block = "disk_space"
    path = "/d"
    alias = "/d"
    info_type = "available"
    unit = "GB"
    interval = 20
    warning = 20.0
    alert = 10.0

    [[block]]
    block = "disk_space"
    path = "/"
    alias = "/"
    info_type = "available"
    unit = "GB"
    interval = 20
    warning = 20.0
    alert = 10.0


    [[block]]
    block = "memory"
    display_type = "memory"
    format_mem = "{Mug}/{MTg}GB({Mup}%)"
    format_swap = "{SUg}/{STg}GB({SUp}%)"
    icons = true
    clickable = true
    interval = 5
    warning_mem = 80
    warning_swap = 80
    critical_mem = 95
    critical_swap = 95

    [[block]]
    block = "cpu"
    interval = 1

    [[block]]
    block = "load"
    interval = 1
    format = "{1m}"

    [[block]]
    block = "uptime"

    [[block]]
    block = "temperature"
    collapsed = false
    interval = 10
    format = "{min}° min, {max}° max, {average}° avg"

    [[block]]
    block = "sound"

    [[block]]
    block = "time"
    interval = 60
    format = "%a %d/%m %R"
  '';
  swayconfig = pkgs.writeText "swayconfig" ''
    # Logo key. Use Mod1 for Alt.
    set $mod Mod4
    # Home row direction keys, like vim
    set $left h
    set $down j
    set $up k
    set $right l

    # Your preferred terminal emulator
    set $term termite

    # Your preferred application launcher
    set $menu dmenu_path | j4-dmenu-desktop --dmenu='bemenu -i --nb "#3f3f3f" --nf "#dcdccc" --fn "pango:DejaVu Sans Mono 12"' --term='termite' | xargs swaymsg exec --

    ### Output configuration
    output HDMI-A-1 mode 3840x2160@60Hz
    # You can get the names of your outputs by running: swaymsg -t get_outputs

    ### Idle configuration
    #exec swayidle -w \
    #      timeout 300 'swaylock -f -c 000000' \
    #      timeout 600 'swaymsg "output * dpms off"' \
    #           resume 'swaymsg "output * dpms on"' \
    #      before-sleep 'swaylock -f -c 000000'

    # This will lock your screen after 300 seconds of inactivity, then turn off
    # your displays after another 300 seconds, and turn your screens back on when
    # resumed. It will also lock your screen before your computer goes to sleep.

    ### Input configuration
    
    # You can get the names of your inputs by running: swaymsg -t get_inputs
    # Read `man 5 sway-input` for more information about this section.

    ### Key bindings

    # start a terminal
    bindsym $mod+Return exec $term

    # kill focused window
    bindsym $mod+Shift+q kill

    # start your launcher
    bindsym $mod+d exec $menu

    # Drag floating windows by holding down $mod and left mouse button.
    # Resize them with right mouse button + $mod.
    # Despite the name, also works for non-floating windows.
    # Change normal to inverse to use left mouse button for resizing and right
    # mouse button for dragging.
    floating_modifier $mod normal

    # reload the configuration file
    bindsym $mod+Shift+c reload

    # exit sway (logs you out of your Wayland session)
    bindsym $mod+Shift+e exec swaymsg exit

    bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume 0 +5% #increase sound volume
    bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume 0 -5% #decrease sound volume
    bindsym XF86AudioMute exec --no-startup-id pactl set-sink-mute 0 toggle # mute sound

    # Brightness
    bindsym XF86MonBrightnessDown exec light -U 5
    bindsym XF86MonBrightnessUp exec light -A 5

    # Printscreen
    bindsym --release Print exec grim -g \"$(slurp)" - | wl-copy

    ## Moving around:
    
    # Move your focus around
    bindsym $mod+$left focus left
    bindsym $mod+$down focus down
    bindsym $mod+$up focus up
    bindsym $mod+$right focus right
    # or use $mod+[up|down|left|right]
    bindsym $mod+Left focus left
    bindsym $mod+Down focus down
    bindsym $mod+Up focus up
    bindsym $mod+Right focus right

    # _move_ the focused window with the same, but add Shift
    bindsym $mod+Shift+$left move left
    bindsym $mod+Shift+$down move down
    bindsym $mod+Shift+$up move up
    bindsym $mod+Shift+$right move right
    # ditto, with arrow keys
    bindsym $mod+Shift+Left move left
    bindsym $mod+Shift+Down move down
    bindsym $mod+Shift+Up move up
    bindsym $mod+Shift+Right move right

    ## Workspaces:

    # switch to workspace
    bindsym $mod+1 workspace 1
    bindsym $mod+2 workspace 2
    bindsym $mod+3 workspace 3
    bindsym $mod+4 workspace 4
    bindsym $mod+5 workspace 5
    bindsym $mod+6 workspace 6
    bindsym $mod+7 workspace 7
    bindsym $mod+8 workspace 8
    bindsym $mod+9 workspace 9
    bindsym $mod+0 workspace 10
    # move focused container to workspace
    bindsym $mod+Shift+1 move container to workspace 1
    bindsym $mod+Shift+2 move container to workspace 2
    bindsym $mod+Shift+3 move container to workspace 3
    bindsym $mod+Shift+4 move container to workspace 4
    bindsym $mod+Shift+5 move container to workspace 5
    bindsym $mod+Shift+6 move container to workspace 6
    bindsym $mod+Shift+7 move container to workspace 7
    bindsym $mod+Shift+8 move container to workspace 8
    bindsym $mod+Shift+9 move container to workspace 9
    bindsym $mod+Shift+0 move container to workspace 10
    # Note: workspaces can have any name you want, not just numbers.
    # We just use 1-10 as the default.

    ## Layout stuff:

    # You can "split" the current object of your focus with
    # $mod+b or $mod+v, for horizontal and vertical splits
    # respectively.
    bindsym $mod+b splith
    bindsym $mod+v splitv

    # Switch the current container between different layout styles
    bindsym $mod+s layout stacking
    bindsym $mod+w layout tabbed
    bindsym $mod+e layout toggle split

    # Make the current focus fullscreen
    bindsym $mod+f fullscreen

    # Toggle the current focus between tiling and floating mode
    bindsym $mod+Shift+space floating toggle

    # Swap focus between the tiling area and the floating area
    bindsym $mod+space focus mode_toggle

    # move focus to the parent container
    bindsym $mod+a focus parent

    ## Scratchpad:

    # Sway has a "scratchpad", which is a bag of holding for windows.
    # You can send windows there and get them back later.

    # Move the currently focused window to the scratchpad
    bindsym $mod+Shift+minus move scratchpad

    # Show the next scratchpad window or hide the focused scratchpad window.
    # If there are multiple scratchpad windows, this command cycles through them.
    bindsym $mod+minus scratchpad show

    ## Resizing containers:

    mode "resize" {
      # left will shrink the containers width
      # right will grow the containers width
      # up will shrink the containers height
      # down will grow the containers height
      bindsym $left resize shrink width 10px
      bindsym $down resize grow height 10px
      bindsym $up resize shrink height 10px
      bindsym $right resize grow width 10px

      # ditto, with arrow keys
      bindsym Left resize shrink width 10px
      bindsym Down resize grow height 10px
      bindsym Up resize shrink height 10px
      bindsym Right resize grow width 10px

      # return to default mode
      bindsym Return mode "default"
      bindsym Escape mode "default"
    }

    bindsym $mod+r mode "resize"


    ## Status Bar:

    # Read `man 5 sway-bar` for more information about this section.
    bar {
      font pango:DejaVu Sans Mono, FontAwesome 12
      position top

      # When the status_command prints a new line to stdout, swaybar updates.
      # The default just shows the current date and time.
      status_command i3status-rs ${i3statusbarconfig}

      colors {
        separator #666666
        background #222222
        statusline #dddddd
        focused_workspace #0088CC #0088CC #ffffff
        active_workspace #333333 #333333 #ffffff
        inactive_workspace #333333 #333333 #888888
        urgent_workspace #2f343a #900000 #ffffff
      }
    }
  '';
in
{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  hardware.sensor.iio.enable = true;
  services.upower.enable = true;

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", RUN+="${pkgs.coreutils}/bin/chgrp video %S%p/brightness", RUN+="${pkgs.coreutils}/bin/chmod g+w %S%p/brightness"
  '';

  services.udev.path = [
   pkgs.coreutils # for chgrp
  ];

  #nixpkgs.overlays = [ waylandOverlay ];

  programs.sway = { 
    enable = true;
    extraSessionCommands = ''
      export SDL_VIDEODRIVER=wayland
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      export _JAVA_AWT_WM_NONREPARENTING=1
      export BEMENU_BACKEND=wayland
      export SWAY_CONFIG_DIR=${swayconfig}
    '';
    extraPackages = with pkgs; [
     swayidle
     swaylock
     #waybar
     i3status-rust
     grim
     slurp
     mako
     wl-clipboard
     #wlstream
     #oguri
     #kanshi
     #redshift-wayland
     #xdg-desktop-portal-wlr
    ];
  };

  environment.systemPackages = with pkgs; [
    # xwayland is needed for firefox and google chrome, why?
    xwayland
    firefox-wayland
    mutt spectacle htop
    j4-dmenu-desktop
    termite
    #wayfire
    #waybox
    #bspwc
    qt5.qtwayland
    light
    ncurses
    pciutils
  ];
}
