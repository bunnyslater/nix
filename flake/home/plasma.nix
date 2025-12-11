{ lib, globals, username, ... }: let
  username = globals.username;
in lib.mkIf globals.enablePlasma {
  programs.plasma = {
    enable = true;
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      colorScheme = "CatppuccinMochaLavender";
      iconTheme = "breeze-dark";
      wallpaper = "/home/${username}/.config/bunny/misc/jamie-kettle-CziCVd8c9lU-unsplash copy 2.jpg";
    };
    kscreenlocker.appearance.wallpaper = "/home/${username}/.config/bunny/misc/jamie-kettle-CziCVd8c9lU-unsplash copy 2.jpg";
    panels = [
      {
        location = "bottom";
        floating = false;
        # opacity = "translucent";
        height = 28;
        widgets = [
          # We can configure the widgets by adding the name and config
          # attributes. For example to add the the kickoff widget and set the
          # icon to "nix-snowflake-white" use the below configuration. This will
          # add the "icon" key to the "General" group for the widget in
          # ~/.config/plasma-org.kde.plasma.desktop-appletsrc.
          {
            name = "org.kde.plasma.kickoff";
          }
          {
            name = "org.kde.plasma.icontasks";
            config = {
              General = {
                launchers = [
                  "applications:org.kde.dolphin.desktop"
                  "applications:firefox.desktop"
                  "applications:1password.desktop"
                  "applications:org.kde.konsole.desktop"
                  "applications:systemsettings.desktop"
                  "applications:apple-notes.desktop"
                  "applications:org.signal.Signal.desktop"
                ] ++ lib.optional globals.enableVirtualization "applications:virt-manager.desktop" ++ [
                  "applications:chromium-vopono.desktop"
                  "applications:anki.desktop"
                  "applications:code.desktop"
                ];
              };
            };
          }
          "org.kde.plasma.pager"
          {
            systemTray.items = {
              shown = [
                "org.kde.plasma.volume"
                "org.kde.plasma.networkmanagement"
                "org.kde.plasma.brightness"
                "org.kde.plasma.battery"
              ];
              hidden = [
                "org.kde.plasma.bluetooth"
              ];
            };
          }
          "org.kde.plasma.digitalclock"
          "org.kde.plasma.showdesktop"
        ];
      }
    ];
  };
  home.file.".local/share/konsole/Breeze.colorscheme" = {
  text = ''
    [Background]
    Color=20,29,42

    [BackgroundFaint]
    Color=49,54,59

    [BackgroundIntense]
    Color=0,0,0

    [Color0]
    Color=35,38,39

    [Color0Faint]
    Color=49,54,59

    [Color0Intense]
    Color=127,140,141

    [Color1]
    Color=237,21,21

    [Color1Faint]
    Color=120,50,40

    [Color1Intense]
    Color=192,57,43

    [Color2]
    Color=17,209,22

    [Color2Faint]
    Color=23,162,98

    [Color2Intense]
    Color=28,220,154

    [Color3]
    Color=246,116,0

    [Color3Faint]
    Color=182,86,25

    [Color3Intense]
    Color=253,188,75

    [Color4]
    Color=29,153,243

    [Color4Faint]
    Color=27,102,143

    [Color4Intense]
    Color=61,174,233

    [Color5]
    Color=155,89,182

    [Color5Faint]
    Color=97,74,115

    [Color5Intense]
    Color=142,68,173

    [Color6]
    Color=26,188,156

    [Color6Faint]
    Color=24,108,96

    [Color6Intense]
    Color=22,160,133

    [Color7]
    Color=252,252,252

    [Color7Faint]
    Color=99,104,109

    [Color7Intense]
    Color=255,255,255

    [Foreground]
    Color=252,252,252

    [ForegroundFaint]
    Color=239,240,241

    [ForegroundIntense]
    Color=61,174,233

    [General]
    Anchor=0.5,0.5
    Blur=false
    ColorRandomization=false
    Description=Breeze
    FillStyle=Tile
    Opacity=1
    Wallpaper=
    WallpaperFlipType=NoFlip
    WallpaperOpacity=1 '';
};

home.file.".local/share/konsole/Profile\ 1.profile" = {
  text = ''
    [Appearance]
    ColorScheme=Breeze
    Font=Hack,12,-1,7,400,0,0,0,0,0,0,0,0,0,0,1

    [General]
    Name=Profile 1
    Parent=FALLBACK/
  '';
};

home.file.".config/dolphinrc" = {
  text = ''
      MenuBar=Disabled

      [DetailsMode]
      IconSize=48
      RightPadding=23

      [ExtractDialog]
      1536x960 screen: Height=540
      1536x960 screen: Width=1024

      [FileDialogSize]
      2 screens: Height=584
      2 screens: Width=820

      [General]
      GlobalViewProps=false
      ShowFullPath=true
      ShowStatusBar=FullWidth
      Version=202
      ViewPropsTimestamp=2025,7,20,15,23,11.818

      [IconsMode]
      IconSize=80
      PreviewSize=144

      [KFileDialog Settings]
      Places Icons Auto-resize=false
      Places Icons Static Size=22

      [PreviewSettings]
      Plugins=appimagethumbnail,audiothumbnail,comicbookthumbnail,cursorthumbnail,djvuthumbnail,ebookthumbnail,exrthumbnail,directorythumbnail,fontthumbnail,imagethumbnail,jpegthumbnail,kraorathumbnail,windowsexethumbnail,windowsimagethumbnail,opendocumentthumbnail,svgthumbnail,gdk-pixbuf-thumbnailer

      [Search]
      Location=Everywhere

      [ViewPropertiesDialog]
      1536x960 screen: Height=714
      1536x960 screen: Width=379
  '';
};
}