# vpm
This is a small shell script to make managing plugins for Vim less of a headache.
The help text should explain the different functionality.

A couple of variables can be set in a .vpmrc, which is then sourced.
These variables include

* PLUGIN_DIR where plugins can be found (default ~/.vim/bundle)
* DOWNLOAD_URL_BASE where plugins can be downloaded (default https://github.com)
* PLUGIN_DATA_FILE where vpm will store the information about your installed plugins (default ~/.vim/vpm.txt)

The nice thing about the PLUGIN_DATA_FILE is that it will store the download url for each plugin you install.
You can then use the install-from-file command to download all of your plugins on a different machine.
Plugins removed and installed to vpm will be removed / added to this file as expected.

To initialize this file for plugins you already have installed, run the bootstrap command.
