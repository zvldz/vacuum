#!/bin/bash
# Adding keybinding for bash

LIST_CUSTUM_FUNCTION+=("custom_function_binding")

function custom_function_binding()
{
    echo "+ Adding keybinding for bash"
    cat << EOF > $IMG_DIR/etc/profile.d/binding.sh
#!/bin/sh
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

stty werase undef
bind '"\C-w": backward-kill-word'

alias vim=vi
EOF
    chmod +x $IMG_DIR/etc/profile.d/binding.sh
}
