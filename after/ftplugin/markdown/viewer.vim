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

let s:themeFullList = [
    \ 'github',
    \ 'github2',
    \ 'github3',
    \ 'clear',
    \ 'clearDark',
    \ 'vue',
    \ 'vue-dark'
\ ]

let s:codeThemeFullList = [
    \ 'arta',
    \ 'ascetic',
    \ 'atelier-dune.dark',
    \ 'atelier-dune.light',
    \ 'atelier-forest.dark',
    \ 'atelier-forest.light',
    \ 'atelier-heath.dark',
    \ 'atelier-heath.light',
    \ 'atelier-lakeside.dark',
    \ 'atelier-lakeside.light',
    \ 'atelier-seaside.dark',
    \ 'atelier-seaside.light',
    \ 'codepen-embed',
    \ 'color-brewer',
    \ 'dark',
    \ 'default',
    \ 'docco',
    \ 'far',
    \ 'foundation',
    \ 'github',
    \ 'googlecode',
    \ 'hybrid',
    \ 'idea',
    \ 'ir_black',
    \ 'kimbie.dark',
    \ 'kimbie.light',
    \ 'magula',
    \ 'mono-blue',
    \ 'monokai',
    \ 'monokai_sublime',
    \ 'obsidian',
    \ 'paraiso.dark',
    \ 'paraiso.light',
    \ 'railscasts',
    \ 'rainbow',
    \ 'solarized_dark',
    \ 'solarized_light',
    \ 'sunburst',
    \ 'tomorrow-night-blue',
    \ 'tomorrow-night-bright',
    \ 'tomorrow-night-eighties',
    \ 'tomorrow-night',
    \ 'tomorrow',
    \ 'vs',
    \ 'xcode',
    \ 'zenburn'
\]

 " default config
let s:theme_default = 'github2'
let s:code_theme_default = 'default'
let s:highlight_code_default = 1
let s:mermaid_img_default = 0

if !exists('g:mdv_theme')
    let g:mdv_theme = s:theme_default
endif

if !exists('g:mdv_highlight_code')
    let g:mdv_highlight_code = s:highlight_code_default
endif

if !exists('g:mdv_code_theme')
    let g:mdv_code_theme = s:code_theme_default
endif

if !exists('g:mdv_mermaid_img')
    let g:mdv_mermaid_img = s:mermaid_img_default
endif


function! s:BuildConfigItem(theme, isHighlightCode, codeTheme, isMermaidImg)
    return {
        \ 'theme': a:theme,
        \ 'highlight_code': a:isHighlightCode,
        \ 'code_theme': a:codeTheme,
        \ 'mermaid_img': a:isMermaidImg
        \}
endfunction

function! s:BuildGlobalConfig()
    let config = s:BuildConfigItem(g:mdv_theme, g:mdv_highlight_code, g:mdv_code_theme, g:mdv_mermaid_img)
    return config
endfunction

function! s:MergeConfigByGlobal(config)
    let globalConfig = s:BuildGlobalConfig()
    let defaultTheme = get(globalConfig, 'theme')
    let defaultHighlightCode = get(globalConfig, 'highlight_code')
    let defaultCodeTheme = get(globalConfig, 'code_theme')
    let defaultMermaidImg = get(globalConfig, 'mermaid_img')

    let theme = get(a:config, 'theme', defaultTheme)
    let isHighlightCode = get(a:config, 'highlight_code', defaultHighlightCode)
    let codeTheme = get(a:config, 'code_theme', defaultCodeTheme)
    let isMermaidImg = get(a:config, 'mermaid_img', defaultMermaidImg)

    let mergedItem =  s:BuildConfigItem(theme, isHighlightCode, codeTheme, isMermaidImg)
    return mergedItem
endfunction

function! s:GetConfigItemFromPack(name)
    let globalConfig = s:BuildGlobalConfig()
    if exists('g:mdv_config_pack') == 0
        return globalConfig
    endif

    let config = get(g:mdv_config_pack, a:name, {})

    if empty(config)
        return globalConfig
    endif

    let mergedConfig = s:MergeConfigByGlobal(config)
    return mergedConfig
endfunction


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
"@param {dict} config
"@param {String} content
"@return {Dictionary} dict.title, dict.html_lines
function s:MakeUpHtml(config, content)
    "  full config
    let theme = get(a:config, 'theme', s:theme_default)
    let codeTheme = get(a:config, 'code_theme', s:code_theme_default)
    let isHighlightCode = get(a:config, 'highlight_code', s:highlight_code_default)
    let isMermaidImg = get(a:config, 'mermaid_img', s:mermaid_img_default)

    let style = s:ReadFile('/css/' . theme . '.css', '\n')

    if isHighlightCode
        let hljs_css = s:ReadFile('/css/hljs/' . codeTheme . '.css', '')
        let hljs_fix = s:ReadFile('/css/' . theme . '-hljs.css', '')
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

    if isMermaidImg
        let html = substitute(html, '{{svg-2-img}}', 'true', '')
    endif
    let svg2img_path = s:scriptPath . '/js/svg2img.js'
    let html = substitute(html, '{{svg2img-js}}', svg2img_path, '')


    let lines = split(html, '\n')

    let ret_dict = {'title': title, 'html_lines': lines}
    return ret_dict
endfunction

" @param {dict} config
"@return {String}
function! s:ParseContent(config)
    let lineList = getline(1, '$')
    let tempMarkdown = tempname()
    call writefile(lineList, tempMarkdown, '')

    let viewer_js = shellescape(s:scriptPath . '/viewer.js')
    let isHighlightCode = get(a:config, 'highlight_code')
    let is_highlight_code = isHighlightCode ? '1' : '0'
    let str_cmd = 'node ' . viewer_js . ' ' . shellescape(tempMarkdown) . ' ' . is_highlight_code

    let parsed = system(str_cmd)
    return parsed
endfunction

" @param {dict} config
"@return {dict} dict.title, dict.html_lines
function! s:Convert2Html(config)
    let parsed = s:ParseContent(a:config)
    let theme = get(a:config, 'theme')
    let dict = s:MakeUpHtml(a:config, parsed)
    return dict
endfunction

"
"write html to file
" @param {dict} config
" @return {boolean}
function! s:WriteHtml(config)
    if !exists('b:temp_html_file') && !exists('b:save_html_file')
        return 0
    endif

    let dict = s:Convert2Html(a:config)
    let lines = get(dict, 'html_lines', [])

    if exists('b:temp_html_file')
        call writefile(lines, b:temp_html_file, '')
    endif

    if exists('b:save_html_file')
        call writefile(lines, b:save_html_file, '')
    endif

    return 1
endfunction

function! s:RemoveTempHtml()
    if exists('b:temp_html_file')
        call delete(b:temp_html_file)
    endif
endfunction

function! s:GetConfigForCurrentBuffer()
    if exists('b:mdv_cached_config')
        return b:mdv_cached_config
    endif
    return s:BuildGlobalConfig()
endfunction

function! s:ViewMarkdownWithConfig(config)
    if !exists('b:temp_html_file')
        let file_name = expand('%:t')
        let file_path = expand('%:p:h')
        let b:temp_html_file = file_path . '/.' . file_name . '.temp.html'
    endif

    let isWriteSuccess =  s:WriteHtml(a:config)
    if isWriteSuccess
        let b:mdv_cached_config = a:config
    endif

    call s:OpenFile(b:temp_html_file)
endfunction

function! s:ParseInputPackName(length, args)
    if a:length > 0
        let name = get(a:args, 0)
        let config = s:GetConfigItemFromPack(name)
        return config
    endif
    let config = s:GetConfigForCurrentBuffer()
    return config
endfunction

function! s:ViewMarkdown(...)
    let config = s:ParseInputPackName(a:0, a:000)
    call s:ViewMarkdownWithConfig(config)
endfunction

function! s:Markdown2HtmlWithConfig(config)
    if !exists('b:save_html_file')
        let b:save_html_file = expand('%:p') . '.html'
    endif

    let isWriteSuccess =  s:WriteHtml(a:config)
    if isWriteSuccess
        let b:mdv_cached_config = a:config
    endif
endfunction

function! s:Markdown2Html(...)
    let config = s:ParseInputPackName(a:0, a:000)
    call s:Markdown2HtmlWithConfig(config)
endfunction

function! s:AutoRenderWhenSave()
    let config = s:GetConfigForCurrentBuffer()
    let isWriteSuccess =  s:WriteHtml(config)
    if isWriteSuccess
        let b:mdv_cached_config = config
    endif
endfunction

"@param {integer} length
"@param {list} args
function! s:ParseInputConfig(length, args)
    if a:length == 0
        let config = s:GetConfigForCurrentBuffer()
        return config
    endif

    let config = {}
    if a:length == 1
        let config['theme'] = get(a:args, 0)
    elseif a:length == 2
        let config['theme'] =  get(a:args, 0)
        let config['code_theme'] =  get(a:args, 1)
    else
        let config['theme'] =  get(a:args, 0)
        let config['code_theme'] =  get(a:args, 1)
        let strMermeidImg = get(a:args, 2)
        let config['mermaid_img'] = strMermeidImg ==# '1'
    endif

    let mergedConfig = s:MergeConfigByGlobal(config)
    return mergedConfig
endfunction

function! s:ViewMarkdownWithInputConfig(...)
    let config = s:ParseInputConfig(a:0, a:000)
    call s:ViewMarkdownWithConfig(config)
endfunction

function! s:Markdown2HtmlWithInputConfig(...)
    let config = s:ParseInputConfig(a:0, a:000)
    call s:Markdown2HtmlWithConfig(config)
endfunction

function MkdViewCompleter(A, L, C)
    let names= []

    if exists('g:mdv_config_pack')
        let names = keys(g:mdv_config_pack)
    endif

    let hint = trim(a:A)

    if strlen(hint) == 0
        return names
    endif

    let matchedList= []
    for item in names
        if stridx(item, hint) > -1
            call add(matchedList, item)
        endif
    endfor

    return matchedList
endfunction

function! s:ThemeComplete(hint)
    let trimed = trim(a:hint)

    if len(trimed) == 0
        return s:themeFullList
    endif

    let matchedList= []
    for item in s:themeFullList
        if stridx(item, trimed) > -1
            call add(matchedList, item)
        endif
    endfor

    return matchedList
endfunction

function! s:CodeThemeComplete(hint)
    let trimed = trim(a:hint)

    if len(trimed) == 0
        return s:codeThemeFullList
    endif

    let matchedList= []
    for item in s:codeThemeFullList
        if stridx(item, trimed) > -1
            call add(matchedList, item)
        endif
    endfor

    return matchedList
endfunction

function! s:MermaidImgComplete(hint)
    let completeList = ['0', '1']
    let trimed = trim(a:hint)

    if len(trimed) == 0
        return completeList
    endif

    return []
endfunction

function! s:isEndWithSpace(str)
    let length = strlen(a:str)
    return strridx(a:str, ' ') == length - 1  ? 1 :  0
endfunction



" A: g
" L: MarkdownView g
" C: 14
"
" A: v
" L: MarkdownView github2 v
" C: 22
"
function MarkdownViewCompleter(A, L, C)
    let parts = split(a:L)
    let length = len(parts)

    if length == 1
        return s:themeFullList
    elseif length == 2
        if s:isEndWithSpace(a:L)
            let completeList = s:CodeThemeComplete(' ')
        else
            let completeList = s:ThemeComplete(a:A)
        endif
        return completeList
    elseif length == 3
        if s:isEndWithSpace(a:L)
            let completeList = s:MermaidImgComplete(' ')
        else
            let completeList = s:CodeThemeComplete(a:A)
        endif
        return completeList
    endif

    return []
endfunction



command -nargs=? -complete=customlist,MkdViewCompleter MkdView call s:ViewMarkdown(<f-args>)
command -nargs=? -complete=customlist,MkdViewCompleter Mkd2html call s:Markdown2Html(<f-args>)
command -nargs=+ -complete=customlist,MarkdownViewCompleter MarkdownView call s:ViewMarkdownWithInputConfig(<f-args>)
command -nargs=+ -complete=customlist,MarkdownViewCompleter Markdown2html call s:Markdown2HtmlWithInputConfig(<f-args>)

augroup markdownviewer
    autocmd!
    autocmd QuitPre,BufDelete,BufUnload,BufHidden,BufWinLeave     *.md,*.mkd,*.markdown   call s:RemoveTempHtml()
    autocmd BufWritePre *.md,*.mkd,*.markdown   call s:AutoRenderWhenSave()
augroup END


let &cpoptions = s:save_cpo
