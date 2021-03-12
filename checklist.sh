#!/bin/sh

set -e

apt_install_command="sudo apt-get -qq -y install"
apt_add_repository="sudo apt-add-repository -y"
snap_install_command="snap install"
prefix_question="🤖"
prefix_done="✅"
prefix_skipped="⏭ "
prefix_warning="🟡"
prefix_missing="❌"
report_only=false

apt_install() {
    package_name=$1
    ppa_dependency=$2

    if $report_only; then
        report_apt_installation "$package_name"
        return
    fi

    if _should_proceed "Install $package_name"; then
        if [ -n "$ppa_dependency" ]; then
            eval "$apt_add_repository" "$ppa_dependency"
        fi

        if _install_with_apt "$package_name"; then
            echo "$prefix_done $package_name installed"
        else 
            echo "$prefix_warning $package_name could not be installed"
        fi
    else
        echo "$prefix_skipped $package_name installation skipped"
    fi
}

_should_proceed() {
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
}

_install_with_apt() {
    package_name=$1
    eval "$apt_install_command" "$package_name"
}

snap_install() {
    package_name=$1
    is_classic=$2

    if [ $report_only = true ]; then
        report_snap_installation "$package_name"
        return
    fi
    
    if _should_proceed "Install $package_name"; then
        if [ "$is_classic" = "classic" ]; then
            eval "$snap_install_command" "$package_name" --classic
        else
            eval "$snap_install_command" "$package_name"
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
}

setting() {
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
}

set_report_only() {
    if [ "$1" = "report" ]; then
        report_only=true
    fi
}

report_apt_installation() {
    package=$1

    if [ "$(dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -c "ok installed")" -eq 1 ]; then
        echo "$prefix_done $package"
    else
        echo "$prefix_missing $package"
    fi
}

report_snap_installation() {
    package=$1

    if [ "$(snap info "$package" 2>/dev/null | grep -c "installed")" -eq 1 ]; then
        echo "$prefix_done $package"
    else
        echo "$prefix_missing $package"
    fi
}

install_iosevka_font() {
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
}

install_pop_os_shell() {
    dependency=$1
    package_name="PopOS Shell"
    if _should_proceed "Install $package_name"; then
        _install_with_apt "$dependency"
        git clone https://github.com/pop-os/shell.git ~/pop-os-shell
        cd ~/pop-os-shell && make local-install && cd -
    else
        echo "$prefix_skipped $package_name installation skipped"
    fi
}

_download_and_unzip() {
    url=$1
    target_dir=$2
    download_dir=~
    download_filename="download.zip"

    create_dir "$target_dir"

    wget -O "$download_dir/$download_filename" -q "$url" && \
    unzip -d "$target_dir" "$download_dir/$download_filename" && \
    rm "$download_dir/$download_filename"
}

create_dir() {
    dir=$1
    mkdir -p "$dir"
}

main() {
    set_report_only "$1"

    echo   "==========="
    echo   "📦 Packages"
    printf "===========\n"
    apt_install "alacritty" "ppa:mmstick76/alacritty"
    apt_install "ansible"
    apt_install "curl"
    apt_install "docker"
    apt_install "docker-compose"
    apt_install "fish" "ppa:fish-shell/release-3"
    apt_install "ffmpeg"
    apt_install "fonts-mononoki"
    apt_install "git"
    apt_install "git-lfs"
    apt_install "gnome-tweaks"
    apt_install "gnome-shell-extensions"
    apt_install "htop"
    apt_install "vim"

    snap_install "code" "classic"
    snap_install "intellij-idea-community" "classic"
    snap_install "signal-desktop"
    snap_install "spotify"
    
    if [ $report_only = true ]; then
        exit 0
    fi

    install_iosevka_font
    install_pop_os_shell "node-typescript"

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

main "$@"