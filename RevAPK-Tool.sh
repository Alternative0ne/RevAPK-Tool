#!/bin/bash

reverse_ipa() {
    local ipa_file="$1"

    local temp_dir=$(mktemp -d)

    unzip -q "$ipa_file" -d "$temp_dir" >/dev/null

    local info_plist="$temp_dir/Payload/*.app/Info.plist"

    if [ -f "$info_plist" ]; then
        echo "Info.plist extracted from IPA file:"
        echo "$info_plist"
    else
        echo "Info.plist not found in IPA file"
    fi

    local ipa_source_folder=$(dirname "$ipa_file")
    echo "IPA source directory: $ipa_source_folder"

    rm -rf "$temp_dir"
}

reverse_apk() {
    local apk_file="$1"
    local libname="$2"

    if [[ -n "$libname" ]]; then
        echo "Searching for libraries matching '$libname'"
    fi

    local temp_dir=$(mktemp -d)

    unzip -q -j "$apk_file" "lib/*" -d "$temp_dir" >/dev/null

    local libs
    if [[ -n "$libname" ]]; then
        libs=$(find "$temp_dir" -name "*$libname*.so" -type f)
    else
        libs=$(find "$temp_dir" -name "*.so" -type f)
    fi

    if [[ -z "$libs" ]]; then
        echo "No libraries found"
    else
        echo "Libraries found:"
        echo "$libs"
    fi

    local apk_name=$(basename "$apk_file" .apk)
    local apk_source_folder=$(dirname "$apk_file")
    mkdir -p "$apk_source_folder"

    mv "$temp_dir"/* "$apk_source_folder" >/dev/null

    echo "APK source directory: $apk_source_folder"

    rm -rf "$temp_dir"
}

print_menu() {
    echo "Choose an option:"
    echo "[1] Reverse APK"
    echo "[2] Reverse IPA"
    echo "[3] Exit"
}

while true; do
    echo -e "\n# Made By AlternativeOne <3\n"
    print_menu

    read -rp "## Choose :: " choice

    case $choice in
        1)
            echo -e "\nReverse APK"
            read -rp "Enter APK file path: " apk_file
            reverse_apk "$apk_file"
            ;;
        2)
            echo -e "\nReverse IPA"
            read -rp "Enter IPA file path: " ipa_file
            reverse_ipa "$ipa_file"
            ;;
        3)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Please choose a valid option."
            ;;
    esac
done
