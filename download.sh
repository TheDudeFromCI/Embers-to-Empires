#~/bin/bash

# Make sure we passed in a download mode.
if (( $# != 1 )); then
    echo "Unknown number of arguments! Please use as:"
    echo "./download.sh <client|server>"
    exit 1
fi

# Make sure the download mode is a valid option.
if [[ $1 == !(client|server) ]]; then
    echo "Unknown setting '$1'! Please use as:"
    echo "./download.sh <client|server>"
    exit 1
fi

# Download all mods within a mod list.
function download_mods () {
    source ../progress_bar.sh
    enable_trapping
    setup_scroll_area

    file_count=$(sed -n -e '$=' $1)
    files_done=0

    echo "Downloading $file_count mods from $1..."
    while IFS= read -r url; do
        echo "Downloading $url."
        curl -O $url 2>/dev/null
        files_done=$(( files_done + 1 ))
        progress=$(echo "scale=2; $files_done/$file_count*100" | bc -l)
        draw_progress_bar $(echo "$progress/1" | bc)
    done < $1

    destroy_scroll_area
}

# Download all resource packs within a pack list.
function download_resources () {
    source ../progress_bar.sh
    enable_trapping
    setup_scroll_area

    file_count=$(sed -n -e '$=' $1)
    files_done=0

    echo "Downloading $file_count resource packs from $1..."
    while IFS= read -r url; do
        echo "Downloading $url."
        curl -O $url 2>/dev/null
        files_done=$(( files_done + 1 ))
        progress=$(echo "scale=2; $files_done/$file_count*100" | bc -l)
        draw_progress_bar $(echo "$progress/1" | bc)
    done < $1

    destroy_scroll_area
}

# Clear mod folder.
echo "Clearing mod folder, (if exists)"
rm -rf mods 2>/dev/null
mkdir mods
cd mods

# Download the common mods, first.
download_mods "../common-mods.txt"

# Download client mods only in client mode.
if [[ $1 == client ]]; then
    download_mods "../client-mods.txt"
    
    # Clear resource pack folder.
    cd ..
    rm -rf resourcepacks 2>/dev/null
    mkdir resourcepacks
    cd resourcepacks

    download_resources "../client-resourcepacks.txt"
fi

exit 0
