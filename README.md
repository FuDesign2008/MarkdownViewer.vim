MarkdownViewer.vim
===================
Parse markdown to html and preview it, compatible with [GitHub flavored
markdown](https://help.github.com/articles/github-flavored-markdown).


##Install
1. Install `node.js` and `npm`.
1. Install `marked` globally, `npm install marked -g` or `sudo npm install
   marked -g`.
1. Copy the `after` folder to `~/.vim`.
1. Ensure you have the line `filetype plugin on` in your `.vimrc`.
1. Open a markdown file in vim and enjoy!

##Config Options
1. `g:mdv_loaded`, the plugin has loaded or not.The default value is `0`. If
   you want to prevent loading the plugin, you can set it to `1` in `.vimrc`.

1. `g:mdv_theme` , the theme of html file. The default value is `github2` and
   available value are `github2`, `github`, `clear` and `clearDark`.

1. `g:mdv_html`, save the html file at the directory where the  markdown
   file is in when calling `:ViewMkd` command and/or when saving mardown
   file. The default value is `1`.


##Usage
1. `:ViewMkd`, to preview markdown file. The default key map `<leader>v`
   calls this command.

1. `:M2html`, converting markdown file to html file.  If `g:mdv_html` is `1`,
    the html file will be located in  the directory where the markdown file is in.
    If the value is `0` , the html file will be a temp file that will be shown
    in browser when calling `:ViewMkd` command.

##Screenshot
![MarkdownViewer Screenshot](markdown_viewer.png)

##Next
1. add highlight for code

```js
var hello = "Hello";
console.log(hello);
```



