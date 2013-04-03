PreviewMarkdown.vim
===================

Preview the markdown file with installed app.
You can config `g:markdown_preview_app` in `.vimrc`.
For example, we config Mou.app to preview markdown on Mac OS X.

```vim
let g:markdown_preview_app = '/Applications/Mou.app'
```
We can config different preview apps for different platforms.

```vim
if has('win32')
    let g:markdown_preview_app = 'C:/Program Files/MarkdownPad 2/MarkdownPad2.exe'
elseif has('win64')
    let g:markdown_preview_app = 'D:/Program Files/MarkdownPad 2/MarkdownPad2.exe'
elseif has('mac')
    let g:markdown_preview_app = '/Applications/Mou.app'
endif
```

