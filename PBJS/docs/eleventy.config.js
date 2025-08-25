const path = require("node:path")
const sass = require("sass")


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
    var c = content.replace(/::(.*?)::/g, '<a href="/api/$1/">$1</a>')
    c = c.replace(/<rule>\s*(.*?)\s*<\/rule>/gs, '<div class="api-rule"><pre><code>$1</pre></code></div>')
    return c
  })
  
  eleventyConfig.addCollection("api", function (collectionsApi) {
    return collectionsApi.getAll().filter(function (item) {
      return item.url.startsWith('/api/')
    }).sort(function (a, b) {
      console.log(a)
      return (a.data.title || "").localeCompare(b.data.title)
    });
  });

}