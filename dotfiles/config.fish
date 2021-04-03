set fish_greeting

set -Ux EDITOR vim

# enhancd settings
#set -Ux ENHANCD_HOOK_AFTER_CD "la"
# Base16 Shell
if status --is-interactive
    set BASE16_SHELL "$HOME/.config/base16-shell/"
    source "$BASE16_SHELL/profile_helper.fish"
end

# FZF key bindings
if type -q fzf_key_bindings
   fzf_key_bindings
end

# load local fish config
if test -e ~/.config/fish/local.config.fish
    source ~/.config/fish/local.config.fish
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

# aliases
if type -q 'youtube-dl'
    alias youtube-dl='/usr/bin/python3 /usr/local/bin/youtube-dl'
end

# exa, ls alternative
if type -sq exa
    alias ls='exa'
end

# functions
#function vf
#    command fzf | xargs -o $EDITOR
#end

# set PATH
# used by epr (terminal epub reader)
set PATH ~/.local/bin $PATH
# texlive
#set PATH /usr/local/texlive/2020/bin/x86_64-linux $PATH
#set INFOPATH /usr/local/texlive/2020/texmf-dist/doc/info $INFOPATH

# MANPATH
#set -gx MANPATH (manpath | string split :)
#set -gx MANPATH /usr/local/texlive/2020/texmf-dist/doc/man $MANPATH ":"

set PATH /usr/local/go/bin $PATH
