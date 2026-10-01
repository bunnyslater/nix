{ lib, pkgs, inputs, ... }: let
in {

  imports = [
    inputs.plasma-manager.homeManagerModules.plasma-manager
  ];

  # Configures Breeze GTK theme.
  gtk = {
    enable = true;
    theme = lib.mkMerge [
      {
        name = "breeze-gtk";
      }
    ];
  };

  programs.plasma = {
    enable = true;
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      colorScheme = "CatppuccinMochaLavender";
      iconTheme = "breeze-dark";
      wallpaper = "/home/billie/Images/Wallpapers/jens-riesenberg-MdfCeYF-ASA-unsplash.jpg";
    };
    kscreenlocker.appearance.wallpaper = "/home/billie/.config/bunny/misc/jamie-kettle-CziCVd8c9lU-unsplash copy 2.jpg";
    panels = [
      {
        location = "bottom";
        floating = false;
        opacity = "translucent";
        height = 28;
        widgets = [
          {
            name = "org.kde.plasma.kickoff";
          }
          {
            name = "org.kde.plasma.icontasks";
            config = {
              General = {
                launchers = [
                  "applications:org.kde.dolphin.desktop"
                  "applications:helium.desktop"
                  "applications:1password.desktop"
                  "applications:org.kde.konsole.desktop"
                  "applications:systemsettings.desktop"
                  "applications:apple-notes.desktop"
                  "applications:org.signal.Signal.desktop"
                  "applications:feishin.desktop"
                  "applications:virt-manager.desktop"
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
  home.packages = with pkgs; [
    (pkgs.catppuccin-kde.override {
      flavour = ["mocha"];
      accents = ["lavender"];
    })
    snapshot
    ddcutil-service
    xdg-utils
    ffmpegthumbnailer
  ];
  home.file.".local/share/konsole/CatppuccinMocha.colorscheme" = {
  text = ''
    [Background]
    Color=30,30,46

    [BackgroundFaint]
    Color=30,30,46

    [BackgroundIntense]
    Color=30,30,46

    [Color0]
    Color=69,71,90

    [Color0Faint]
    Color=69,71,90

    [Color0Intense]
    Color=88,91,112

    [Color1]
    Color=243,139,168

    [Color1Faint]
    Color=243,139,168

    [Color1Intense]
    Color=243,119,153

    [Color2]
    Color=166,227,161

    [Color2Faint]
    Color=166,227,161

    [Color2Intense]
    Color=137,216,139

    [Color3]
    Color=249,226,175

    [Color3Faint]
    Color=249,226,175

    [Color3Intense]
    Color=235,211,145

    [Color4]
    Color=137,180,250

    [Color4Faint]
    Color=137,180,250

    [Color4Intense]
    Color=116,168,252

    [Color5]
    Color=245,194,231

    [Color5Faint]
    Color=245,194,231

    [Color5Intense]
    Color=242,174,222

    [Color6]
    Color=148,226,213

    [Color6Faint]
    Color=148,226,213

    [Color6Intense]
    Color=107,215,202

    [Color7]
    Color=166,173,200

    [Color7Faint]
    Color=166,173,200

    [Color7Intense]
    Color=186,194,222

    [Foreground]
    Color=205,214,244

    [ForegroundFaint]
    Color=205,214,244

    [ForegroundIntense]
    Color=205,214,244

    [General]
    Anchor=0.5,0.5
    Blur=false
    ColorRandomization=false
    Description=CatppuccinMocha
    FillStyle=Tile
    Opacity=1
    Wallpaper=
    WallpaperFlipType=NoFlip
    WallpaperOpacity=1 '';
};

home.file.".local/share/konsole/Profile\ 1.profile" = {
  text = ''
    [Appearance]
    ColorScheme=CatppuccinMocha
    Font=Hack,14,-1,7,400,0,0,0,0,0,0,0,0,0,0,1

    [General]
    Name=Profile 1
    Parent=FALLBACK/
  '';
};

home.file.".config/dolphinrc" = {
  text = ''
  MenuBar=Enabled

  [General]
  EditableUrl=true
  GlobalViewProps=false
  ShowStatusBar=FullWidth
  ShowZoomSlider=true
  Version=202
  ViewPropsTimestamp=2026,1,12,16,55,3.111

  [IconsMode]
  PreviewSize=224

  [KFileDialog Settings]
  Places Icons Auto-resize=false
  Places Icons Static Size=22

  [PreviewSettings]
  Plugins=svgthumbnail,djvuthumbnail,ebookthumbnail,comicbookthumbnail,exrthumbnail,cursorthumbnail,audiothumbnail,windowsexethumbnail,imagethumbnail,directorythumbnail,opendocumentthumbnail,jpegthumbnail,appimagethumbnail,kraorathumbnail,windowsimagethumbnail,fontthumbnail,mobithumbnail,blenderthumbnail,ffmpegthumbs,gsthumbnail,rawthumbnail,ffmpegthumbnailer

  [ViewPropertiesDialog]
  1536x960 screen: Height=320
  1536x960 screen: Width=482                  
  '';
};
}