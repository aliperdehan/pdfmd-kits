-- apa7.lua: front matter -> the setter commands of the apa7 LaTeX class.
--
-- Pandoc's LaTeX template writes \author{..}, \date{..} and \begin{abstract}..\end{abstract}. apa7 wants
-- \authorsnames, \authorsaffiliations, \duedate, \course, \professor, \shorttitle, \keywords and a preamble
-- \abstract{..}. This filter reads the usual keys and writes those commands into `header-includes`:
--
--   title, shorttitle        the running head defaults to the title
--   author                   a name, a list of names, or maps {name, affiliation}
--   affiliation              one affiliation or a list (authors point at them by number or by text)
--   course, professor        title-page fields of the student paper (instructor: is accepted for professor:)
--   duedate                  the date on the title page (date: is used when there is none)
--   abstract, keywords       keywords may be a list
--   authornote               the author note of a manuscript
--
-- The filter only runs for LaTeX output and only when the document class is apa7.

local utils = pandoc.utils

local function kind(value)
  return utils.type(value)
end

local function to_latex(value)
  if value == nil then return nil end
  local doc
  local t = kind(value)
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
  if kind(value) == 'List' then return value end
  return { value }
end

local function plain(value)
  if value == nil then return nil end
  local s = utils.stringify(value)
  if s == '' then return nil end
  return s
end

local function has_option(meta, wanted)
  for _, option in ipairs(as_list(meta.classoption)) do
    if utils.stringify(option) == wanted then return true end
  end
  return false
end

local function Meta(meta)
  if not FORMAT:match('latex') and not FORMAT:match('beamer') then return nil end
  if plain(meta.documentclass) ~= 'apa7' then return nil end

  local lines = {}
  local function emit(command, value)
    if value then lines[#lines + 1] = string.format('\\%s{%s}', command, value) end
  end

  -- affiliations: top-level list first, authors may add more by text
  local affiliations = {}
  local texts = {}
  local function affiliation_index(entry)
    local key = utils.stringify(entry)
    local number = tonumber(key)
    if number and affiliations[number] then return number end
    for i, text in ipairs(texts) do
      if text == key then return i end
    end
    local value = to_latex(kind(entry) == 'table' and entry.name or entry)
    if not value then return nil end
    affiliations[#affiliations + 1] = value
    texts[#texts + 1] = key
    return #affiliations
  end
  for _, entry in ipairs(as_list(meta.affiliation)) do
    affiliation_index(entry)
  end
  local declared = #affiliations

  -- authors
  local names, superscripts, any_superscript = {}, {}, false
  for _, author in ipairs(as_list(meta.author)) do
    local name, refs
    if kind(author) == 'table' then
      name = plain(author.name)
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
      if #numbers > 0 then
        any_superscript = true
        superscripts[#names] = #numbers == 1 and numbers[1] or '{' .. table.concat(numbers, ',') .. '}'
      else
        superscripts[#names] = ''
      end
    end
  end
  if #names > 0 then
    -- the class splits the names at commas; a comma inside a name would split it, so none is written
    local escaped = {}
    for i, name in ipairs(names) do
      local clean = name:gsub(',', '')
      escaped[i] = to_latex(pandoc.Str(clean)) or clean
    end
    local optional = ''
    if any_superscript and #affiliations > 1 then
      optional = '[' .. table.concat(superscripts, ',') .. ']'
    end
    lines[#lines + 1] = '\\authorsnames' .. optional .. '{' .. table.concat(escaped, ', ') .. '}'
    -- Pandoc's template still writes \author{..} after the header, and apa7 turns \author into a second
    -- \authorsnames, which stops with "Command \c@NumberOfAuthors already defined": it is made empty here
    lines[#lines + 1] = '\\long\\def\\author#1{}'
  end
  if #affiliations > 0 then
    local items = {}
    for i, text in ipairs(affiliations) do items[i] = '{' .. text .. '}' end
    lines[#lines + 1] = '\\authorsaffiliations{' .. table.concat(items, ', ') .. '}'
  end

  -- the rest of the title page
  local title = plain(meta.title)
  emit('shorttitle', to_latex(meta.shorttitle) or (title and to_latex(pandoc.Str(title))))
  emit('course', to_latex(meta.course))
  emit('professor', to_latex(meta.professor or meta.instructor))
  emit('duedate', to_latex(meta.duedate or meta.date))
  emit('authornote', to_latex(meta.authornote))

  local keywords = {}
  for _, word in ipairs(as_list(meta.keywords)) do
    keywords[#keywords + 1] = to_latex(word)
  end
  if #keywords > 0 then emit('keywords', table.concat(keywords, ', ')) end

  -- the abstract moves into the preamble; Pandoc's own abstract environment is dropped
  emit('abstract', to_latex(meta.abstract))

  if #names > 0 then meta['author-meta'] = pandoc.MetaString(table.concat(names, ', ')) end
  meta.author, meta.abstract = nil, nil

  local includes = as_list(meta['header-includes'])
  local merged = pandoc.MetaList({})
  for _, item in ipairs(includes) do merged[#merged + 1] = item end
  merged[#merged + 1] = pandoc.MetaBlocks({ pandoc.RawBlock('latex', table.concat(lines, '\n')) })
  meta['header-includes'] = merged
  return meta
end

-- The reference list starts a page of its own in the papers that are double-spaced.
local paged
local function Header(header)
  if header.level ~= 1 then return nil end
  if not paged then return nil end
  local text = utils.stringify(header):lower()
  if text == 'references' or text == 'reference list' then
    return { pandoc.RawBlock('latex', '\\clearpage'), header }
  end
end

return {
  { Meta = function(meta)
      paged = has_option(meta, 'man') or has_option(meta, 'stu')
      return Meta(meta)
    end },
  { Header = Header },
}
