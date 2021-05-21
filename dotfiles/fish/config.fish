set fish_greeting

set -Ux EDITOR vim

# enhancd settings
set -Ux ENHANCD_HOOK_AFTER_CD "la"
set -Ux ENHANCD_DISABLE_HOME 1

# Base16 Shell
if status --is-interactive
    set BASE16_SHELL "$HOME/.config/base16-shell/"
    source "$BASE16_SHELL/profile_helper.fish"
end

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
abbr tf "terraform"
abbr tfa "terraform apply"
abbr tfr "terraform refresh"
abbr tfp "terraform plan"

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
set -U fish_user_paths $fish_user_paths $HOME/.local/bin

# go
set -U fish_user_paths $fish_user_paths /usr/local/go/bin
set -U fish_user_paths $fish_user_paths $HOME/go/bin
set -U fish_user_paths $fish_user_paths /usr/local/protobuf/bin

# starship prompt
if type -sq starship
    starship init fish | source
end
