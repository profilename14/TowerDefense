#!/bin/sh

pico8_file="tower_defense.p8"
export_file="ferrous_fight.p8.png"
root_directory=".."
build_directory="${root_directory}/builds/${export_file}"

echo "[START] Exporting files..."
python shrinko8-main/shrinko8.py $root_directory/$pico8_file $build_directory
echo "[COMPLETE] Exporting files..."
