MarkdownViewer.vim
===================
Parse markdown to html and preview it.


##Install
1. Install `node.js` and `npm`.
1. Install `marked` globally, `npm install marked -g` or `sudo install maked -g`.
1. Copy the `after` folder to `~/.vim`.
1. Ensure you have the line `filetype plugin on` in your `.vimrc`.
1. Open a markdown file in vim and enjoy!

##Config Options
1. `g:mdv_loaded`, the plugin has loaded or not.The default value is `0`. If
   you want to prevent loading the plugin, you can set it to `1` in `.vimrc`.

1. `g:mdv_theme` , the theme of html file. The default value is `github2` and
   available value are `github2`, `github`, `clear` and `clearDark`.

1. `g:mdv_sav_html`, when previewing, save the html file at the directory which
   the  markdown file is in. The default value is `1`.

1. `g:mdv_auto_view`, when saving markdown file, automatically preview the file
   or not. The default value is `1`.

1. `g:mdv_custom_key`, custom shortcut to run `:ViewMarkdown` command or not.
   The default is `0`, and the  shortcut is `<leader>v`.



##Usage
1. `:ViewMarkdown`, to preview markdown file.
1. `<leader>v`, the default keymap for executing `:ViewMarkdown` command.




