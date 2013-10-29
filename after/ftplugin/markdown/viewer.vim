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

let s:savHtml = 1
if exists('g:mdv_sav_html')
    let s:savHtml = g:mdv_sav_html
endif

let s:autoView = 0
if exists('g:mdv_auto_view')
    let s:autoView = g:mdv_auto_view
endif

let s:customKey = 0
if exists('g:mdv_custom_key')
    let s:customKey = g:mdv_custom_key
endif

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
" @param {String} html
" @return {String}
"
function s:GetTitle(html)
    let matched = matchstr(a:html, '<h1[^>]\+>[^<]\+</h1>')
    if matched == ''
        let matched = matchstr(a:html, '<h1>[^<]\+</h1>')
    endif
    if matched == ''
        return ''
    endif
    let gtIndex = stridx(matched, '>')
    let ltIndexRight = strridx(matched, '<')
    return strpart(matched, gtIndex + 1, ltIndexRight - gtIndex - 1)
endfunction
"
"@param {String} theme
"@param {String} content
"@return {List}
function s:Convert2Html(theme, content)
    let title = s:GetTitle(a:content)
    let html = s:ReadFile('/bone.html', '')
    let style = s:ReadFile('/' . a:theme . '.css', '\n')
    if len(style) < 1
        let style = s:ReadFile('/' . s:defaultTheme . '.css', '\n')
    endif
    "echo html
    "echo style
    let html  = substitute(html, '{{style}}', style, '')
    let html  = substitute(html, '{{title}}', title, '')
    let html  = substitute(html, '{{content}}', escape(a:content, ' &'), '')
    "echo  html
    return split(html, '\n')
    "return split(a:content, '\n')
endfunction


function! s:ViewMarkDown()
    let text = getline(1, '$')
    let tempMarkdown = tempname()
    call writefile(text, tempMarkdown, '')
    "echomsg text
    let parsed = system('marked  --input ' . shellescape(tempMarkdown))
    "echo type(parsed)
    let html = s:Convert2Html(s:theme, parsed)
    if s:savHtml
        let fileName = expand('%p') . '.html'
    else
        let fileName = tempname()
    endif
    call writefile(html, fileName, '')
    call s:OpenFile(fileName)
endfunction

command -nargs=0 ViewMarkDown call s:ViewMarkDown()

if s:autoView
    autocmd BufWritePost <buffer>  :ViewMarkDown
endif

if !s:customKey
    noremap <buffer> <leader>v :ViewMarkDown<CR>
endif


let &cpo = s:save_cpo
