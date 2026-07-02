#!/bin/bash
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

PACKAGE="kvantum qt6ct nwg-look"
if command -v xbps-install &> /dev/null; then
    PKG_MANAGER="xbps-install"
elif command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
else
    echo -e "${RED}Error: Supported package manager not found!${NC}"
    exit 1
fi
echo -e "using $PKG_MANAGER as package manager..."
echo -e "installing dependencies..."
echo "sudo $PKG_MANAGER -S $PACKAGE"
sudo $PKG_MANAGER -S $PACKAGE

RED='\e[1;31m'
NC='\e[0m'
NOW=$(date +"%Y-%m-%d_%H-%M-%S")
DEST_DIR="$XDG_CONFIG_HOME/Kvantum"
URL="https://github.com/renamon2/kvantum-rena/raw/refs/heads/master/rena-night.tar.gz"
TEMP_DIR="/tmp/rena-night"
mkdir -p "$TEMP_DIR"
curl -L "$URL" -o "$TEMP_DIR/rena-night.tar.gz"
if [ -d "$DEST_DIR" ] && [ -d "$DEST_DIR/rena-night" ]; then
    rm -rf "$DEST_DIR/rena-night"
    mkdir -p "$DEST_DIR/rena-night"
    echo -e "The rena-night theme directory already exists.\nremoved...\ncreating new directory..."
    mv "$DEST_DIR/kvantum.kvconfig" "$DEST_DIR/kvantum.kvconfig.bak"
else
    mkdir -p "$DEST_DIR/rena-night"
    touch "$DEST_DIR/kvantum.kvconfig"
    echo -e "created new directory...\ncreating kvantum.kvconfig...\ncreating rena-night/..."
fi
tar -xzf "$TEMP_DIR/rena-night.tar.gz" -C "$DEST_DIR/"
echo -e "extracted rena-night theme..."
echo -e "[General]\ntheme=rena-night" > "$DEST_DIR/kvantum.kvconfig"
echo -e "set theme to rena-night in kvantum.kvconfig..."

ask_yes_no() {
    read -t 5 -p "$1 (Y/n) [Auto-yes in 5s]: " yn
    if [ -z "$yn" ]; then
        echo -e "\nTimeout or Enter pressed! Defaulting to: YES"
        return 0
    fi
    case $yn in
        [YyДд]* | [Yy][Ee][Ss] | [Дд][Аа] | "yep" | "yeah" | "sure" ) 
            return 0 # True / Yes
            ;;
        [NnНн]* | [Nn][Oo] | [Нн][Ее][Тт] | "nope" | "nay" ) 
            return 1 # False / No
            ;;
        * ) 
            echo "Unknown response. Defaulting to: NO"
            return 1 
            ;;
    esac
}

DEST_DIR="$XDG_CONFIG_HOME/qt6ct"
if ask_yes_no "Do you want to set the theme to rena-night for qt6ct if you don't want change fonts, icons, etc. then write N,\n but make cfg qt6ct it s still necessary"; then
    if [ -d $DEST_DIR ]; then
        mv "$DEST_DIR" "${DEST_DIR}_$NOW"
        echo "${RED} I'm stupid and forgot to create a backup :_( ${NC}"
    fi 
    echo -e "set theme to rena-night...\n"
    mkdir -p "$DEST_DIR"
    touch "$DEST_DIR/qt6ct.conf"
    echo -e "Writing qt6ct.conf configuration..."
    cat << 'EOF' > "$DEST_DIR/qt6ct.conf"
[Appearance]
custom_palette=false
icon_theme=Papirus-Dark
standard_dialogs=xdgdesktopportal
style=kvantum
    
[Fonts]
fixed="Fira Code Retina,12,-1,5,450,0,0,0,0,0,0,0,0,0,0,1,Regular"
general="Fira Code Light,12,-1,5,300,0,0,0,0,0,0,0,0,0,0,1,Regular"

[Interface]
activate_item_on_single_click=1
buttonbox_layout=1
cursor_flash_time=1000
dialog_buttons_have_icons=1
double_click_interval=400
gui_effects=General, AnimateMenu, AnimateCombo, AnimateTooltip, AnimateToolBox
keyboard_scheme=1
menus_have_icons=true
show_shortcuts_in_context_menus=true
stylesheets=/usr/share/qt6ct/qss/fusion-fixes.qss
toolbutton_style=4
underline_shortcut=1
wheel_scroll_lines=3

[Troubleshooting]
force_raster_widgets=1
ignored_applications=@Invalid()
EOF
if ask_yes_no "Do you want to change gtk theme to pine-rose"; then
        echo -e "set gtk theme to pine-rose..."
        URL="https://github.com/rose-pine/gtk.git"
        TEMP_DIR="/tmp/gtk-pine-rose"
        THEME_DIR="$XDG_DATA_HOME/themes"
        THEME_NAME="rose-pine-gtk"
        THEME_FULL_DIR="$THEME_DIR/$THEME_NAME"
        DEST_DIR_GTK3="$XDG_CONFIG_HOME/gtk-3.0"
        DEST_DIR_GTK4="$XDG_CONFIG_HOME/gtk-4.0"

        rm -rf "$TEMP_DIR"
        mkdir -p "$THEME_FULL_DIR/gtk-3.0"
        mkdir -p "$THEME_FULL_DIR/gtk-4.0"
        mkdir -p "$DEST_DIR_GTK3"
        mkdir -p "$DEST_DIR_GTK4"

        git clone "$URL" "$TEMP_DIR"
        cp -r "$TEMP_DIR/gtk3/rose-pine-gtk/"* "$THEME_FULL_DIR/gtk-3.0/"
        cp "$TEMP_DIR/gtk4/rose-pine.css" "$THEME_FULL_DIR/gtk-4.0/gtk.css"

        cat << EOF > "$THEME_FULL_DIR/index.theme"
[Desktop Entry]
Type=X-GNOME-Metatheme
Name=rose-pine-gtk
Encoding=UTF-8

[X-GNOME-Metatheme]
GtkTheme=rose-pine-gtk
EOF

        echo -e "Writing settings.ini configuration..."
        touch "$DEST_DIR_GTK3/settings.ini"
        cat << 'EOF' > "$DEST_DIR_GTK3/settings.ini"
[Settings]
gtk-theme-name=rose-pine-gtk
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Fira Code Light 11
gtk-cursor-theme-name=Kitty_Cursors
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_ICONS
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=0
gtk-menu-images=0
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=0
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintslight
gtk-xft-rgba=rgb
gtk-application-prefer-dark-theme=1
EOF

        touch "$DEST_DIR_GTK4/settings.ini"
        cat << 'EOF' > "$DEST_DIR_GTK4/settings.ini"
[Settings]
gtk-theme-name=rose-pine-gtk
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=Fira Code Light 11
gtk-cursor-theme-name=Kitty_Cursors
gtk-cursor-theme-size=24
gtk-application-prefer-dark-theme=1
EOF

        gsettings set org.gnome.desktop.interface gtk-theme 'rose-pine-gtk'
        gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
        gsettings set org.gnome.desktop.interface cursor-theme 'Kitty_Cursors'
        gsettings set org.gnome.desktop.interface font-name 'Fira Code Light 11'
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
        if command -v nwg-look &> /dev/null; then
            nwg-look -a &> /dev/null
        fi
    else
        echo -e "skipped setting theme to pine-rose..."
    fi
fi