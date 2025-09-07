const path = require("node:path")
const sass = require("sass")
const fs = require('fs')

module.exports = async function(eleventyConfig) {
  // Recognize Sass as a "template language"
  eleventyConfig.addTemplateFormats("scss")
  
  // Compile Sass
  eleventyConfig.addExtension("scss", {
    outputFileExtension: "css",
    compile: async function (inputContent, inputPath) {
      // Skip files like _fileName.scss
      let parsed = path.parse(inputPath);
      if (parsed.name.startsWith("_")) {
        return
      }
  
      // Run file content through Sass
      let result = sass.compileString(inputContent, {
        loadPaths: [parsed.dir || "."],
        sourceMap: false, // or true, your choice!
      });
  
      // Allow included files from @use or @import to
      // trigger rebuilds when using --incremental
      this.addDependencies(inputPath, result.loadedUrls)
  
      return async () => {
        return result.css
      }
    },
  })
    
  eleventyConfig.addPreprocessor("apiLinks", "md,liquid", (data, content) => {
    var c = content
    
    const jsonPath = `./api-rules/${data.title}.json`
    
    const formatRuleText = (ruleText) => `<div class="api-rule"><pre><code>${ruleText}</pre></code></div>`
    
    if (fs.existsSync(jsonPath)) {
      const json = require(jsonPath)
      var used = {
        single: {},
        array: {},
      }
      c = c.replace(/rule::(.*)/g, (match, p1) => {
        var ruleText = ''
        if (p1.startsWith('array.')) {
          const k = p1.replace('array.', '')
          ruleText = json['array'][k]
          used['array'][k] = true
        }
        else {
          ruleText = json['single'][p1]
          used['single'][p1] = true
        }
        return formatRuleText(ruleText)
      })
      
      // look for undocumented rules.
      var unusedSingle = []
      for (const r in json['single']) {
        if (!used['single'][r]) {
          unusedSingle.push(r)
        }
      }

      var unusedArray = []
      for (const r in json['array']) {
        if (!used['array'][r]) {
          unusedArray.push(r)
        }
      }
      
      if (unusedSingle.length > 0) {
        c += "\n\n## Undocumented Single Rules:\n\n"
        unusedSingle.forEach(r => {
          c += r +"\n"+ formatRuleText(json['single'][r]) + "\n\n"
        })
      }

      if (unusedArray.length > 0) {
        c += "\n\n## Undocumented Array Rules:\n\n"
        
        unusedArray.forEach(r => {
          c += r +"\n"+ formatRuleText(json['array'][r]) + "\n\n"
        })        
      }

    }

    // if it exists, then do a search replace for rules
    // maybe also add a section at the end for what is missing.
    c = c.replace(/::([^:]*?)::/g, '<a href="/api/$1/">$1</a>')
    c = c.replace(/<rule>\s*(.*?)\s*<\/rule>/gs, '<div class="api-rule"><pre><code>$1</pre></code></div>')
    return c
  })
  
  eleventyConfig.addCollection("api", function (collectionsApi) {
    return collectionsApi.getAll().filter(function (item) {
      return item.url.startsWith('/api/') && item.url != '/api/'
    }).sort(function (a, b) {
      // console.log(a) 
      return (a.data.title || "").localeCompare(b.data.title)
    });
  });

}