set fish_greeting

set -Ux EDITOR vim

# enhancd settings
set -Ux ENHANCD_HOOK_AFTER_CD "la"
set -Ux ENHANCD_DISABLE_HOME 1

# FZF key bindings
if type -q fzf_key_bindings
   fzf_key_bindings
end

# use bat for colored man pages
if type -sq bat
    set -x MANPAGER "fish -c 'col -bx | bat -l man -p'"
end

# abbreviations
abbr v "$EDITOR"
abbr vd "$EDITOR ~/did.txt"
abbr vw "vim -c VimwikiIndex"
abbr ytd "youtube-dl"
abbr uu "sudo apt update && sudo apt upgrade && sudo apt autoremove && sudo apt autoclean"

# aliases
if type -q 'youtube-dl'
    alias youtube-dl='/usr/bin/python3 /usr/local/bin/youtube-dl'
end

# exa, ls alternative
if type -sq exa
    alias ls='exa'
    alias ll='exa --long --git'
    alias la='exa --all --long --git'
end

# functions
function vf
    command fzf | xargs -o $EDITOR
end

# load local fish config
if test -e ~/.config/fish/local.config.fish
    source ~/.config/fish/local.config.fish
end

# PATHS
fish_add_path $HOME/.local/bin

# go
fish_add_path /usr/local/go/bin
fish_add_path $HOME/go/bin

# starship prompt
if type -sq starship
    starship init fish | source
end
