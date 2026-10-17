-- xSAR article filter (Pandoc Lua). Deterministic: no clock, no network.
--
-- For article pages it:
--   * validates front matter (title, date YYYY-MM-DD, summary, slug == file name),
--   * sets pagetitle, description, date_display and outfile for the template,
--   * collects every inline and display formula in document order, writes one
--     LaTeX job per unique formula to $XSAR_WORK/jobs/<hash>.tex, and writes the
--     per-article upload manifest $XSAR_STAGE/formulas/<slug>.txt,
--   * writes one index row to $XSAR_WORK/rows/<slug>.tsv.
-- Maths stays in the page as MathML (pandoc --math-method=mathml).
-- Formula hash = sha256 of "<mode>\n<TeX trimmed of outer whitespace>", mode = inline | display.

local stringify = pandoc.utils.stringify

local MONTHS = { "January", "February", "March", "April", "May", "June", "July",
  "August", "September", "October", "November", "December" }

local function die(msg)
  error("article.lua: " .. msg, 0)
end

local function env(name)
  local v = os.getenv(name)
  if not v or v == "" then die("environment variable " .. name .. " not set (run ./build.sh)") end
  return v
end

local function write_file(path, data)
  local f = assert(io.open(path, "wb"))
  f:write(data)
  f:close()
end

local function sha256(s)
  local out = pandoc.pipe("sha256sum", {}, s)
  return out:match("^(%x+)")
end

local function inline_html(meta_value)
  local blocks
  if pandoc.utils.type(meta_value) == "Blocks" then
    blocks = meta_value
  else
    blocks = pandoc.Blocks { pandoc.Plain(pandoc.Inlines(meta_value)) }
  end
  local html = pandoc.write(pandoc.Pandoc(blocks), "html5", { wrap_text = "none" })
  return (html:gsub("[\t\r\n]+", " "):gsub("^%s+", ""):gsub("%s+$", ""))
end

-- LaTeX wrapper for one formula. Keep in sync with tools.versions notes.
local function tex_job(mode, tex)
  local body
  if mode == "display" then
    body = "$\\displaystyle " .. tex .. "$"
  else
    body = "$" .. tex .. "$"
  end
  return table.concat({
    "\\documentclass[border=2pt]{standalone}",
    "\\usepackage{amsmath}",
    "\\usepackage{amssymb}",
    "\\begin{document}",
    body,
    "\\end{document}",
    "",
  }, "\n")
end

function Pandoc(doc)
  local meta = doc.meta

  if meta.is_index then
    meta.pagetitle = stringify(meta.title or "Articles")
    meta.description = stringify(meta.description or "")
    meta.outfile = "index.html"
    return doc
  end

  local src = PANDOC_STATE.input_files[1] or "?"
  for _, k in ipairs({ "title", "date", "summary", "slug" }) do
    if not meta[k] or stringify(meta[k]) == "" then die(src .. ": front matter needs '" .. k .. "'") end
  end
  local slug = stringify(meta.slug)
  if not slug:match("^[a-z0-9][a-z0-9%-]*$") then die(src .. ": slug must be lowercase a-z, 0-9 and '-'") end
  local base = src:match("([^/]+)%.md$")
  if base ~= slug then die(src .. ": slug '" .. slug .. "' must match the file name") end
  local date = stringify(meta.date)
  local y, m, d = date:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
  if not y then die(src .. ": date must be YYYY-MM-DD") end
  m, d = tonumber(m), tonumber(d)
  if m < 1 or m > 12 or d < 1 or d > 31 then die(src .. ": bad date " .. date) end

  local title_html = inline_html(meta.title)
  local summary_html = inline_html(meta.summary)
  meta.date = date
  meta.date_display = string.format("%d %s %s", d, MONTHS[m], y)
  meta.pagetitle = stringify(meta.title)
  meta.description = stringify(meta.summary)
  meta.outfile = slug .. ".html"

  local work = env("XSAR_WORK")
  local stage = env("XSAR_STAGE")

  -- Formulas, strictly in document order (topdown traversal).
  local lines = {
    "Formulas for " .. slug .. " (" .. stringify(meta.title) .. ")",
    "Upload each PNG to the X article where that formula appears, in this order.",
    "Short inline formulas can usually just be typed as text on X; display formulas are the ones that need images.",
    "",
  }
  local n = 0
  doc:walk {
    traverse = "topdown",
    Math = function(el)
      local mode = (el.mathtype == "DisplayMath") and "display" or "inline"
      local tex = el.text:gsub("^%s+", ""):gsub("%s+$", "")
      local hash = sha256(mode .. "\n" .. tex)
      n = n + 1
      write_file(work .. "/jobs/" .. hash .. ".tex", tex_job(mode, tex))
      lines[#lines + 1] = string.format("%d. %s  articles/formulas/%s.png", n, mode, hash)
      for l in (tex .. "\n"):gmatch("(.-)\n") do
        lines[#lines + 1] = "     " .. l
      end
      lines[#lines + 1] = ""
    end,
  }
  if n == 0 then lines[#lines + 1] = "(no formulas)" end
  write_file(stage .. "/formulas/" .. slug .. ".txt", table.concat(lines, "\n") .. "\n")

  local lastmod = meta.updated and stringify(meta.updated) or date
  write_file(work .. "/rows/" .. slug .. ".tsv",
    table.concat({ date, slug, lastmod, meta.date_display, title_html, summary_html }, "\t") .. "\n")

  return doc
end
