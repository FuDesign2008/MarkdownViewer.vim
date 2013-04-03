"
" preview.vim  in ftplugin/markdown/
"
" Providing `:PreviewMarkdown` command.
" You can config `g:markdown_preview_app` to let which app to preview markdown file.
" Now, the plugin only supports Mac OS X, Windows.
"
"
"



if &cp || exists('g:preview_markdown_loaded')
    finish
endif
let g:preview_markdown_loaded = 1
let s:save_cpo = &cpo
set cpo&vim

if !exists('g:markdown_preview_app')
    let g:markdown_preview_app = ''
endif

function! s:PreviewMarkdown()
    echomsg 'g:markdown_preview_app: ' . g:markdown_preview_app
    if strlen(g:markdown_preview_app) == 0
        echomsg 'g:markdown_preview_app has NO config!'
        return
    endif

    if has('mac')
        let cmd = 'silent !open -a "' . g:markdown_preview_app . '" "%:p"'
    elseif has('win32') || has('win64') || has('win95') || has('win16')
        let cmd = '!cmd /c start /b "' . g:markdown_preview_app . '" "%:p"'
    endif
    execute cmd
endfunction

command -nargs=0 PreviewMarkdown call s:PreviewMarkdown(<f-args>)


let &cpo = s:save_cpo
