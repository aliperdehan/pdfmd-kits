-- moderncv.lua: front matter and two div classes -> a moderncv curriculum vitae.
--
-- Front matter (all optional but the name):
--   name           "Ada Example" (the last word is the family name), or firstname: / lastname:
--   title          the line under the name
--   address        a text, or a list of up to three lines: street, "postcode city", country
--   phone          a text, or a map {mobile: .., fixed: .., fax: ..}
--   email, homepage
--   social         a map {linkedin: .., github: .., orcid: ..}: the services moderncv knows
--   photo          a picture file; photoheight: its height (64pt)
--   quote, extrainfo
--   cvstyle        casual, classic, banking, oldstyle, fancy, contemporary (the mode of the kit sets it)
--   cvcolor        blue by default
--
-- In the text a heading is a \section, and two fenced divs are the CV's own blocks:
--   ::: {.cventry years="2020--2024" title="BSc Chemistry" institution="Example University" city="Example City" grade="GPA 3.9"}
--   A line of description, or a short list.
--   :::
--   ::: {.cvitem label="Languages"}
--   English, Russian, Kazakh
--   :::
--
-- Only for LaTeX output and only when the document class is moderncv.

local utils = pandoc.utils
local active = false

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

local function meta_filter(meta)
  if not FORMAT:match('latex') then return nil end
  if plain(meta.documentclass) ~= 'moderncv' then return nil end
  active = true

  local lines = {}
  lines[#lines + 1] = '\\moderncvstyle{' .. (plain(meta.cvstyle) or 'casual') .. '}'
  lines[#lines + 1] = '\\moderncvcolor{' .. (plain(meta.cvcolor) or 'blue') .. '}'

  local first, last = plain(meta.firstname), plain(meta.lastname)
  local name = plain(utils.type(meta.name) == 'table' and meta.name.name or meta.name)
  if not (first and last) and name then
    first, last = name:match('^(.-)%s*(%S+)$')
    first, last = first or '', last or name
  end
  if first or last then
    lines[#lines + 1] = '\\name{' .. (to_latex(pandoc.Str(first or '')) or '') .. '}{'
      .. (to_latex(pandoc.Str(last or '')) or '') .. '}'
  end
  local title = to_latex(meta.title)
  if title then lines[#lines + 1] = '\\title{' .. title .. '}' end

  local address = as_list(meta.address)
  if #address > 0 then
    local parts = {}
    for i = 1, 3 do parts[i] = to_latex(address[i]) or '' end
    lines[#lines + 1] = '\\address{' .. parts[1] .. '}{' .. parts[2] .. '}{' .. parts[3] .. '}'
  end
  if meta.phone then
    if utils.type(meta.phone) == 'table' then
      for _, kind in ipairs({ 'mobile', 'fixed', 'fax' }) do
        local number = to_latex(meta.phone[kind])
        if number then lines[#lines + 1] = '\\phone[' .. kind .. ']{' .. number .. '}' end
      end
    else
      lines[#lines + 1] = '\\phone[mobile]{' .. to_latex(meta.phone) .. '}'
    end
  end
  local email = plain(meta.email)
  if email then lines[#lines + 1] = '\\email{' .. email .. '}' end
  local homepage = plain(meta.homepage)
  if homepage then lines[#lines + 1] = '\\homepage{' .. homepage .. '}' end
  if utils.type(meta.social) == 'table' then
    local services = {}
    for service in pairs(meta.social) do services[#services + 1] = service end
    table.sort(services)
    for _, service in ipairs(services) do
      lines[#lines + 1] = '\\social[' .. service .. ']{' .. (plain(meta.social[service]) or ''):gsub('_', '\\_') .. '}'
    end
  end
  local photo = plain(meta.photo)
  if photo then
    lines[#lines + 1] = '\\photo[' .. (plain(meta.photoheight) or '64pt') .. '][0.4pt]{' .. photo .. '}'
  end
  local quote = to_latex(meta.quote)
  if quote then lines[#lines + 1] = '\\quote{' .. quote .. '}' end
  local extra = to_latex(meta.extrainfo)
  if extra then lines[#lines + 1] = '\\extrainfo{' .. extra .. '}' end
  append_blocks(meta, 'header-includes', table.concat(lines, '\n'))
  append_blocks(meta, 'include-before', '\\makecvtitle')

  if first or last then
    meta['author-meta'] = pandoc.MetaString(((first or '') .. ' ' .. (last or '')):gsub('^%s+', ''))
  end
  if title then meta['title-meta'] = pandoc.MetaString(plain(meta.title)) end
  meta.title, meta.author, meta.date = nil, nil, nil
  return meta
end

local function div_filter(div)
  if not active then return nil end
  -- an attribute is plain text, as Markdown's smart punctuation would have it: 2020--2024 is an en dash
  local function attribute(key)
    local text = (div.attributes[key] or ''):gsub('%-%-%-', '\u{2014}'):gsub('%-%-', '\u{2013}')
    return to_latex(pandoc.Str(text)) or ''
  end
  if div.classes:includes('cventry') then
    local body = to_latex(pandoc.Blocks(div.content)) or ''
    return pandoc.RawBlock('latex', string.format('\\cventry{%s}{%s}{%s}{%s}{%s}{%s}',
      attribute('years'), attribute('title'), attribute('institution'), attribute('city'), attribute('grade'), body))
  elseif div.classes:includes('cvitem') then
    local body = to_latex(pandoc.Blocks(div.content)) or ''
    return pandoc.RawBlock('latex', string.format('\\cvitem{%s}{%s}', attribute('label'), body))
  end
  return nil
end

return {
  { Meta = meta_filter },
  { Div = div_filter },
}
