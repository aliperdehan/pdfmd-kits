-- achemso.lua: front matter -> the title block of the achemso class.
--
-- achemso wants one \author{..} per author (with \email{..} for a corresponding author), each group of authors
-- followed by their \affiliation{..} (and \alsoaffiliation{..} for a second one), \keywords{..}, \abbreviations{..},
-- and the target journal as a class option. Pandoc's template writes one \author{A \and B}, which achemso cannot read.
--
--   author        a name, a list of names, or maps {name, email, phone, fax, affiliation}
--   affiliation   one affiliation or a list (an author points at it by number or by text; with one affiliation
--                 in all, every author without his own gets it)
--   keywords      a list or a text
--   abbreviations a list or a text
--   journal       the class option journal=, "jacsat" when nothing says otherwise (metadata.yaml of the kit)
--
-- Only for LaTeX output and only when the document class is achemso.

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

local function join_list(value)
  local items = {}
  for _, item in ipairs(as_list(value)) do items[#items + 1] = to_latex(item) end
  if #items == 0 then return nil end
  return table.concat(items, ', ')
end

local function has_prefix(meta, prefix)
  for _, option in ipairs(as_list(meta.classoption)) do
    if utils.stringify(option):sub(1, #prefix) == prefix then return true end
  end
  return false
end

return {
  { Meta = function(meta)
      if not FORMAT:match('latex') and not FORMAT:match('beamer') then return nil end
      if plain(meta.documentclass) ~= 'achemso' then return nil end

      local lines = {}
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

      -- the authors, in order, each with the list of his affiliations
      local authors = {}
      for _, author in ipairs(as_list(meta.author)) do
        local entry = { refs = {} }
        local refs
        if utils.type(author) == 'table' then
          entry.name = plain(author.name)
          entry.email, entry.phone, entry.fax = plain(author.email), plain(author.phone), plain(author.fax)
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

      -- consecutive authors with the same affiliations are one group: \affiliation applies to all before it
      local function key_of(entry) return table.concat(entry.refs, ',') end
      for i, entry in ipairs(authors) do
        lines[#lines + 1] = '\\author{' .. (to_latex(pandoc.Str(entry.name)) or entry.name) .. '}'
        if entry.email then lines[#lines + 1] = '\\email{' .. entry.email .. '}' end
        if entry.phone then lines[#lines + 1] = '\\phone{' .. entry.phone .. '}' end
        if entry.fax then lines[#lines + 1] = '\\fax{' .. entry.fax .. '}' end
        local following = authors[i + 1]
        if (following == nil or key_of(following) ~= key_of(entry)) and #entry.refs > 0 then
          lines[#lines + 1] = '\\affiliation{' .. affiliations[entry.refs[1]] .. '}'
          for j = 2, #entry.refs do
            lines[#lines + 1] = '\\alsoaffiliation{' .. affiliations[entry.refs[j]] .. '}'
          end
        end
      end
      -- Pandoc's template writes \author{..} once more, and achemso would take that for another author
      lines[#lines + 1] = '\\makeatletter\\let\\author\\@gobble\\makeatother'

      -- Pandoc's citeproc output goes through \cite and \bibitem[label]; achemso redefines both and prints "code" for
      -- the label. The citation style already made the text, so the citation is that text and \bibitem is an \item.
      lines[#lines + 1] = '\\AtBeginDocument{\\DeclareDocumentCommand\\citeproc{mm}{#2}\\renewcommand{\\bibitem}[2][]{\\item}}'

      local keywords = join_list(meta.keywords)
      if keywords then lines[#lines + 1] = '\\keywords{' .. keywords .. '}' end
      local abbreviations = join_list(meta.abbreviations)
      if abbreviations then lines[#lines + 1] = '\\abbreviations{' .. abbreviations .. '}' end

      local names = {}
      for _, entry in ipairs(authors) do names[#names + 1] = entry.name end
      if #names > 0 then meta['author-meta'] = pandoc.MetaString(table.concat(names, ', ')) end
      meta.author = nil

      -- the target journal is a class option
      local journal = plain(meta.journal)
      if journal and not has_prefix(meta, 'journal=') then
        local options = pandoc.MetaList({})
        for _, option in ipairs(as_list(meta.classoption)) do options[#options + 1] = option end
        options[#options + 1] = pandoc.MetaString('journal=' .. journal)
        meta.classoption = options
      end

      local merged = pandoc.MetaList({})
      for _, item in ipairs(as_list(meta['header-includes'])) do merged[#merged + 1] = item end
      merged[#merged + 1] = pandoc.MetaBlocks({ pandoc.RawBlock('latex', table.concat(lines, '\n')) })
      meta['header-includes'] = merged
      return meta
    end },
}
