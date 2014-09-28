"
" preview.vim  in ftplugin/markdown/
"
" Providing commands:
"
" :ViewMkd
" :M2html
"
"


if &cp || exists('g:mdv_loaded')
    finish
endif
let g:mdv_loaded = 1
let s:save_cpo = &cpo
set cpo&vim

let s:scriptPath = expand('<sfile>:hp')

let s:saveHtml = 1
if exists('g:mdv_html')
    let s:saveHtml = g:mdv_html
endif


let s:defaultTheme = 'github2'
let s:theme = 'github2'
if exists('g:mdv_theme')
    let s:theme = g:mdv_theme
endif

function! s:OpenFile(filePath)

    let path = shellescape(a:filePath)
    let cmdStr = ''

    if has('mac')
        let cmdStr = 'open ' . path
    elseif has('win32') || has('win64') || has('win95') || has('win16')
        let cmdStr = '/c start ' . path
    else
        echomsg "Can NOT open " . a:filePath
        return
    endif

    call system(cmdStr)
    echo cmdStr

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

"
"write html to file
"@return {String}  the path of writed file
function! s:WriteHtml()
    let text = getline(1, '$')
    let tempMarkdown = tempname()
    call writefile(text, tempMarkdown, '')
    "echomsg text
    let parsed = system('marked  --input ' . shellescape(tempMarkdown))
    "echo type(parsed)
    let html = s:Convert2Html(s:theme, parsed)
    if s:saveHtml
        let fileName = expand('%p') . '.html'
    else
        if !exists('b:tempFile')
            let b:tempFile = tempname() . '.html'
        endif
        let fileName = b:tempFile

        "force write to current directory
        if exists('b:autosave') && b:autosave
            let nameInCurDir = expand('%p') . '.html'
            call writefile(html, nameInCurDir, '')
        endif
    endif

    call writefile(html, fileName, '')
    return fileName
endfunction


function! s:ViewMarkDown()
    let filePath = s:WriteHtml()
    call s:OpenFile(filePath)
endfunction

function! s:Markdown2Html()
    let b:autosave = 1
    call s:WriteHtml()
endfunction

command -nargs=0 ViewMkd call s:ViewMarkDown()
command -nargs=0 M2html call s:Markdown2Html()

" use BufWritePre instead of BufWritePost
autocmd BufWritePre *.md,*.mkd,*.markdown  :call s:WriteHtml()


let &cpo = s:save_cpo
