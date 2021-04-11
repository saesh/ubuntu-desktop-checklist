#!/bin/sh

# shellcheck disable=SC1091
. ./deps/shflags

DEFINE_boolean 'report' false 'only show installation report' 'r'
DEFINE_boolean 'skip' false 'skip installed items' 's'

set -e

prefix_question="🤖"
prefix_done="✅"
prefix_skipped="⏭ "
prefix_warning="🟡"
prefix_missing="❌"

main() {
    echo   "==========="
    echo   "📦 Packages"
    printf "===========\n"
    apt_install "alacritty" "ppa:mmstick76/alacritty"
    apt_install "ansible"
    apt_install "curl"
    apt_install "docker"
    apt_install "docker-compose"
    apt_install "exa"
    apt_install "fish" "ppa:fish-shell/release-3"
    apt_install "fonts-mononoki"
    apt_install "git"
    apt_install "git-lfs"
    apt_install "gnome-tweaks"
    apt_install "gnome-shell-extensions"
    apt_install "htop"
    apt_install "vim"
    apt_install "zathura"

    gnome_extension_install "caffeine@patapon.info" "https://extensions.gnome.org/extension-data/caffeinepatapon.info.v37.shell-extension.zip"
    gnome_extension_install "sound-output-device-chooser@kgshank.net" "https://extensions.gnome.org/extension-data/sound-output-device-chooserkgshank.net.v35.shell-extension.zip"
    gnome_extension_install "dash-to-panel@jderose9.github.com" "https://extensions.gnome.org/extension-data/dash-to-paneljderose9.github.com.v40.shell-extension.zip"
    gnome_extension_install "clipboard-indicator@tudmotu.com" "https://extensions.gnome.org/extension-data/clipboard-indicatortudmotu.com.v37.shell-extension.zip"

    snap_install "code" "classic"
    snap_install "intellij-idea-community" "classic"
    snap_install "signal-desktop"
    snap_install "spotify"
    
    if is_report_only; then
        exit 0
    fi

    install_iosevka_font
    install_pop_os_shell "node-typescript"
    install_vscode_extensions "vscode-icons-team.vscode-icons" \
                              "sainnhe.sonokai" \
                              "golang.go" \
                              "ms-azuretools.vscode-docker" \
                              "usernamehw.errorlens" \
                              "timonwong.shellcheck" \
                              "wayou.vscode-todo-highlight" \
                              "coenraads.bracket-pair-colorizer-2"
    install_fzf
    install_youtubedl "ffmpeg"

    link_dotfile "vimrc" "$HOME/.vimrc"
    link_dotfile "fish/config.fish" "$HOME/.config/fish/config.fish"
    link_dotfile "fish/fishfile" "$HOME/.config/fish/fishfile"
    link_dotfile "fish/go.fish" "$HOME/.config/fish/go.fish"
    link_dotfile "fonts.conf" "$HOME/.config/fontconfig/fonts.conf"

    echo

    echo   "==================="
    echo   "🎛  System settings"
    printf "===================\n"
    setting "Show all input sources in gnome settings?\n(Required for Eurkey to show up)" "gsettings set org.gnome.desktop.input-sources show-all-sources true"
    setting "Hide the dock?" "gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false"
    setting "Set system clock to local time?\n(Required for correct time in Windows in dual-boot environment)" "timedatectl set-local-rtc 1 --adjust-system-clock"

    echo

    echo "📝 Please logout and back in and perform these steps:"
    echo
    echo "- set Eurkey in keyboard settings"
}

apt_install() (
    package_name=$1
    ppa_dependency=$2
   
    if is_report_only; then
        report_apt_installation "$package_name"
        return
    fi

    if is_skip_installed && _is_installed_with_apt "$package_name"; then
        return
    fi

    if _should_proceed "Install $package_name ($( _is_installed_with_apt "$package_name" && echo "$prefix_done" || echo "$prefix_missing" ))"; then
        if [ -n "$ppa_dependency" ]; then
            sudo apt-add-repository -y "$ppa_dependency"
        fi

        if _install_with_apt "$package_name"; then
            echo "$prefix_done $package_name installed"
        else 
            echo "$prefix_warning $package_name could not be installed"
        fi
    else
        echo "$prefix_skipped $package_name installation skipped"
    fi
)

snap_install() (
    package_name=$1
    is_classic=$2

    if is_report_only; then
        report_snap_installation "$package_name"
        return
    fi

    if is_skip_installed && _is_installed_with_snap "$package_name"; then
        return
    fi
    
    if _should_proceed "Install $package_name ($( _is_installed_with_snap "$package_name" && echo "$prefix_done" || echo "$prefix_missing" ))"; then
        if [ "$is_classic" = "classic" ]; then
            snap install "$package_name" --classic
        else
            snap install "$package_name"
        fi 
        return_code=$?
        if [ "$return_code" -eq "0" ]; then
            echo "$prefix_done $package_name installed"
        else 
            echo "$prefix_warning $package_name could not be installed"
        fi
    else
        echo "$prefix_skipped $package_name installation skipped"
    fi
)

gnome_extension_install() (
    extension_name=$1
    download_path=$2

    if is_report_only; then
        report_gnome_extension_installation "$extension_name"
        return
    fi

    if is_skip_installed && _is_gnome_extension_installed "$extension_name"; then
        return
    fi

    if _should_proceed "Install $extension_name"; then
        wget -O "$HOME/$extension_name.zip" "$download_path"

        gnome-extensions install "$HOME/$extension_name.zip"
        gnome-extensions enable "$extension_name"

        rm "$HOME/$extension_name.zip"
    else
        echo "$prefix_skipped $extension_name installation skipped"
    fi
)

setting() (
    question=$1
    activation_command=$2
    if _should_proceed "$question"; then
        eval "$activation_command"
        return_code=$?
        if [ "$return_code" -eq "0" ]; then
            echo "$prefix_done Done"
        else 
            echo "$prefix_warning Something went wrong"
        fi
    else
        echo "$prefix_skipped Skipped"
    fi
)

install_iosevka_font() (
    package_name="Iosevka font"
    if _should_proceed "Install $package_name"; then
        _download_and_unzip "https://github.com/be5invis/Iosevka/releases/download/v5.0.5/ttf-iosevka-ss08-5.0.5.zip" "$HOME/.local/share/fonts"
        _download_and_unzip "https://github.com/be5invis/Iosevka/releases/download/v5.0.5/ttf-iosevka-term-ss08-5.0.5.zip" "$HOME/.local/share/fonts"
        return_code=$?
        if [ "$return_code" -eq "0" ]; then
            echo "$prefix_done $package_name installed"
        else 
            echo "$prefix_warning $package_name could not be installed"
        fi
    else
        echo "$prefix_skipped $package_name installation skipped"
    fi
)

install_pop_os_shell() (
    dependency=$1
    package_name="PopOS Shell"
    if _should_proceed "Install $package_name"; then
        _install_with_apt "$dependency"
        git clone https://github.com/pop-os/shell.git ~/pop-os-shell
        cd ~/pop-os-shell && make local-install && cd -
    else
        echo "$prefix_skipped $package_name installation skipped"
    fi
)

install_vscode_extensions() (
    package_name="VScode extensions"
    
    if ! _is_installed_with_snap "code"; then
        return 0
    fi

    if _should_proceed "Install $package_name"; then
        for extension in "$@"
        do
            code --install-extension "$extension" 2>/dev/null
            echo "$prefix_done $package_name $extension installed"
        done
    else
        echo "$prefix_skipped $package_name installation skipped"
    fi
)

install_fzf() (
    package_name="fzf"
    fd_version="8.2.1"
    bat_version="0.18.0"

    if _should_proceed "Install $package_name"; then
        # fzf
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --completion --key-bindings --update-rc || echo "$package_name already installed"
        
        # fd for fzf.fish
        _download_and_dpkg "https://github.com/sharkdp/fd/releases/download/v${fd_version}/fd-musl_${fd_version}_amd64.deb"

        # bat for fzf.fish
        _download_and_dpkg "https://github.com/sharkdp/bat/releases/download/v${bat_version}/bat-musl_${bat_version}_amd64.deb"
        _link_dotfile "$(pwd)/dotfiles/bat" "$HOME/.config/bat/config"

        echo "$prefix_done $package_name, fd, bat installed"
    else
        echo "$prefix_skipped $package_name installation skipped"
    fi
    echo
)

install_youtubedl() (
    dependency=$1
    package_name="youtube-dl"
    url="https://yt-dl.org/downloads/latest/youtube-dl"
    destination="/usr/local/bin/youtube-dl"

    if _should_proceed "Install $package_name"; then
        _install_with_apt "$dependency"
        sudo wget -O "$destination" -q "$url" && \
        sudo chmod +x "$destination"
    else
        echo "$prefix_skipped $package_name installation skipped"
    fi
    
)

is_report_only() {
    [ "$FLAGS_report" = "${FLAGS_TRUE}" ] && return 0 || return 1
}

is_skip_installed() {
    [ "$FLAGS_skip" = "${FLAGS_TRUE}" ] && return 0 || return 1
}

report_apt_installation() (
    package_name=$1

    if _is_installed_with_apt "$package_name"; then
        echo "$prefix_done $package_name"
    else
        echo "$prefix_missing $package_name"
    fi
)

report_snap_installation() (
    package_name=$1

    if _is_installed_with_snap "$package_name"; then
        echo "$prefix_done $package_name"
    else
        echo "$prefix_missing $package_name"
    fi
)

report_gnome_extension_installation() (
    extension_name=$1

    if _is_gnome_extension_installed "$extension_name"; then
        echo "$prefix_done $extension_name"
    else
        echo "$prefix_missing $extension_name"
    fi
)

link_dotfile() (
    dotfile_name="$1"
    target="$2"

    if _should_proceed "Link $dotfile_name"; then
        _link_dotfile "$(pwd)/dotfiles/$dotfile_name" "$target"
    else
        echo "$prefix_skipped $dotfile_name dotfile linking skipped"
    fi
)

_should_proceed() (
    question=$1

    echo "$prefix_question $question?"
    read -r response
    case $response in
    [yY])
        return 0
        ;;
    *)
        return 1
        ;;
    esac
)

_install_with_apt() (
    package_name=$1
    sudo apt-get -qq -y install "$package_name"
)

_is_installed_with_apt() (
    package_name=$1
    # flip 1 and 0; grep count of 1 means it is installed; thus 0 for success should be returned
    count="$(dpkg-query -W -f='${Status}' "$package_name" 2>/dev/null | grep -c "ok installed")"
    return "$((1 - count))"
)

_is_installed_with_snap() (
    package_name=$1
    # flip 1 and 0; grep count of 1 means it is installed; thus 0 for success should be returned
    count="$(snap info "$package_name" 2>/dev/null | grep -c "installed")"
    return "$((1 - count))"
)

_is_gnome_extension_installed() (
    extension_name=$1
    # flip 1 and 0; grep count of 1 means it is installed; thus 0 for success should be returned
    count="$(gnome-extensions show "$extension_name" 2>/dev/null | grep -c "ENABLED")"
    return "$((1 - count))"
)

_download_and_unzip() (
    url=$1
    target_dir=$2
    download_dir=~
    download_filename="download.zip"

    mkdir -p "$target_dir"

    wget -O "$download_dir/$download_filename" -q "$url" && \
    unzip -d "$target_dir" "$download_dir/$download_filename" && \
    rm "$download_dir/$download_filename"
)

_download_and_dpkg() (
    url=$1
    download_filename="$(mktemp)"

    wget -O "$download_filename" -q "$url" && \
    sudo dpkg -i "$download_filename"
    rm "$download_filename"
)

_link_dotfile() (
    from=$1
    to=$2
    target_path=$(dirname "$to")
    
    mkdir -p "$target_path"

    ln -s "$from" "$to"
)

FLAGS "$@" || exit $?
eval set -- "${FLAGS_ARGV}"
main "$@"