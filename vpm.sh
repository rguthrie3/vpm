#!/bin/sh

function usage() {
    echo "Vim Package Manager
    usage: vpm action [action-args]

    For specific help about an action, do
    $ vpm action help

    Actions:
    list              : List all installed packages
    install           : Install a package
    remove            : Remove a package
    update            : Update a package (if no args follow, update all packages)
    install-from-file : Install all packages listed in a file"
}

function list_packages_help() {
    echo "Vim Package Manager

    list : Lists all packages currently installed.
    Change which directory to search for plugins in by setting $$PLUGIN_DIR in the .vpmrc.
    By default it lists the plugins in ~/.vim/bundle"
}

function install_packages_help() {
    echo "Vim Package Manager

    Installs the packages that are listed as arguments following \"install\".

    These strings will be concatenated with $$DOWNLOAD_URL_BASE, which can be set in the .vpmrc.
    The default is https://github.com.

    They will be downloaded to $$PLUGIN_DIR (default ~/.vim/bundle)

    The download location will be saved in $$PLUGIN_DATA_FILE

    Example usage:
    $ vpm install tpope/vim-obsession tpope/vim-fugitive
    clones https://github.com/tpope/vim-obsession into $$PLUGIN_DIR"
}

function remove_packages_help() {
    echo "Vim Package Manager

    Removes the packages that are listed as arguments following \"remove\".

    Unlike with install, you don't need to supply anything except the directory name (e.g no GitHub username is needed).
    The directory $$PLUGIN_DIR/<arg> will be deleted.

    Also, if an entry for the removed package is in $$PLUGIN_DATA_FILE, it will be removed

    Example usage:
    $ vpm remove vim-obsession vim-fugitive"
}

function update_packages_help() {
    echo "Vim Package Manager

    Updates all packages that are found in $$PLUGIN_DIR

    In the future, this should take as argument specific plugins to update, and update all plugins if no args are supplied"
}

function install_from_file() {
    echo "Vim Package Manager

    Installs all of the plugins listed in the file passed as an argument.
    The file should have entries formatted as <plugin-name> : <download-url>
    The spaces before and after the colon are required.
    
    vpm will keep track of your plugins and their download locations in $$PLUGIN_DATA_FILE (default ~/.vim/vpm.txt)
    so that if you want to download your plugins to a new machine, you only need to copy that file to your new machine and run
    this command.

    Example usage:
    $ vpm install-from-file ~/.vim/vpm.txt"
}

function bootstrap_help() {
    echo "Vim Package Manager: bootstrap

    When first running vpm, it doesn't know where the plugins you already have were downloaded from.
    It assumes that they were downloaded from a git repo.

    bootstrap searches $$PLUGIN_DIR for each installed plugin, and checks where it was installed from, storing it in the
    $$PLUGIN_DATA_FILE.  This file just stores the names of plugins and where they were downloaded from, so that your plugins can easily
    be installed on another machine with the install-from-file command."
}

function list_packages() {
    ls $PLUGIN_DIR
}

function install_packages() {
    local packages_arr=($@)
    local len=$(expr $# - 1)
    for i in `seq 1 $len`; do
        local package=${packages_arr[$i]}
        local package_name=$(echo $package | sed 's/.*\/\(.*\)/\1/g')
        echo "Installing package from ${DOWNLOAD_URL_BASE}/$package into ${PLUGIN_DIR}/$package_name"
        git clone ${DOWNLOAD_URL_BASE}/$package ${PLUGIN_DIR}/$package_name
        echo "$package_name : ${DOWNLOAD_URL_BASE}/$package" >> ${PLUGIN_DATA_FILE}
    done
}

function remove_packages() {
    local packages_arr=($@)
    local len=$(expr $# - 1)
    for i in `seq 1 $len`; do
        local package_name=${packages_arr[$i]}
        echo "Removing ${PLUGIN_DIR}/$package_name"
        rm -r ${PLUGIN_DIR}/$package_name

        # Remove this plugin from the data file
        local tmpfile=$(mktemp)
        grep -v "$package_name" ${PLUGIN_DATA_FILE} > $tmpfile
        mv $tmpfile ${PLUGIN_DATA_FILE}
    done
}

function update_packages() {
    for dir in $(ls $PLUGIN_DIR); do
        cd $PLUGIN_DIR/$dir && git pull origin master
    done
}

function install_from_file() {
    local urls=$(sed 's/^\(.*\) : \(.*\)$/\1==DOWNLOAD-FROM==\2/g' $PLUGIN_DATA_FILE)
    urls=($urls)
    local len=$(expr ${#urls[@]} - 1)
    for i in `seq 0 $len`; do
        local name=$(echo ${urls[$i]} | sed 's/\(.*\)==DOWNLOAD-FROM==.*/\1/g')
        local url=$(echo ${urls[$i]} | sed 's/.*==DOWNLOAD-FROM==\(.*\)/\1/g')
        git clone $url $PLUGIN_DIR/$name
    done
}

function bootstrap() {
    local tmpfile=$(mktemp)
    for dir in $(ls $PLUGIN_DIR); do
        local url=$(cd $PLUGIN_DIR/$dir && git remote get-url origin)
        echo "$dir : $url" >> $tmpfile
    done
    mv $tmpfile $PLUGIN_DATA_FILE
}

function main() {
    if [ $# -eq 0 ]; then
        usage
        exit 0
    fi
    
    PLUGIN_DIR="$HOME/.vim/bundle"
    DOWNLOAD_URL_BASE="https://github.com"
    PLUGIN_DATA_FILE="$HOME/.vim/vpm.txt"

    if [ -f "~/.vpmrc" ]; then
        source ~/.vpmrc
    fi
    
    if [ "$2" = help ]; then
        case "$1" in
        "list")
            list_packages_help
            ;;
        "install")
            install_packages_help
            ;;
        "update")
            update_packages_help
            ;;
        "remove")
            remove_packages_help
            ;;
        "install-from-file")
            install_from_file_help
            ;;
        "bootstrap")
            bootstrap_help
            ;;
        *)
            usage
        esac
    else
        case "$1" in
            "list")
                list_packages
                ;;
            "install")
                install_packages
                ;;
            "update")
                update_packages
                ;;
            "remove")
                remove_packages
                ;;
            "install-from-file")
                install_from_file
                ;;
            "bootstrap")
                bootstrap
                ;;
            *)
                usage
        esac
    fi


    exit 0
}

main $@
