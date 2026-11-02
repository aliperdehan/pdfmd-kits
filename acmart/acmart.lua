-- acmart.lua: front matter -> the title block of the acmart class (ACM).
--
-- acmart wants \title, one \author{..} per author each followed by \affiliation{\institution{..}} and \email{..},
-- \begin{abstract} and \keywords{..} BEFORE \maketitle. Pandoc's template writes \author{A \and B} and the abstract
-- after \maketitle. The block is written through `include-before` (right after \begin{document}) and Pandoc's own title,
-- author and abstract are dropped. The ACM reference-format block and the copyright notice are switched off.
--
--   author        a name, a list, or maps {name, email, affiliation}
--   affiliation   one or a list: a text, or a map {institution, department, city, state, postcode, country}
--                 (an author points at it by number or text; one affiliation in all is shared)
--   abstract, keywords
--   acmconference  text for \acmConference[..]{..}{..}{..}: the four arguments as a list (short name, name, date, place)
--   acmjournal     the short name for \acmJournal{..}
--
-- Only for LaTeX output and only when the document class is acmart.

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
      if plain(meta.documentclass) ~= 'acmart' then return nil end

      local affiliations, texts = {}, {}
      local function affiliation_index(entry)
        local key = utils.stringify(entry)
        local number = tonumber(key)
        if number and affiliations[number] then return number end
        for i, text in ipairs(texts) do
          if text == key then return i end
        end
        -- an affiliation is a text, or a map {institution, department, city, state, postcode, country}; acmart stops
        -- without a country
        local value
        if utils.type(entry) == 'table' then
          local parts = {}
          for _, field in ipairs({ 'department', 'institution', 'city', 'state', 'postcode', 'country' }) do
            local text = to_latex(entry[field])
            if text then parts[#parts + 1] = '\\' .. field .. '{' .. text .. '}' end
          end
          if not entry.country then parts[#parts + 1] = '\\country{~}' end
          value = #parts > 0 and table.concat(parts) or to_latex(entry.name)
          if value and not value:find('\\institution', 1, true) and entry.name then
            value = '\\institution{' .. to_latex(entry.name) .. '}' .. value
          end
        else
          -- acmart prints institution, city, country joined by commas and ignores an empty country; the last part of a
          -- text is taken as the country, which prints the same line (a map gives the parts one by one)
          local text = to_latex(entry)
          if text then
            local head, tail = text:match('^(.*),%s*([^,]+)$')
            if head then
              value = '\\institution{' .. head .. '}\\country{' .. tail .. '}'
            else
              value = '\\institution{' .. text .. '}\\country{~}'
            end
          end
        end
        if not value then return nil end
        affiliations[#affiliations + 1] = value
        texts[#texts + 1] = key
        return #affiliations
      end
      for _, entry in ipairs(as_list(meta.affiliation)) do affiliation_index(entry) end
      local shared = (#affiliations == 1) and 1 or nil

      local body = {}
      local title = to_latex(meta.title)
      if title then body[#body + 1] = '\\title{' .. title .. '}' end
      local names = {}
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
          body[#body + 1] = '\\author{' .. (to_latex(pandoc.Str(name)) or name) .. '}'
          local used = {}
          for _, ref in ipairs(as_list(refs)) do
            local index = affiliation_index(ref)
            if index then used[#used + 1] = index end
          end
          if #used == 0 and shared then used = { shared } end
          for _, index in ipairs(used) do
            body[#body + 1] = '\\affiliation{' .. affiliations[index] .. '}'
          end
          if email then body[#body + 1] = '\\email{' .. email .. '}' end
        end
      end
      local abstract = to_latex(meta.abstract)
      if abstract then body[#body + 1] = '\\begin{abstract}\n' .. abstract .. '\n\\end{abstract}' end
      local keywords = {}
      for _, word in ipairs(as_list(meta.keywords)) do keywords[#keywords + 1] = to_latex(word) end
      if #keywords > 0 then body[#body + 1] = '\\keywords{' .. table.concat(keywords, ', ') .. '}' end
      body[#body + 1] = '\\maketitle'
      append_blocks(meta, 'include-before', table.concat(body, '\n'))

      local preamble = {
        -- Pandoc's citeproc output goes through \cite and \bibitem[label]; the class redefines both. The citation style
        -- already made the text, so a citation is that text and \bibitem is an \item.
        '\\AtBeginDocument{\\DeclareDocumentCommand\\citeproc{mm}{#2}\\renewcommand{\\bibitem}[2][]{\\item}}',
        -- Pandoc's template always writes \author{} and \date{} in the preamble; here they do nothing, the real ones are
        -- back when the document begins
        '\\let\\pdfmdauthor\\author\n\\renewcommand{\\author}[2][]{}\n\\AtBeginDocument{\\let\\author\\pdfmdauthor}',
        '\\let\\pdfmddate\\date\n\\renewcommand{\\date}[1]{}\n\\AtBeginDocument{\\let\\date\\pdfmddate}',
      }
      local conference = as_list(meta.acmconference)
      local journal = to_latex(meta.acmjournal)
      if #conference == 4 then
        preamble[#preamble + 1] = '\\acmConference[' .. to_latex(conference[1]) .. ']{' .. to_latex(conference[2]) .. '}{'
          .. to_latex(conference[3]) .. '}{' .. to_latex(conference[4]) .. '}'
      elseif journal then
        preamble[#preamble + 1] = '\\acmJournal{' .. journal .. '}'
      else
        -- no venue: no copyright notice and no reference-format block
        preamble[#preamble + 1] = '\\setcopyright{none}\n\\settopmatter{printacmref=false}\n'
          .. '\\renewcommand\\footnotetextcopyrightpermission[1]{}'
      end
      append_blocks(meta, 'header-includes', table.concat(preamble, '\n'))

      if title then meta['title-meta'] = pandoc.MetaString(plain(meta.title)) end
      if #names > 0 then meta['author-meta'] = pandoc.MetaString(table.concat(names, ', ')) end
      meta.title, meta.author, meta.abstract = nil, nil, nil
      return meta
    end },
}
