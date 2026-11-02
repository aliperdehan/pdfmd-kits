-- mla.lua: front matter -> the heading block of the mla class.
--
-- mla prints "Name / Professor / Course / Date" and a running head from \author, \professor, \course and \date.
-- Pandoc's template already writes \title, \author and \date; this adds \professor and \course, makes the date
-- today's (MLA style, \mladate) when none is given, and settles the citations.
--
--   author, title
--   professor (or instructor), course
--   date          the class's own date format of today when left out
--
-- Only for LaTeX output and only when the document class is mla.

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
      if plain(meta.documentclass) ~= 'mla' then return nil end

      local lines = {
        -- Pandoc's citeproc output goes through \cite and \bibitem[label]; biblatex (which the class loads) redefines both.
        -- The citation style already made the text, so a citation is that text and \bibitem is an \item.
        '\\AtBeginDocument{\\DeclareDocumentCommand\\citeproc{mm}{#2}\\renewcommand{\\bibitem}[2][]{\\item}}',
      }
      local professor = to_latex(meta.professor or meta.instructor)
      if professor then lines[#lines + 1] = '\\professor{' .. professor .. '}' end
      local course = to_latex(meta.course)
      if course then lines[#lines + 1] = '\\course{' .. course .. '}' end
      append_blocks(meta, 'header-includes', table.concat(lines, '\n'))

      if not meta.date then
        meta.date = pandoc.MetaInlines({ pandoc.RawInline('latex', '\\mladate') })
      end
      -- one author, as MLA has: several are joined
      local names = {}
      for _, author in ipairs(as_list(meta.author)) do
        local name = plain(utils.type(author) == 'table' and author.name or author)
        if name then names[#names + 1] = name end
      end
      if #names > 0 then
        meta.author = pandoc.MetaInlines({ pandoc.Str(table.concat(names, ', ')) })
        meta['author-meta'] = pandoc.MetaString(table.concat(names, ', '))
      end
      return meta
    end },
}
