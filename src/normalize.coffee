toMarkdown = require('to-markdown')

markdown = (html) ->
  firstImgSrc = null

  # to-markdown seems to strip extra newlines which we'd like. Replacing
  # them with <br>s beforehand preserves them correctly.
  html = html.replace(/\n/g, '<br>')

  converted = toMarkdown(html, {converters: [
    {
      filter: 'p',
      replacement: (content) ->
        # Periods (.) are prepended with backslash inside <p>s for some reason.
        # Let's remove these.
        return "#{content.replace(/\\/g, '')}"
    },
    {
      filter: 'pre',
      replacement: (content) ->
        return "```#{content}```"
    },
    {
      filter: 'tt'
      replacement: (content) ->
        return "`#{content}`"
    },
    {
      filter: 'img',
      replacement: (innerHTML, node) ->
        firstImgSrc = node.getAttribute('src')
        return "<<#{firstImgSrc}|img>>"
    },
    {
      filter: 'a',
      replacement: (innerHTML, node) ->
        href = node.getAttribute('href')
        return "<#{href}|#{innerHTML}>"
    },
    {
      filter: ['strong', 'b'],
      replacement: (content) ->
        return "*#{content}*"
    },
  ]})

  # re-replace first img tag, since its processed last by to-markdown
  converted = converted.replace(/<<([^\|]+)\|img>>/, '<<$1|img> (attached)>')

  return {
    markdown: converted,
    firstImgSrc: firstImgSrc,
  }

# Piazza API returns strings with some ascii characters encoded. We'd like
# to unencode them.
unencode = (str) ->
  return str.replace(/&#(\d+);/g, (match, g1) ->
    return String.fromCharCode(g1))

module.exports = {
  markdown: markdown,
  unencode: unencode,
}
