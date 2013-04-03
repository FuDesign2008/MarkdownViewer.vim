PreviewMarkdown.vim
===================

Providing command `:PreviewMarkdown` to preview the markdown file with
installed app.


##Config Options
You can config `g:markdown_preview_app` in `.vimrc`.  For example, we config
`/Applications/Mou.app` to preview markdown on Mac OS X.

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
##Mapping Shortcut
You can add shortcut at `.vimrc`. Taking mapping `<leader>p` for example:

```vim
autocmd FileType markdown nnoremap <buffer> <slient> <leader>p :PreviewMarkdown<CR>
```


