"
" previewMarkdown.vim
"
"the hortcut key is: <leader>p
"
" You can config `g:markdown_preview_app`  to let which app to preview markdown file
"
"



if &cp || exists('g:preview_markdown_loaded')
    finish
endif
let g:preview_markdown_loaded = 1
let s:save_cpo = &cpo
set cpo&vim

if !exists('g:markdown_preview_app')
    let g:markdown_preview_app = 0
endif

function! PreviewMarkdown()
    if !g:markdown_preview_app
        echomsg 'g:markdown_preview_app has NO config!'
        return
    endif

    if has('mac')
        let cmd = 'silent !open -a ' . g:markdown_preview_app . ' "%:p"'
    elseif has('win32') || has('win64') || has('win95') || has('win16')
        let cmd = '!cmd /c start /b' . g:markdown_preview_app . ' "%:p"'
    endif
    execute cmd
endfunction

autocmd FileType markdown nnoremap <buffer> <leader>p :call PreviewMarkdown()<CR>

let &cpo = s:save_cpo
