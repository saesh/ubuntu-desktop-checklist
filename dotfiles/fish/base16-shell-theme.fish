#!/usr/bin/fish

function base16-shell-theme --argument-names 'theme' -d 'set shell/fish/fzf base16 theme'
    if test -z $theme
        echo "No base16 theme name given. Exiting."
        return 1
    end

    # scripts to set various themes
    set -l base16_shell base16-$theme
    set -l base16_fish ~/.config/base16-fish/functions/base16-$theme.fish
    set -l base16_fzf ~/.config/base16-fzf/fish/base16-$theme.fish

    # attempt to execute base16-shell theme script
    if type -q $base16_shell
        echo "setting base16-shell theme"
        $base16_shell
    end

    # attempt to set base16-fish theme script
    if test -e $base16_fish
        echo "setting base16-fish theme"
        source $base16_fish
    end

    # attempt to source base16-fzf theme script
    if test -e $base16_fzf
        echo "setting base16-fzf theme"
        source $base16_fzf
    end
end