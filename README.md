MarkdownViewer.vim
===================
Parse markdown to html and preview it, compatible with [GitHub flavored
markdown](https://help.github.com/articles/github-flavored-markdown).


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

1. `g:mdv_save_html`, save the html file at the directory which the  markdown
   file is in. The default value is `1`.

1. `g:mdv_auto_save`, If html will be saved, this option will save the html
   automatically when saving the markdown file.  The default value is `1`.


##Usage
1. `:ViewMarkdown`, to preview markdown file. The default key map `<leader>v`
   calls this command.
1. `:Save2Html`, saving html under the directory which the markdown file is in
   only if `g:mdv_save_html` is `1`. If `g:mdv_auto_save` is `1`, the pluin
   will save html file automatically when saving markdown file.

##Next
1. add highlight for code



