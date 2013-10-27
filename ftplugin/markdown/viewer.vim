"
" preview.vim  in ftplugin/markdown/
"
" Providing `:MdView` command.
"
"


if &cp || exists('g:mdv_loaded')
    finish
endif
let g:mdv_loaded = 1
let s:save_cpo = &cpo
set cpo&vim

let s:scriptPath = expand('<sfile>:hp')
let s:defaultTheme = 'github2'
let s:theme = 'github2'

if exists('g:mdv_theme')
    let s:theme = g:mdv_theme
endif

function! s:OpenFile(filePath)
    if has('mac')
        "let cmd = 'silent !open "' . a:filePath  . '"'
        let cmd = 'open "' . a:filePath  . '"'
    elseif has('win32') || has('win64') || has('win95') || has('win16')
        "let cmd = '!cmd /c start "' . a:filePath . '"'
        let cmd = '/c start "' . a:filePath . '"'
    endif
    "execute cmd
    call system(cmd)
endfunction

" reuturn {String}
function s:ReadFile(file, spliter)
    let filePath = s:scriptPath . a:file
    if filereadable(filePath)
        return join(readfile(filePath, 'b'), a:spliter)
    endif
    return ''
endfunction
"
"@param {String} theme
"@param {String} content
"@return {List}
function s:Convert2Html(theme, content)
    let html = s:ReadFile('/bone.html', '')
    let style = s:ReadFile('/' . a:theme . '.css', '\n')
    if len(style) < 1
        let style = s:ReadFile('/' . s:defaultTheme . '.css', '\n')
    endif
    "echo html
    "echo style
    let html  = substitute(html, '<%=style%>', style, '')
    let html  = substitute(html, '<%=title%>', 'title', '')
    let html  = substitute(html, '<%=content%>', a:content, '')
    "echo  html
    return split(html, '\n')
endfunction

function! s:ViewMarkDown()
    "let text = join(getline(1, '$'), '\n')
    "echomsg 'text......'
    "echomsg text
    let parsed = system('marked  --input ' . shellescape(expand('%:p')))
    "echo type(parsed)
    let html = s:Convert2Html(s:theme, parsed)
    let fileName = expand('%p') . '.html'
    call writefile(html, fileName, '')
    call s:OpenFile(fileName)
endfunction


command -nargs=0 ViewMd call s:ViewMarkDown()


let &cpo = s:save_cpo
