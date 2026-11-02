-- elsarticle.lua: front matter -> the frontmatter environment of the elsarticle class.
--
-- elsarticle wants \begin{frontmatter} \title \author[labels]{..} \ead \affiliation[label]{..} \begin{abstract}
-- \begin{keyword} .. \sep .. \end{keyword} \end{frontmatter} at the start of the document. Pandoc writes \title,
-- \author{A \and B}, \maketitle and an abstract environment, none of which fits. The block is written through
-- `include-before` (it comes right after \begin{document}) and Pandoc's own title, author and abstract are dropped.
--
--   title, author   author: a name, a list, or maps {name, email, corresponding, affiliation}
--   affiliation     one or a list (authors point at them by number or by text; one affiliation in all is shared)
--   abstract, keywords
--   journal         \journal{..} (the name in the page head of a preprint)
--
-- Only for LaTeX output and only when the document class is elsarticle.

local utils = pandoc.utils

local function to_latex(value)
  if value == nil then return nil end
  local doc
  local t = utils.type(value)
  if t == 'Blocks' then
    doc = pandoc.Pandoc(value)
  elseif t == 'Inlines' then
    doc = pandoc.Pandoc({ pandoc.Plain(value) })
  else
    doc = pandoc.Pandoc({ pandoc.Plain({ pandoc.Str(utils.stringify(value)) }) })
  end
  local out = pandoc.write(doc, 'latex')
  out = out:gsub('^%s+', ''):gsub('%s+$', '')
  if out == '' then return nil end
  return out
end

local function as_list(value)
  if value == nil then return {} end
  if utils.type(value) == 'List' then return value end
  return { value }
end

local function plain(value)
  if value == nil then return nil end
  local s = utils.stringify(value)
  if s == '' then return nil end
  return s
end

local function append_blocks(meta, key, raw)
  local merged = pandoc.MetaList({})
  for _, item in ipairs(as_list(meta[key])) do merged[#merged + 1] = item end
  merged[#merged + 1] = pandoc.MetaBlocks({ pandoc.RawBlock('latex', raw) })
  meta[key] = merged
end

return {
  { Meta = function(meta)
      if not FORMAT:match('latex') then return nil end
      if plain(meta.documentclass) ~= 'elsarticle' then return nil end

      local affiliations, texts = {}, {}
      local function affiliation_index(entry)
        local key = utils.stringify(entry)
        local number = tonumber(key)
        if number and affiliations[number] then return number end
        for i, text in ipairs(texts) do
          if text == key then return i end
        end
        local value = to_latex(utils.type(entry) == 'table' and entry.name or entry)
        if not value then return nil end
        affiliations[#affiliations + 1] = value
        texts[#texts + 1] = key
        return #affiliations
      end
      for _, entry in ipairs(as_list(meta.affiliation)) do affiliation_index(entry) end
      local shared = (#affiliations == 1) and 1 or nil

      local body = { '\\begin{frontmatter}' }
      local title = to_latex(meta.title)
      if title then body[#body + 1] = '\\title{' .. title .. '}' end

      local names, any_corresponding = {}, false
      for _, author in ipairs(as_list(meta.author)) do
        local name, email, corresponding, refs
        if utils.type(author) == 'table' then
          name, email = plain(author.name), plain(author.email)
          corresponding = author.corresponding ~= nil and utils.stringify(author.corresponding) == 'true'
          refs = author.affiliation or author.affiliations
        else
          name = plain(author)
        end
        if name then
          names[#names + 1] = name
          local labels = {}
          for _, ref in ipairs(as_list(refs)) do
            local index = affiliation_index(ref)
            if index then labels[#labels + 1] = 'aff' .. index end
          end
          if #labels == 0 and shared then labels = { 'aff1' } end
          local mark = ''
          if corresponding then mark = '\\corref{cor1}'; any_corresponding = true end
          local optional = (#labels > 0) and ('[' .. table.concat(labels, ',') .. ']') or ''
          body[#body + 1] = '\\author' .. optional .. '{' .. (to_latex(pandoc.Str(name)) or name) .. mark .. '}'
          if email then body[#body + 1] = '\\ead{' .. email .. '}' end
        end
      end
      for i, text in ipairs(affiliations) do
        body[#body + 1] = '\\affiliation[aff' .. i .. ']{organization={' .. text .. '}}'
      end
      if any_corresponding then body[#body + 1] = '\\cortext[cor1]{Corresponding author}' end

      local abstract = to_latex(meta.abstract)
      if abstract then body[#body + 1] = '\\begin{abstract}\n' .. abstract .. '\n\\end{abstract}' end
      local keywords = {}
      for _, word in ipairs(as_list(meta.keywords)) do keywords[#keywords + 1] = to_latex(word) end
      if #keywords > 0 then
        body[#body + 1] = '\\begin{keyword}\n' .. table.concat(keywords, ' \\sep ') .. '\n\\end{keyword}'
      end
      body[#body + 1] = '\\end{frontmatter}'
      append_blocks(meta, 'include-before', table.concat(body, '\n'))

      -- Pandoc's citeproc output goes through \cite and \bibitem[label]; the class redefines both. The citation style
      -- already made the text, so a citation is that text and \bibitem is an \item.
      local preamble = { '\\AtBeginDocument{\\DeclareDocumentCommand\\citeproc{mm}{#2}\\renewcommand{\\bibitem}[2][]{\\item}}' }
      -- Pandoc's template always writes \author{} in the preamble, and the class would keep it as an empty first author
      -- (", Ada Example" on the title page): that call does nothing, the real \author is back when the document begins
      preamble[#preamble + 1] = '\\let\\pdfmdauthor\\author\n\\renewcommand{\\author}[2][]{}\n\\AtBeginDocument{\\let\\author\\pdfmdauthor}'
      local journal = to_latex(meta.journal)
      if journal then preamble[#preamble + 1] = '\\journal{' .. journal .. '}' end
      append_blocks(meta, 'header-includes', table.concat(preamble, '\n'))

      -- what Pandoc would have written is written above; the PDF's own title and author stay
      if title then meta['title-meta'] = pandoc.MetaString(plain(meta.title)) end
      if #names > 0 then meta['author-meta'] = pandoc.MetaString(table.concat(names, ', ')) end
      meta.title, meta.author, meta.abstract = nil, nil, nil
      return meta
    end },
}
