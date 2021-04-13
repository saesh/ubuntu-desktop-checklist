function wttr -d 'show the weather using wttr.in'
    if set -q "$argv[1]"
        set -l location = $argv[1]
    else
        set -l location = "Berlin"
    end

    curl https://wttr.in/"$location?0&q"
end