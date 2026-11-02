-- llncs.lua: front matter -> the title block of the llncs class (Springer LNCS).
--
-- llncs wants \author{Name\inst{1} \and Name\inst{2,3}}, \institute{First \and Second} and, in the abstract,
-- \keywords{a \and b}. Pandoc's template writes the \author line from the `author` list, so each author becomes
-- "name + \inst{..}" and the institutes go into the preamble.
--
--   author        a name, a list, or maps {name, email, affiliation}
--   affiliation   one or a list (an author points at it by number or text; one affiliation in all is shared)
--   keywords      a list; they are written inside the abstract, as llncs wants
--
-- With the class option runningheads, \titlerunning and \authorrunning are set from the title and the authors.
-- Only for LaTeX output and only when the document class is llncs.

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
      if plain(meta.documentclass) ~= 'llncs' then return nil end

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

      local names, authors, emails = {}, pandoc.MetaList({}), {}
      for _, author in ipairs(as_list(meta.author)) do
        local name, email, refs
        if utils.type(author) == 'table' then
          name, email = plain(author.name), plain(author.email)
          refs = author.affiliation or author.affiliations
        else
          name = plain(author)
        end
        if name then
          names[#names + 1] = name
          local numbers = {}
          for _, ref in ipairs(as_list(refs)) do
            local index = affiliation_index(ref)
            if index then numbers[#numbers + 1] = tostring(index) end
          end
          if #numbers == 0 and shared then numbers = { '1' } end
          local inlines = pandoc.Inlines({ pandoc.Str(name) })
          if #numbers > 0 then
            inlines:insert(pandoc.RawInline('latex', '\\inst{' .. table.concat(numbers, ',') .. '}'))
          end
          authors[#authors + 1] = pandoc.MetaInlines(inlines)
          if email and #numbers > 0 then
            local first = tonumber(numbers[1])
            emails[first] = emails[first] or {}
            table.insert(emails[first], email)
          end
        end
      end

      local preamble = {
        '\\AtBeginDocument{\\DeclareDocumentCommand\\citeproc{mm}{#2}\\renewcommand{\\bibitem}[2][]{\\item}}',
      }
      if #affiliations > 0 then
        local institutes = {}
        for i, text in ipairs(affiliations) do
          if emails[i] then text = text .. '\\\\\n\\email{' .. table.concat(emails[i], ', ') .. '}' end
          institutes[#institutes + 1] = text
        end
        preamble[#preamble + 1] = '\\institute{' .. table.concat(institutes, '\n\\and\n') .. '}'
      end
      if has_option(meta, 'runningheads') then
        local title = to_latex(meta.title)
        if title then preamble[#preamble + 1] = '\\titlerunning{' .. title .. '}' end
        if #names > 0 then
          local surname = names[1]:match('(%S+)%s*$') or names[1]
          local running = (#names == 1) and names[1] or (surname .. ' et al.')
          preamble[#preamble + 1] = '\\authorrunning{' .. (to_latex(pandoc.Str(running)) or running) .. '}'
        end
      end
      append_blocks(meta, 'header-includes', table.concat(preamble, '\n'))

      -- keywords belong inside the abstract
      local keywords = {}
      for _, word in ipairs(as_list(meta.keywords)) do keywords[#keywords + 1] = to_latex(word) end
      if #keywords > 0 and meta.abstract then
        local blocks = pandoc.Blocks({})
        local t = utils.type(meta.abstract)
        if t == 'Blocks' then
          for _, block in ipairs(meta.abstract) do blocks:insert(block) end
        else
          blocks:insert(pandoc.Plain(pandoc.Inlines(meta.abstract)))
        end
        blocks:insert(pandoc.RawBlock('latex', '\\keywords{' .. table.concat(keywords, ' \\and ') .. '}'))
        meta.abstract = pandoc.MetaBlocks(blocks)
      end

      if #names > 0 then
        meta.author = authors
        meta['author-meta'] = pandoc.MetaString(table.concat(names, ', '))
      end
      return meta
    end },
}
