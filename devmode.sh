#!/bin/bash

CONFIG_DIR="$HOME/devmode/config"
SPCK_DIR="/sdcard/android/data/io.spck/files/workspace"
NODE_DIR="/sdcard/android/data/io.spck.editor.node/files/workspace"

mkdir -p "$CONFIG_DIR"

set_new_workspace() {
    echo "Scanning current directory..."
    items=(*)

    echo "Pilih file/folder yang ingin dimasukkan ke workspace:"
    selected=()

    for i in "${!items[@]}"; do
        echo "$((i+1)). ${items[$i]}"
    done

    echo "Ketik nomor yang ingin disertakan, pisahkan dengan spasi (mis: 1 3 5):"
    read -a choices

    for i in "${choices[@]}"; do
        index=$((i-1))
        [ -n "${items[$index]}" ] && selected+=("${items[$index]}")
    done

    echo "Name for workspace..."
    read workspace_name

    ws_path=$(pwd)
    mkdir -p "$SPCK_DIR/$workspace_name"

    for item in "${selected[@]}"; do
        cp -r "$item" "$SPCK_DIR/$workspace_name/" 2>/dev/null
    done

    json_content=$(jq -n \
        --arg name "$workspace_name" \
        --arg dir "$ws_path" \
        --argjson files "$(printf '%s\n' "${selected[@]}" | jq -R . | jq -s .)" \
        '{name: $name, dir: $dir, files: $files}')

    echo "$json_content" > "$CONFIG_DIR/$workspace_name.json"
    echo "Workspace '$workspace_name' saved."
}

run_workspace() {
    echo "Available workspaces:"
    files=("$CONFIG_DIR"/*.json)
    select ws_file in "${files[@]}"; do
        [ -n "$ws_file" ] && break
    done

    echo "Pilih editor:"
    echo "1) spck editor"
    echo "2) spck editor for nodejs"
    read editor_choice

    editor_dir="$SPCK_DIR"
    [ "$editor_choice" = "2" ] && editor_dir="$NODE_DIR"

    name=$(jq -r .name "$ws_file")
    dir=$(jq -r .dir "$ws_file")
    files=$(jq -r .files[] "$ws_file")

    mkdir -p "$editor_dir/$name"
    cd "$editor_dir/$name" || exit

    echo "Menyalin file ke SPCK..."
    for file in $files; do
        cp -r "$dir/$file" "$editor_dir/$name/" 2>/dev/null
    done

    # Buat filter file sementara
    filter_file="$HOME/.devmode_filter"
    echo "# protect generated and config files" > "$filter_file"
    echo "- .next/" >> "$filter_file"
    echo "- node_modules/" >> "$filter_file"
    echo "- .git/" >> "$filter_file"
    echo "- .vscode/" >> "$filter_file"
    echo "- *.log" >> "$filter_file"
    echo "+ *" >> "$filter_file"

    # Cleanup if Ctrl+C
    cleanup() {
        echo -e "\nCleaning up copied files..."
        for file in $files; do
            rm -rf "$editor_dir/$name/$file"
        done
        exit
    }
    trap cleanup INT

    echo "Running sync loop (1s)... Ctrl+C to stop"

    while true; do
        rsync -a --filter="merge $filter_file" "$editor_dir/$name/" "$dir/" 2>/dev/null
        sleep 1
    done
}

case "$1" in
    set-new-workspace) set_new_workspace ;;
    run) run_workspace ;;
    *) echo "Usage: ~/devmode.sh {set-new-workspace|run}" ;;
esac
