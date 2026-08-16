# GIF shell — fish engine entry (isolated XDG_CONFIG_HOME).
# Your normal ~/.config/fish is NOT loaded here.

if not set -q GIF_ROOT; or not test -d "$GIF_ROOT/functions"
    set -gx GIF_ROOT (dirname (dirname (dirname (status filename))))
end
if not test -d "$GIF_ROOT/functions"
    set -gx GIF_ROOT "$HOME/.config/gif"
end

set -gx GIF_CONFIG_DIR "$GIF_ROOT"
set -gx GIF_DATA_DIR "$HOME/.local/share/gif"
set -gx GIF_SHELL 1
set -gx SHELL_NAME GIF
mkdir -p $GIF_CONFIG_DIR $GIF_DATA_DIR

for f in $GIF_ROOT/conf.d/*.gifsh
    source $f
end
for f in $GIF_ROOT/functions/*.gifsh
    source $f
end

if functions -q __gif_boot_appearance
    __gif_boot_appearance
end
