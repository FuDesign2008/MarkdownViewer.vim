MarkdownViewer.vim
===================
Parse markdown to html and preview it, compatible with [GitHub flavored
markdown](https://help.github.com/articles/github-flavored-markdown).


##Install
1. Install `node.js` and `npm`.
1. Install `marked` and `highlight.js` packages globally
    * `npm install marked -g` or `sudo npm install marked -g`
    * `npm install highlight.js -g` or `sudo npm install highlight.js -g`
1. Set `NODE_PATH` environment variable
    * add `export NODE_PATH=/usr/lib/node_modules:$NODE_PATH` to ` ~/.bash_profile` or `~/.zshrc`
    * See http://stackoverflow.com/questions/13465829/node-js-modules-path for more infomation
1. Copy the `after` folder to `~/.vim`.
1. Ensure you have the line `filetype plugin on` in your `.vimrc`.
1. Open a markdown file in `vim` and execute command `:ViewMkd`. Enjoy it!

##Usage
1. `:ViewMkd`, to preview markdown file. The default key map `<leader>v`
   calls this command.

1. `:M2html`, converting markdown file to html file.  If `g:mdv_html` is `1`,
    the html file will be located in  the directory where the markdown file is in.
    If the value is `0` , the html file will be a temp file that will be shown
    in browser when calling `:ViewMkd` command.

1. `:MailMkd config-name`, send an email with the html content which is from the markdown
   file to someone. This command needs python support and the
   `g:mdv_mail_config` should be set.

##Screenshot
![MarkdownViewer Screenshot](markdown_viewer.png)


##Configuration
1. `g:mdv_loaded`, the plugin has loaded or not.The default value is `0`. If
   you want to prevent loading the plugin, you can set it to `1` in `.vimrc`.

1. `g:mdv_theme` , the theme of html file. The default value is `github2` and
   available values are :
    * `github2`
    * `github`
    * `clear`
    * `clearDark`

1. `g:mdv_html`, save the html file at the directory where the  markdown
   file is in when calling `:ViewMkd` command and/or when saving markdown
   file. The default value is `1`.

1. `g:mdv_highlight_code`, to highlight code or not, default value is `1`. If
   you want to prevent to highlight code, you can set it to `0` in `.vimrc`.

1. `g:mdv_code_theme`, the theme of code in html file. The default value is
   `default`. The possible values are :
    * `arta`
    * `ascetic`
    * `atelier-dune.dark`
    * `atelier-dune.light`
    * `atelier-forest.dark`
    * `atelier-forest.light`
    * `atelier-heath.dark`
    * `atelier-heath.light`
    * `atelier-lakeside.dark`
    * `atelier-lakeside.light`
    * `atelier-seaside.dark`
    * `atelier-seaside.light`
    * `codepen-embed`
    * `color-brewer`
    * `dark`
    * `default`
    * `docco`
    * `far`
    * `foundation`
    * `github`
    * `googlecode`
    * `hybrid`
    * `idea`
    * `ir_black`
    * `kimbie.dark`
    * `kimbie.light`
    * `magula`
    * `mono-blue`
    * `monokai`
    * `monokai_sublime`
    * `obsidian`
    * `paraiso.dark`
    * `paraiso.light`
    * `railscasts`
    * `rainbow`
    * `solarized_dark`
    * `solarized_light`
    * `sunburst`
    * `tomorrow-night-blue`
    * `tomorrow-night-bright`
    * `tomorrow-night-eighties`
    * `tomorrow-night`
    * `tomorrow`
    * `vs`
    * `xcode`
    * `zenburn`

1. `g:mdv_mail_config`, the configuration for `:MailMkd` command. All the
   configuration should be written in `~/mdv_mail_config.vim`. Below is an
   example:

```vimscript

" ~/mdv_mail_config.vim

let g:mdv_mail_config = {}

let g:mdv_mail_config['example'] = {
    \ 'from': 'abc@example.com',
    \ 'to': ['xyz@example.com'],
    \ 'cc': ['mnq@example.com'],
    \ 'server_host': 'smtp.example.com',
    \ 'server_port': 25,
    \ 'login_name': 'abc@example.com',
    \ 'login_pwd': 'the-password'
    \ }

let g:mdv_mail_config['example2'] = {
    \ 'from': 'abc2@example.com',
    \ 'to': ['xyz2@example.com'],
    \ 'cc': [],
    \ 'server_host': 'smtp.example.com',
    \ 'server_port': 25,
    \ 'login_name': 'abc2@example.com',
    \ 'login_pwd': 'the-password-2'
    \ }

```

Then, executing `:MailMkd example` command will use the `example` configuration
to mail the current file content to `xyz@example.com`.

##Change Log
* 2015-05-29
    - add `:MailMkd` command

* 2015-01-15
    - add highlight for code

##Next
1. better image support




