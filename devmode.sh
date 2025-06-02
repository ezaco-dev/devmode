#!/bin/bash

CONFIG_DIR="$HOME/devmode/config"
SPCK_DIR="/sdcard/android/data/io.spck/files/"
NODE_DIR="/sdcard/android/data/io.spck.editor.node/files/"
ACODE_DIR="/sdcard/acode/"

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

    echo "Pilih editor default untuk workspace ini:"
    echo "1) SPCK"
    echo "2) SPCK Node.js"
    echo "3) Acode (Di sarankan untuk android 11 ke atas)"
    read editor_choice

    case "$editor_choice" in
        1) editor_dir="$SPCK_DIR" ;;
        2) editor_dir="$NODE_DIR" ;;
        3) editor_dir="$ACODE_DIR" ;;
        *) echo "Pilihan tidak valid. Default ke SPCK."; editor_dir="$SPCK_DIR" ;;
    esac

    mkdir -p "$editor_dir/$workspace_name"

    for item in "${selected[@]}"; do
        cp -r "$item" "$editor_dir/$workspace_name/" 2>/dev/null
    done

    json_content=$(jq -n \
        --arg name "$workspace_name" \
        --arg dir "$ws_path" \
        --arg editor "$editor_dir" \
        --argjson files "$(printf '%s\n' "${selected[@]}" | jq -R . | jq -s .)" \
        '{name: $name, dir: $dir, editor: $editor, files: $files}')

    echo "$json_content" > "$CONFIG_DIR/$workspace_name.json"
    echo "Workspace '$workspace_name' saved."
}

run_workspace() {
    echo "Available workspaces:"
    files=("$CONFIG_DIR"/*.json)
    select ws_file in "${files[@]}"; do
        [ -n "$ws_file" ] && break
    done

    name=$(jq -r .name "$ws_file")
    dir=$(jq -r .dir "$ws_file")
    files=$(jq -r .files[] "$ws_file")
    editor_dir=$(jq -r .editor "$ws_file")

    mkdir -p "$editor_dir/$name"
    cd "$editor_dir/$name" || exit

    echo "Menyalin file ke editor..."
    for file in $files; do
        cp -r "$dir/$file" "$editor_dir/$name/" 2>/dev/null
    done

    filter_file="$HOME/.devmode_filter"
    echo "# protect generated and config files" > "$filter_file"
    echo "- .next/" >> "$filter_file"
    echo "- node_modules/" >> "$filter_file"
    echo "- .git/" >> "$filter_file"
    echo "- .vscode/" >> "$filter_file"
    echo "- *.log" >> "$filter_file"
    echo "+ *" >> "$filter_file"

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
        rsync -a --delete --filter="merge $filter_file" "$editor_dir/$name/" "$dir/" 2>/dev/null
        sleep 1
    done
}

delete_workspace() {
    echo "Daftar workspace:"
    files=("$CONFIG_DIR"/*.json)
    for i in "${!files[@]}"; do
        fname=$(basename "${files[$i]}")
        echo "$((i+1)). $fname"
    done

    echo "Pilih workspace yang ingin dihapus (contoh: 1 2 4):"
    read -a del_choice

    for idx in "${del_choice[@]}"; do
        json="${files[$((idx-1))]}"
        [ -f "$json" ] || continue

        name=$(jq -r .name "$json")
        editor_dir=$(jq -r .editor "$json")

        echo "Menghapus workspace '$name'..."
        rm -rf "$editor_dir/$name"
        rm -f "$json"
    done

    echo "Workspace terhapus."
}

case "$1" in
    set-new-workspace) set_new_workspace ;;
    set) set_new_workspace;;
    run) run_workspace ;;
    remove-workspace) delete_workspace ;;
    rm) delete_workspace ;;
    *) echo "Gunakan command devmode 
    {set-new-workspace | run | delete-workspace}
    MENJALANKAN run...
    Pilih Workspace..." & run_workspace;;
esac
