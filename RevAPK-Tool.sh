#!/bin/bash

reverse_ipa() {
    local ipa_file="$1"

    local info_plist=$(unzip -q -c "$ipa_file" "Payload/*.app/Info.plist")

    echo "🔍 Analyzing IPA..."
    echo "-----------------------"

    echo "📱 App Transport Security (ATS)"
    if grep -q "<key>NSAppTransportSecurity</key><dict>" <<< "$info_plist"; then
        echo "✅ ATS Enabled" 
    else
        echo "❌ ATS not enabled"
    fi

    echo -e "\n🔗 URLs"
    grep -o 'https\?://[^"]*' <<< "$info_plist"

    echo -e "\n🔑 API keys and secrets"
    grep -oE '[0-9a-fA-F]{32,}|&amp;[a-zA-Z0-9@^]+' <<< "$info_plist" | sort -u

    echo -e "\n🛡️ App Permissions"
    local permissions=("NSPhotoLibraryUsageDescription" "NSLocationWhenInUseUsageDescription" "NSLocationUsageDescription" "NSLocationAlwaysUsageDescription" "NSContactsUsageDescription" "NSCalendarsUsageDescription" "NSCameraUsageDescription")
    
    for permission in "${permissions[@]}"; do
        local description=$(grep -A1 "<key>$permission</key>" <<< "$info_plist" | grep -v "<key>$permission</key>" | grep -oP '(?<=<string>).*?(?=</string>)' | sed -e 's/^[[:space:]]*//' -e '/^$/d' | sed -e ':a;N;$!ba;s/\n/ /g')
        if [ -n "$description" ]; then
            echo "🔒 $permission: $description"
        fi
    done
    echo "-----------------------"
}
reverse_apk() {
    local apk_file="$1"
    local libname="$2"

    if [[ -n "$libname" ]]; then
        echo "Searching for libraries matching '$libname' 🔍"
    fi

    local temp_dir=$(mktemp -d)

    unzip -q -j "$apk_file" "lib/*" -d "$temp_dir" >/dev/null

    local libs_count
    if [[ -n "$libname" ]]; then
        libs_count=$(find "$temp_dir" -name "*$libname*.so" -type f | wc -l)
    else
        libs_count=$(find "$temp_dir" -name "*.so" -type f | wc -l)
    fi

    if [[ "$libs_count" -eq 0 ]]; then
        echo "No libraries found ❌"
    else
        echo "Number of libraries found: $libs_count"
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
    echo "[1] Reverse APK 🔄"
    echo "[2] Reverse IPA 🔄"
    echo "[3] Exit 🚪"
}

while true; do
    echo -e "\n# Made By AlternativeOne ❤️\n"
    print_menu

    read -rp "## Choose :: " choice

    case $choice in
        1)
            echo -e "\nReverse APK 🔄"
            read -rp "Enter APK file path: " apk_file
            if [[ ! -f "$apk_file" ]]; then
                echo "Error: Invalid APK file path ❌"
                continue
            fi
            reverse_apk "$apk_file"
            ;;
        2)
            echo -e "\nReverse IPA 🔄"
            read -rp "Enter IPA file path: " ipa_file
            if [[ ! -f "$ipa_file" ]]; then
                echo "Error: Invalid IPA file path ❌"
                continue
            fi
            reverse_ipa "$ipa_file"
            ;;
        3)
            echo "Exiting... 🚪"
            exit 0
            ;;
        *)
            echo "Not a Option ❌"
            ;;
    esac
done
