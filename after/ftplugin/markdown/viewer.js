/* jshint node: true, esversion: 6, asi: true */


const markdownIt = require('markdown-it')
const hljs = require('highlight.js')
const fs = require('fs')

const args = process.argv
const filePath = args[2]

if (!markdownIt) {
  console.log('ERROR: no markdownIt')
  process.exit(1)
}

if (!hljs) {
  console.log('Error: no highlight.js')
  process.exit(1)
}

/**
 * Known mermaid diagram type keywords.
 * Used to match both fence language (lang param) and content first line (str param).
 */
const MERMAID_TYPES = 'sequenceDiagram|graph|flowchart|gantt|classDiagram|stateDiagram|stateDiagram-v2|erDiagram|journey|pie|gitGraph|C4Context|C4Container|C4Deployment|C4Dynamic|C4Boundary|mindmap|timeline|sankey|quadrantChart|requirement|block|block-beta|packet|packet-beta|architecture|architecture-beta|radar|treemap|venn|kanban|wardley|ishikawa|xychart|xychart-beta';
const MERMAID_LANG_RE = new RegExp(`^(${MERMAID_TYPES})$`);
const MERMAID_CONTENT_RE = new RegExp(`^(${MERMAID_TYPES})`);

const options = {

  // Enable HTML tags in source
  html: true,
  // Use '/' to close single tags (<br />).
  // This is only for full CommonMark compatibility.
  xhtmlOut: true,
  // Convert '\n' in paragraphs into <br>
  breaks: false,
  // CSS language prefix for fenced blocks. Can be
  // useful for external highlighters.
  langPrefix: 'language-',
  // Autoconvert URL-like text to links
  linkify: true,
  // Enable some language-neutral replacement + quotes beautification
  typographer: true,
  // Double + single quotes replacement pairs, when typographer enabled,
  // and smartquotes on. Could be either a String or an Array.
  //
  // For example, you can use '«»„"' for Russian, '„"‚'' for German,
  // and ['«\xA0', '\xA0»', '‹\xA0', '\xA0›'] for French (including nbsp).
  quotes: '\u201C\u201D\u2018\u2019',
  // Highlighter function. Should return escaped HTML,
  // or '' if the source string is not changed and should be escaped externally.
  // If result starts with <pre... internal wrapper is skipped.
  highlight(str, lang) {
    if (lang === 'mermaid' || MERMAID_LANG_RE.test(lang) || MERMAID_CONTENT_RE.test(str)) {
      return `<div class="mermaid">${str}</div>`
    }

    if (lang && hljs.getLanguage(lang)) {
      try {
        return `<pre class="hljs"><code>${
          hljs.highlight(str, { language: lang }).value
        }</code></pre>`
      } catch (ex) {
        // do nothing
      }
    }

    const markdownCompiler = markdownIt()
    const escapedStr = markdownCompiler.utils.escapeHtml(str)
    return `<pre class="hljs"><code>${escapedStr}</code></pre>`
  },
}


const markdownCompiler = markdownIt(options)

fs.readFile(filePath, {
  encoding: 'utf-8',
}, (err, data) => {
  if (err) {
    console.log(`ERROR: failed to read file [${filePath}]`)
    return
  }

  let parsed = 'ERROR: markdown-it failed to render markdown content'

  try {
    parsed = markdownCompiler.render(data)
  } catch (ex) {
    // do nothing
  }

  console.log(parsed)
})
