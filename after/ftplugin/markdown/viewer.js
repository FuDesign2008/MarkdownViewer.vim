/* jshint node: true */


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


const markdownCompiler = markdownIt({
  highlight(str, lang) {
    if (lang === 'mermaid'
        || str.match(/^sequenceDiagram/)
        || str.match(/^graph/)
        || str.match(/^gantt/)
    ) {
      return `<div class="mermaid">${str}</div>`
    }

    if (lang && hljs.getLanguage(lang)) {
      try {
        return `<pre class="hljs"><code>${
          hljs.highlight(lang, str, true).value
        }</code></pre>`
      } catch (ex) {
        // do nothing
      }
    }

    const escapedStr = markdownCompiler.utils.escapeHtml(str)
    return `<pre class="hljs"><code>${escapedStr}</code></pre>`
  },
})


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
