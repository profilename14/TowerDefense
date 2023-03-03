#!/bin/sh

pico8_file="output_tower_defense"
pico8_file_output="tower_defense.p8"
root_directory=".."

# Preprocess the lua files
echo "[START] Preprocessing and Stitching Files..."
python main.py $root_directory $pico8_file main.lua
echo "[COMPLETE] Preprocessing and Stitching Files..."
echo ""
# Mimify
echo "[START] Mimifying pico file..."
python shrinko8-main/shrinko8.py $root_directory/$pico8_file $root_directory/$pico8_file_output --minify --preserve "*,*.*"
echo "[COMPLETE] Mimifying pico file..."