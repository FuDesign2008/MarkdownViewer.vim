"
" viewer.vim  in ftplugin/markdown/
"
"


if &compatible || exists('g:mdv_loaded')
    finish
endif
let g:mdv_loaded = 1
let s:save_cpo = &cpoptions
set cpoptions&vim

let s:scriptPath = expand('<sfile>:p:h')

let s:theme_default = 'github2'
if !exists('g:mdv_theme')
    let g:mdv_theme = s:theme_default
endif

if !exists('g:mdv_highlight_code')
    let g:mdv_highlight_code = 1
endif

let s:code_theme_default = 'default'
if !exists('g:mdv_code_theme')
    let g:mdv_code_theme = s:code_theme_default
endif

function! s:OpenFile(filePath)

    let path = shellescape(a:filePath)
    let cmdStr = ''

    if has('mac')
        let cmdStr = 'open -a Safari ' . path
        let findStr = system('ls /Applications/ | grep -i google\ chrome')
        if strlen(findStr) > 5
            let cmdStr = 'open -a Google\ Chrome ' . path
        endif
    elseif has('win32') || has('win64') || has('win95') || has('win16')
        let cmdStr = 'cmd /c start "" ' . path
    else
        echomsg 'Can NOT open ' . a:filePath
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
    if matched ==? ''
        let matched = matchstr(a:html, '<h1>[^<]\+</h1>')
    endif
    if matched ==? ''
        return ''
    endif
    let gtIndex = stridx(matched, '>')
    let ltIndexRight = strridx(matched, '<')
    return strpart(matched, gtIndex + 1, ltIndexRight - gtIndex - 1)
endfunction
"
"@param {String} theme
"@param {String} content
"@return {Dictionary} dict.title, dict.html_lines
function s:MakeUpHtml(theme, content)

    let read_theme = a:theme
    let style = s:ReadFile('/css/' . read_theme . '.css', '\n')

    if g:mdv_highlight_code
        let hljs_css = s:ReadFile('/css/hljs/' . g:mdv_code_theme . '.css', '')
        let hljs_fix = s:ReadFile('/css/' . read_theme . '-hljs.css', '')
        let style = style . hljs_css . hljs_fix
    endif



    let mermaid_path = s:scriptPath . '/js/mermaid.min.js'
    let mermaid_css = s:ReadFile('/css/mermaid.css', '')
    let style = style . mermaid_css

    let html = s:ReadFile('/bone.html', '')

    let title = s:GetTitle(a:content)
    let html = substitute(html, '{{title}}', escape(title, '&\'), '')
    let html = substitute(html, '{{style}}', style, '')
    let html = substitute(html, '{{mermaid-path}}', mermaid_path, '')
    let html = substitute(html, '{{content}}', escape(a:content, '&\'), '')

    if exists('g:mdv_mermaid_img') && g:mdv_mermaid_img
        let html = substitute(html, '{{svg-2-img}}', 'true', '')
    endif
    let svg2img_path = s:scriptPath . '/js/svg2img.js'
    let html = substitute(html, '{{svg2img-js}}', svg2img_path, '')


    let lines = split(html, '\n')

    let ret_dict = {'title': title, 'html_lines': lines}
    return ret_dict
endfunction

"@return {String}
function! s:ParseContent()
    let lineList = getline(1, '$')
    let tempMarkdown = tempname()
    call writefile(lineList, tempMarkdown, '')

    let viewer_js = shellescape(s:scriptPath . '/viewer.js')
    let is_highlight_code = g:mdv_highlight_code ? '1' : '0'
    let str_cmd = 'node ' . viewer_js . ' ' . shellescape(tempMarkdown) . ' ' . is_highlight_code

    let parsed = system(str_cmd)
    return parsed
endfunction

"@return {Dictionary} dict.title, dict.html_lines
function! s:Convert2Html()
    let parsed = s:ParseContent()
    let dict = s:MakeUpHtml(g:mdv_theme, parsed)
    return dict
endfunction

"
"write html to file
"@param {Boolean} saveHtml  save html to the folder that include markdown file
function! s:WriteHtml()

    if !exists('b:temp_html_file') && !exists('b:save_html_file')
        return
    endif

    let dict = s:Convert2Html()
    let lines = get(dict, 'html_lines', [])

    if exists('b:temp_html_file')
        call writefile(lines, b:temp_html_file, '')
    endif

    if exists('b:save_html_file')
        call writefile(lines, b:save_html_file, '')
    endif

endfunction

function! s:RemoveTempHtml()
    if exists('b:temp_html_file')
        call delete(b:temp_html_file)
    endif
endfunction


function! s:ViewMarkDown()
    if !exists('b:temp_html_file')
        let file_name = expand('%:t')
        let file_path = expand('%:p:h')
        let b:temp_html_file = file_path . '/.' . file_name . '.temp.html'
    endif
    call s:WriteHtml()
    call s:OpenFile(b:temp_html_file)
endfunction

function! s:Markdown2Html()
    if !exists('b:save_html_file')
        let b:save_html_file = expand('%:p') . '.html'
    endif
    call s:WriteHtml()
endfunction

function! s:AutoRenderWhenSave()
    call s:WriteHtml()
endfunction


command -nargs=0 MkdView call s:ViewMarkDown()
command -nargs=0 Mkd2html call s:Markdown2Html()

augroup markdownviewer
    autocmd!
    autocmd QuitPre,BufDelete,BufUnload,BufHidden,BufWinLeave     *.md,*.mkd,*.markdown   call s:RemoveTempHtml()
    autocmd BufWritePre *.md,*.mkd,*.markdown   call s:AutoRenderWhenSave()
augroup END


let &cpoptions = s:save_cpo
