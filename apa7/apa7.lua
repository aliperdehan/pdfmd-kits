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
--   abstractname             the abstract's heading (Abstract); jou, which prints none, gets one when this is set
--   authornote               the author note of a manuscript
--   titleoffset              how far down the title page the title starts: lines (4) or a length (2in, 5cm)
--   coverpage                true: a plain cover page before the title page; a file name: that PDF's pages instead
--
-- The filter only runs for LaTeX output and only when the document class is apa7.
--
-- In stu and man it also sets the 0.5 in body indent and reference hang in the header (the class sets its indent only inside
-- \maketitle, which a partial build skips), starts each "Appendix X: Title" heading on a new page with tables numbered X1,
-- X2 ... (APA 7), and sets a paragraph that starts with the italic word "Note." flush left.
--
-- In every mode a figure's caption is written above the image (APA 7: the number in bold, the title in italics, the image,
-- then a note), and a "Note." paragraph right after a figure goes into the figure, so that it stays below the image when
-- the figure floats or, in stu and man, is held back to the end of the paper.

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

-- The space above the title, as \maketitle of each mode writes it (stu and man share one \maketitle).
local TITLE_SPACE = {
  stu = '\\vspace*{4\\baselineskip}', man = '\\vspace*{4\\baselineskip}',
  doc = '\\vspace*{0.3in}', jou = '\\vspace{0.03in}',
}
local UNITS = { ['in'] = true, cm = true, mm = true, pt = true, em = true }

-- titleoffset: a bare number is lines (the class's \baselineskip), a number with a unit is a length
local function title_offset(value)
  local text = utils.stringify(value):gsub('^%s+', ''):gsub('%s+$', '')
  local number = text:match('^%d*%.?%d+$')
  if number then return number .. '\\baselineskip' end
  local amount, unit = text:match('^(%d*%.?%d+)%s*(%a+)$')
  if amount and UNITS[unit] then return amount .. unit end
  error('apa7 kit: titleoffset: "' .. text .. '" is neither a number of lines (4) nor a length (2in, 5cm, 40mm, 72pt, 3em)', 0)
end

-- coverpage: true writes a plain page (title, authors, course, professor, due date); a file name puts that PDF's pages
-- (pdfpages) in front. Either is put in front of the title page by \maketitle, so a partial build without a title page
-- has no cover either. The cover has no running head and no page number, and the title page stays page 1 (APA 7).
local function cover_page(meta, names)
  local value = meta.coverpage
  if value == nil then return nil end
  local text = kind(value) == 'boolean' and tostring(value) or utils.stringify(value)
  text = text:gsub('^%s+', ''):gsub('%s+$', '')
  local word = text:lower()
  if word == 'false' or word == 'no' or word == '' then return nil end
  if word == 'true' or word == 'yes' then
    local authors = {}
    for i, name in ipairs(names) do authors[i] = to_latex(pandoc.Str(name)) or name end
    local by = table.concat(authors, ', ')
    if #authors == 2 then by = authors[1] .. ' and ' .. authors[2]
    elseif #authors > 2 then by = table.concat(authors, ', ', 1, #authors - 1) .. ', and ' .. authors[#authors] end
    local parts = { '\\begin{titlepage}\\centering\\vspace*{\\fill}' }
    local title = to_latex(meta.title)
    if title then parts[#parts + 1] = '{\\large\\bfseries ' .. title .. '\\par}\\vspace{2\\baselineskip}' end
    if by ~= '' then parts[#parts + 1] = by .. '\\par\\vspace{2\\baselineskip}' end
    local fields = { meta.course, meta.professor or meta.instructor, meta.duedate or meta.date }
    for i = 1, 3 do
      local line = to_latex(fields[i])
      if line then parts[#parts + 1] = line .. '\\par ' end
    end
    parts[#parts + 1] = '\\vspace*{\\fill}\\end{titlepage}'
    return table.concat(parts), false
  end
  if text:match('[{}\\%%#]') then
    error('apa7 kit: coverpage: "' .. text .. '" is neither true nor a file name (a PDF beside the document)', 0)
  end
  return '\\IfFileExists{' .. text .. '}{\\includepdf[pages=-]{' .. text .. '}}{\\PackageError{apa7.lua}'
    .. '{coverpage: ' .. text .. ' not found}{Put the PDF beside the document, or write coverpage: true for a plain cover page.}}',
    true
end

local function Meta(meta)
  if not FORMAT:match('latex') and not FORMAT:match('beamer') then return nil end
  if plain(meta.documentclass) ~= 'apa7' then return nil end

  local mode = 'jou'                         -- the class's own default when no mode option is given
  for _, name in ipairs({ 'stu', 'man', 'doc' }) do
    if has_option(meta, name) then mode = name break end
  end

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

  -- titleoffset: the class's own space above the title is replaced (etoolbox; \maketitle is read with @ a letter)
  if meta.titleoffset ~= nil then
    lines[#lines + 1] = '\\usepackage{etoolbox}\\makeatletter\\patchcmd{\\maketitle}{' .. TITLE_SPACE[mode] .. '}'
      .. '{\\vspace*{' .. title_offset(meta.titleoffset) .. '}}{}'
      .. '{\\PackageWarningNoLine{apa7.lua}{titleoffset: not applied, the class\'s title page has changed}}\\makeatother'
  end

  local keywords = {}
  for _, word in ipairs(as_list(meta.keywords)) do
    keywords[#keywords + 1] = to_latex(word)
  end
  if #keywords > 0 then emit('keywords', table.concat(keywords, ', ')) end

  -- the abstract moves into the preamble; Pandoc's own abstract environment is dropped
  local abstract = to_latex(meta.abstract)
  -- abstractname: the heading's text. babel sets \abstractname when the document begins, so it is set after that. The
  -- class prints no heading in jou; there the abstract starts with the name, centred.
  local abstractname = to_latex(meta.abstractname)
  if abstractname then
    lines[#lines + 1] = '\\AtBeginDocument{\\renewcommand{\\abstractname}{' .. abstractname .. '}}'
    if mode == 'jou' and abstract then abstract = '{\\centering\\abstractname\\par}' .. abstract end
  end
  emit('abstract', abstract)

  local cover, from_file = cover_page(meta, names)
  if cover then
    if from_file then lines[#lines + 1] = '\\usepackage{pdfpages}' end
    lines[#lines + 1] = '\\let\\apaKitMaketitle\\maketitle\\renewcommand{\\maketitle}{\\pagenumbering{alph}'
      .. cover .. '\\clearpage\\pagenumbering{arabic}\\apaKitMaketitle}'
  end

  if #names > 0 then meta['author-meta'] = pandoc.MetaString(table.concat(names, ', ')) end
  meta.author, meta.abstract = nil, nil

  -- apa7.cls sets \parindent only inside \maketitle, which a partial build skips (the title is dropped below), and
  -- Pandoc's CSL list hangs references by 1.5em. APA 7 wants 0.5 in for both.
  if has_option(meta, 'stu') or has_option(meta, 'man') then
    lines[#lines + 1] = '\\AtBeginDocument{\\raggedright\\setlength{\\parindent}{0.5in}'
      .. '\\ifdefined\\cslhangindent\\setlength{\\cslhangindent}{0.5in}\\fi}'
  end

  local includes = as_list(meta['header-includes'])
  local merged = pandoc.MetaList({})
  for _, item in ipairs(includes) do merged[#merged + 1] = item end
  merged[#merged + 1] = pandoc.MetaBlocks({ pandoc.RawBlock('latex', table.concat(lines, '\n')) })
  meta['header-includes'] = merged

  -- A partial build (`pdfmd report#methods`, a part's path: pdfmd sets `pdfmd-partial`) is for reading one
  -- section, so the title page is dropped, as nulabreport does. Pandoc calls \maketitle only when there is a
  -- title; it stays as `title-meta` for the PDF properties. `partial-title: true` in the front matter keeps it.
  local partial, keep = meta['pdfmd-partial'], meta['partial-title']
  if partial and utils.stringify(partial) == 'true'
      and not (keep and utils.stringify(keep) == 'true') and meta.title then
    if not meta['title-meta'] then meta['title-meta'] = pandoc.MetaString(utils.stringify(meta.title)) end
    meta.title = nil
  end
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
  -- "Appendix A: Title": a page of its own, and its tables are numbered A1, A2 ... (APA 7)
  local letter = utils.stringify(header):match('^Appendix (%u)%f[%W]')
  if letter then
    -- stu and man hold figures back to the end (endfloat): the body's figures are put out before the first appendix, with
    -- their own numbers, and an appendix's figures stay in its text, as the class's own \appendix does
    return { pandoc.RawBlock('latex', '\\clearpage'
      .. '\\ifdefined\\processdelayedfloats\\processdelayedfloats\\clearpage\\fi\\ifdefined\\appendixtrue\\appendixtrue\\fi'
      .. '\\setcounter{table}{0}\\setcounter{figure}{0}'
      .. '\\renewcommand{\\thetable}{' .. letter .. '\\arabic{table}}'
      .. '\\renewcommand{\\thefigure}{' .. letter .. '\\arabic{figure}}'), header }
  end
end

-- Table and figure notes (a paragraph that starts with the italic word "Note.") are flush left in APA 7.
local function Para(para)
  local first = para.content[1]
  if paged and first and first.t == 'Emph' and utils.stringify(first) == 'Note.' then
    table.insert(para.content, 1, pandoc.RawInline('latex', '\\noindent '))
    return para
  end
end

-- A figure: Pandoc writes the caption below the image; APA 7 wants it above (the class styles it: the number in bold on
-- a line of its own, the title in italics below it), and a note below the image. The caption stays Pandoc inlines (a
-- citation in it is still a citation). A figure of several images (subfigures) is left as Pandoc writes it.
local apa
local function is_note(block)
  if not block or block.t ~= 'Para' then return false end
  local first = block.content[1]
  return first and first.t == 'Emph' and utils.stringify(first) == 'Note.'
end

local function caption_first(figure, note)
  local long = utils.blocks_to_inlines(figure.caption.long or {})
  local short = figure.caption.short
  local caption = pandoc.List({ pandoc.RawInline('latex', '\\caption') })
  if short and #short > 0 then
    caption:insert(pandoc.RawInline('latex', '[{'))
    caption:extend(short)
    caption:insert(pandoc.RawInline('latex', '}]'))
  end
  caption:insert(pandoc.RawInline('latex', '{'))
  caption:extend(long)
  caption:insert(pandoc.RawInline('latex', '}'))
  if figure.identifier ~= '' then
    caption:insert(pandoc.RawInline('latex', '\\label{' .. figure.identifier .. '}'))
  end
  local placement = figure.attributes['latex-placement']
  local blocks = pandoc.List({
    pandoc.RawBlock('latex', '\\begin{figure}' .. (placement and ('[' .. placement .. ']') or '')),
    pandoc.Plain(caption),
    pandoc.RawBlock('latex', '{\\centering'),
    figure.content[1],
    pandoc.RawBlock('latex', '\\par}'),
  })
  if note then blocks:insert(note) end
  blocks:insert(pandoc.RawBlock('latex', '\\end{figure}'))
  return blocks
end

local function Blocks(blocks)
  if not apa then return nil end
  local out, changed, i = pandoc.List(), false, 1
  while i <= #blocks do
    local block = blocks[i]
    if block.t == 'Figure' and #block.content == 1 and (block.content[1].t == 'Plain' or block.content[1].t == 'Para')
        and #utils.blocks_to_inlines(block.caption.long or {}) > 0 then
      local note = is_note(blocks[i + 1]) and blocks[i + 1] or nil
      out:extend(caption_first(block, note))
      if note then i = i + 1 end
      changed = true
    else
      out:insert(block)
    end
    i = i + 1
  end
  if changed then return out end
end

return {
  { Meta = function(meta)
      paged = has_option(meta, 'man') or has_option(meta, 'stu')
      apa = (FORMAT:match('latex') ~= nil) and plain(meta.documentclass) == 'apa7'
      return Meta(meta)
    end },
  { Blocks = Blocks },
  { Header = Header, Para = Para },
}
