"
" previewMarkdown.vim
"
"the hortcut key is: <leader>p
"
" You can config `g:markdown_preview_app`  to let which app to preview markdown file
"
"



if &cp || exists("g:preview_markdown")
    finish
endif
let g:preview_markdown = 1
let s:save_cpo = &cpo
set cpo&vim

if !exists('g:markdown_preview_app')
    let g:markdown_preview_app = 'Mou.app'
endif

function! PreviewMarkdown()
    let cmd = "silent !open -a /Applications/" . g:preview_app . " '%:p'"
    execute cmd
endfunction

autocmd FileType markdown nnoremap <buffer> <leader>p :call PreviewMarkdown()<CR>

let &cpo = s:save_cpo
