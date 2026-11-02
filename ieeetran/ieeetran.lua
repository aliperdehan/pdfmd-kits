-- ieeetran.lua: front matter -> the title block of the IEEEtran class.
--
-- IEEEtran wants \title{..}, \author{\IEEEauthorblockN{name} \IEEEauthorblockA{affiliation, e-mail} \and ..} and
-- \maketitle, then the abstract and \begin{IEEEkeywords}. In journal mode the author is a list of names and the
-- affiliations go into a \thanks footnote. Pandoc's template writes \author{A \and B} and an abstract that has no
-- keywords, so the block is written through `include-before` (right after \begin{document}) and Pandoc's own
-- title, author and abstract are dropped.
--
--   author        a name, a list, or maps {name, email, affiliation}
--   affiliation   one or a list (an author points at it by number or text; one affiliation in all is shared)
--   abstract, keywords
--
-- Only for LaTeX output and only when the document class is IEEEtran.

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

local function has_option(meta, wanted)
  for _, option in ipairs(as_list(meta.classoption)) do
    if utils.stringify(option) == wanted then return true end
  end
  return false
end

return {
  { Meta = function(meta)
      if not FORMAT:match('latex') then return nil end
      if plain(meta.documentclass) ~= 'IEEEtran' then return nil end
      local journal = has_option(meta, 'journal')

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

      local authors = {}
      for _, author in ipairs(as_list(meta.author)) do
        local entry = { refs = {} }
        local refs
        if utils.type(author) == 'table' then
          entry.name, entry.email = plain(author.name), plain(author.email)
          refs = author.affiliation or author.affiliations
        else
          entry.name = plain(author)
        end
        if entry.name then
          for _, ref in ipairs(as_list(refs)) do
            local index = affiliation_index(ref)
            if index then entry.refs[#entry.refs + 1] = index end
          end
          if #entry.refs == 0 and shared then entry.refs = { shared } end
          authors[#authors + 1] = entry
        end
      end

      local body = {}
      local title = to_latex(meta.title)
      if title then body[#body + 1] = '\\title{' .. title .. '}' end
      local names = {}
      if #authors > 0 then
        local blocks = {}
        if not journal then
          for _, entry in ipairs(authors) do
            local lines = {}
            for _, index in ipairs(entry.refs) do lines[#lines + 1] = affiliations[index] end
            if entry.email then lines[#lines + 1] = entry.email end
            blocks[#blocks + 1] = '\\IEEEauthorblockN{' .. (to_latex(pandoc.Str(entry.name)) or entry.name) .. '}\n'
              .. '\\IEEEauthorblockA{' .. table.concat(lines, '\\\\\n') .. '}'
          end
          body[#body + 1] = '\\author{' .. table.concat(blocks, '\n\\and\n') .. '}'
        else
          local listed, notes = {}, {}
          for _, entry in ipairs(authors) do
            listed[#listed + 1] = to_latex(pandoc.Str(entry.name)) or entry.name
            local where = {}
            for _, index in ipairs(entry.refs) do where[#where + 1] = affiliations[index] end
            local sentence = entry.name .. ' is with ' .. (#where > 0 and table.concat(where, ' and ') or 'the authors\' institution')
            if entry.email then sentence = sentence .. ' (e-mail: ' .. entry.email .. ')' end
            notes[#notes + 1] = '\\thanks{' .. sentence .. '.}'
          end
          body[#body + 1] = '\\author{' .. table.concat(listed, ', ') .. table.concat(notes, '%\n') .. '}'
        end
        for _, entry in ipairs(authors) do names[#names + 1] = entry.name end
      end
      body[#body + 1] = '\\maketitle'
      local abstract = to_latex(meta.abstract)
      if abstract then body[#body + 1] = '\\begin{abstract}\n' .. abstract .. '\n\\end{abstract}' end
      local keywords = {}
      for _, word in ipairs(as_list(meta.keywords)) do keywords[#keywords + 1] = to_latex(word) end
      if #keywords > 0 then
        body[#body + 1] = '\\begin{IEEEkeywords}\n' .. table.concat(keywords, ', ') .. '\n\\end{IEEEkeywords}'
      end
      append_blocks(meta, 'include-before', table.concat(body, '\n'))

      -- Pandoc's citeproc output goes through \cite and \bibitem[label]; the class redefines both. The citation style
      -- already made the text, so a citation is that text and \bibitem is an \item.
      append_blocks(meta, 'header-includes',
        '\\AtBeginDocument{\\DeclareDocumentCommand\\citeproc{mm}{#2}\\renewcommand{\\bibitem}[2][]{\\item}}')

      if title then meta['title-meta'] = pandoc.MetaString(plain(meta.title)) end
      if #names > 0 then meta['author-meta'] = pandoc.MetaString(table.concat(names, ', ')) end
      meta.title, meta.author, meta.abstract = nil, nil, nil
      return meta
    end },
}
