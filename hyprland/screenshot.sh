#!/bin/bash
# region screenshot with annotation, like the windows snipping tool:
# slurp = select region, grim = capture, satty = annotate/copy/save.
# Esc in slurp cancels without capturing.
mkdir -p ~/Pictures
region="$(slurp)" || exit 0
grim -g "$region" - | satty --filename - \
    --output-filename ~/Pictures/screenshot-"$(date +%Y%m%d-%H%M%S)".png \
    --copy-command wl-copy
