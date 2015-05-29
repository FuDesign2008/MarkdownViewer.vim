"
" viewer.vim  in ftplugin/markdown/
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

let s:highlightCode = 1
if exists('g:mdv_highlight_code')
    let s:highlightCode = g:mdv_highlight_code
endif

let s:defaultCodeTheme = 'default'
let s:codeTheme = 'default'
if exists('g:mdv_code_theme')
    let s:codeTheme = g:mdv_code_theme
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
"@return {Dictionary} dict.title, dict.html_lines
function s:MakeUpHtml(theme, content)
    let html = ''
    if s:highlightCode
        let html = s:ReadFile('/bone_hljs.html', '')

        let hljs_css = s:ReadFile('/hljs/styles/' . s:codeTheme . '.css', '')
        if strlen(hljs_css) < 1
            let hljs_css = s:ReadFile('/hljs/styles/'. s:defaultCodeTheme . '.css', '')
        endif

        let html = substitute(html, '{{hljs-css}}', hljs_css, '')
    else
        let html = s:ReadFile('/bone.html', '')
    endif

    let cssSuffix = s:highlightCode ? '-hljs.css' : '.css'

    let style = s:ReadFile('/' . a:theme . cssSuffix, '\n')
    if len(style) < 1
        let style = s:ReadFile('/' . s:defaultTheme . cssSuffix, '\n')
    endif

    let title = s:GetTitle(a:content)
    let html  = substitute(html, '{{style}}', style, '')
    let html  = substitute(html, '{{title}}', escape(title, '&\'), '')
    let html  = substitute(html, '{{content}}', escape(a:content, '&\'), '')

    let lines = split(html, '\n')

    let ret_dict = {'title': title, 'html_lines': lines}
    return ret_dict
endfunction

"@return {String}
function! s:ParseContent()
    let lineList = getline(1, '$')
    let tempMarkdown = tempname()
    call writefile(lineList, tempMarkdown, '')

    let str_cmd = 'marked  --input ' . shellescape(tempMarkdown)

    if s:highlightCode
        let markedJS = shellescape(s:scriptPath . '/marked-hljs.js')
        let str_cmd = 'node ' . markedJS . ' ' . shellescape(tempMarkdown)
    endif

    let parsed = system(str_cmd)
    return parsed
endfunction

"@return {Dictionary} dict.title, dict.html_lines
function! s:Convert2Html()
    let parsed = s:ParseContent()
    let dict = s:MakeUpHtml(s:theme, parsed)
    return dict
endfunction

"
"write html to file
"@return {String}  the path of writed file
function! s:WriteHtml()
    let dict = s:Convert2Html()
    let lines = get(dict, 'html_lines', [])

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
            call writefile(lines, nameInCurDir, '')
        endif
    endif

    call writefile(lines, fileName, '')
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

function! s:Mail(name)
    if !has('python')
        echomsg "Mail needs python support!"
        return
    endif

    if !exists('g:mdv_mail_config')
        let path = expand('~/mdv_mail_config.vim')
        if filereadable(path)
            exec ':so ' . path
        else
            echomsg 'File `~/mail.vim` does not exist or is not readable!'
            return
        endif
    endif

    if !exists('g:mdv_mail_config')
        echomsg 'g:mdv_mail_config does not exist!'
        return
    endif

    let config_name = substitute(a:name, '^\s*', '', '')
    let config_name = substitute(config_name, '\s*$', '', '')

    let config = get(g:mdv_mail_config, config_name, {})
    if !has_key(config, 'from') || !has_key(config, 'to') || !has_key(config, 'server_host') || !has_key(config, 'server_port')
        echomsg 'The g:mdv_mail_config[`'. config_name .'`] is not valid!'
        return
    endif

    let mail_from = get(config, 'from')
    let mail_to = get(config, 'to')
    let mail_cc = get(config, 'cc', [])
    let server_host = get(config, 'server_host')
    let server_port = get(config, 'server_port')
    let login_name = get(config, 'login_name', '')
    let login_pwd = get(config, 'login_pwd', '')

    let html = s:ParseContent()
    let title = s:GetTitle(html)

    "0 - initial status
    "1 - mail send ok
    "2 - mail send error
    let g:mail_mkd_status = 0

python << EOF
# encoding:utf-8

import sys
reload(sys)
sys.setdefaultencoding('utf-8')

import vim
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

sender = vim.eval('mail_from')
to_address_list = vim.eval('mail_to')
cc_address_list = vim.eval('mail_cc')
server_address = vim.eval('server_host')
server_port = vim.eval('server_port')
login_name = vim.eval('login_name')
login_pwd = vim.eval('login_pwd')

subject = vim.eval('title')
content = vim.eval('html')

if not isinstance(subject, unicode):
    subject = unicode(subject)


msg = MIMEMultipart('alternative')
msg['Subject'] = subject
msg['From'] = sender
msg['To'] = ','.join(to_address_list)
msg['CC'] = ','.join(cc_address_list)

mime_text = MIMEText(content, 'html', 'utf-8')
msg.attach(mime_text)

try:
    server = smtplib.SMTP(server_address, server_port)
    server.login(login_name, login_pwd)
    server.sendmail(sender, to_address_list + cc_address_list, msg.as_string())
    server.quit()
    vim.command('let g:mail_mkd_status=1')
except smtplib.SMTPException:
    vim.command('let g:mail_mkd_status=2')
EOF

if g:mail_mkd_status == 1
    echomsg 'Mail sent OK!'
else
    echomsg 'Failed to send mail!'
endif

endfunction

command -nargs=0 ViewMkd call s:ViewMarkDown()
command -nargs=0 M2html call s:Markdown2Html()
command -nargs=1 MailMkd call s:Mail(<f-args>)

" use BufWritePre instead of BufWritePost
autocmd BufWritePre *.md,*.mkd,*.markdown  :call s:WriteHtml()


let &cpo = s:save_cpo
