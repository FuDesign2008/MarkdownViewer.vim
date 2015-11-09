
/*jshint node: true, nomen: true, indent: 2, maxlen: 80, plusplus: true,  regexp: true, eqnull: true */
/* global escape: true */


'use strict';

var marked = require('marked'),
  hljs = require('highlight.js'),
  fs = require('fs'),
  args = process.argv,
  filePath = args[2];

if (!marked) {
  console.log('ERROR: no marked');
  return;
}

if (!hljs) {
  console.log('ERROR: no highlight.js');
  return;
}

fs.readFile(filePath, {
    encoding: "utf-8"
  }, function (err, data) {
    var parsed = '',
      theRenderer = new marked.Renderer();

    /**
     * @see Renderer.prototype.code in `marked.js`
     */
    theRenderer.code = function(code, lang, escaped) {
      if (this.options.highlight) {
        var out = this.options.highlight(code, lang);
        if (out != null && out !== code) {
          escaped = true;
          code = out;
        }
      }

      if (!lang) {
        return '<pre><code class="hljs">' +
          (escaped ? code : escape(code, true)) + '\n</code></pre>';
      }

      return '<pre><code class="hljs ' +
        this.options.langPrefix + escape(lang, true) + '">' +
        (escaped ? code : escape(code, true)) +
        '\n</code></pre>\n';
    };


    if (err) {
      console.log('ERROR: read file error [' + filePath +  ']' );
      return;
    }


    marked.setOptions({
      langPrefix: '',
      renderer: theRenderer,
      highlight: function (code) {
        var highlighted = hljs.highlightAuto(code),
          html = highlighted.value || '';
        return html;
      }
    });

    try {

      // FIX https://github.com/chjj/marked/issues/642
      data = data.replace(/^(#+)([^ #])/mg, function (all, $1, $2) {
        return $1 + ' ' + $2;
      });

      parsed = marked(data);
      //parsed = marked('I am using __markdown__.');
    } catch (ex) {
      console.log('ERROR: marked to parse markdown content');
    }

    console.log(parsed);

  });






