#!/bin/sh

set -e

apt_install_command="sudo apt-get -qq -y install"
snap_install_command="snap install"
prefix_question="🤖"
prefix_done="✅"
prefix_skipped="⏭ "
prefix_warning="🟡"

apt_install() {
    package_name=$1
    echo "$prefix_question Install '$package_name'?"
    read -r response
    case $response in
    [yY])
        eval $apt_install_command $package_name
        return_code=$?
        if [ "$return_code" -eq "0" ]; then
            echo "$prefix_done $package_name installed"
        else 
            echo "$prefix_warning $package_name could not be installed"
        fi
        ;;
    *)
        echo "$prefix_skipped $package_name installation skipped"
        ;;
    esac
    echo
}

snap_install() {
    package_name=$1
    is_classic="$2"
    echo "$prefix_question Install '$package_name'?"
    read -r response
    case $response in
    [yY])
        if [ "is_classic" -eq "classic" ]; then
            eval $snap_install_command $package_name --classic
        else
            eval $snap_install_command $package_name
        fi 
        return_code=$?
        if [ "$return_code" -eq "0" ]; then
            echo "$prefix_done $package_name installed"
        else 
            echo "$prefix_warning $package_name could not be installed"
        fi
        ;;
    *)
        echo "$prefix_skipped $package_name installation skipped"
        ;;
    esac
    echo
}

setting() {
    question=$1
    activation_command=$2
    echo "$prefix_question $question"
    read -r response
    case $response in
    [yY])
        eval $activation_command
        return_code=$?
        if [ "$return_code" -eq "0" ]; then
            echo "$prefix_done Done"
        else 
            echo "$prefix_warning Something went wrong"
        fi
        ;;
    *)
        echo "$prefix_skipped Skipped"
        ;;
    esac
    echo
}

main() {
    echo "======================="
    echo "📦 Package installation"
    echo "=======================\n"
    apt_install "ansible"
    apt_install "curl"
    apt_install "docker"
    apt_install "docker-compose"
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
    
    echo

    echo "======================="
    echo "🎛  System settings"
    echo "=======================\n"
    setting "Show all input sources in gnome settings?\n(Required for Eurkey to show up)" "gsettings set org.gnome.desktop.input-sources show-all-sources true"
    setting "Hide the dock?" "gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false"
    setting "Set system clock to local time?\n(Required for correct time in Windows in dual-boot environment)" "timedatectl set-local-rtc 1 --adjust-system-clock"

    echo

    echo "📝 Please logout and back in and perform these steps:"
    echo
    echo "- set Eurkey in keyboard settings"
}

main