#!/usr/bin/env lua

-- =============================================================================
-- CONFIGURATION
-- =============================================================================

local CONFIG = {
  SRC_DIR  = "svg-tex/src",
  LIB_DIR  = "svg-tex/lib",
  TEMP_DIR = "temp/svg-tex",
  NAV_OUT  = "assets/nav-images", -- files starting with "card-"
  SVG_OUT  = "assets/svg-images"  -- everything else
}

-- Environment string to inject TEXINPUTS
-- The trailing colon is crucial for LaTeX to find system files
local TEX_ENV = string.format("TEXINPUTS=.:%s/:", os.getenv("PWD") .. "/" .. CONFIG.LIB_DIR)

-- =============================================================================
-- HELPERS
-- =============================================================================

-- Execute a shell command and check for success
local function exec(cmd)
  local success = os.execute(cmd)
  -- Lua 5.1 returns status code, 5.2+ returns bool, string, number
  if success == 0 or success == true then return true end
  print("Error executing: " .. cmd)
  os.exit(1)
end

-- Read file content
local function read_file(path)
  local f = io.open(path, "rb")
  if not f then return nil end
  local content = f:read("*all")
  f:close()
  return content
end

-- Write file content
local function write_file(path, content)
  local f = io.open(path, "wb")
  if not f then error("Cannot open " .. path .. " for writing") end
  f:write(content)
  f:close()
end

-- Get list of files in a directory matching a pattern (Unix ls wrapper)
local function get_files(dir, extension)
  local files = {}
  local p = io.popen('find "' .. dir .. '" -maxdepth 1 -name "*.' .. extension .. '"')
  for file in p:lines() do
    table.insert(files, file)
  end
  p:close()
  return files
end

-- Extract filename from path
local function basename(path)
  return path:match("^.+/(.+)$") or path
end

-- Remove extension
local function strip_ext(filename)
  return filename:match("(.+)%..+") or filename
end

-- =============================================================================
-- CORE LOGIC
-- =============================================================================

-- 1. Setup Directories
print(">> Setting up directories...")
exec("mkdir -p " .. CONFIG.TEMP_DIR)
exec("mkdir -p " .. CONFIG.NAV_OUT)
exec("mkdir -p " .. CONFIG.SVG_OUT)

-- 2. Process all .tex files
local tex_sources = get_files(CONFIG.SRC_DIR, "tex")

for _, tex_file in ipairs(tex_sources) do
  local fname = basename(tex_file)
  print("\n>> Processing Bundle: " .. fname)

  -- Clean temp dir specific to this build to avoid mixing outputs
  -- (We remove pdfs/svgs but keep the dir)
  exec("rm -f " .. CONFIG.TEMP_DIR .. "/*.pdf")
  exec("rm -f " .. CONFIG.TEMP_DIR .. "/*.svg")

  -- A. Compile (pdflatex handles \tikzexternalize automatically)
  -- We pass TEX_ENV inline.
  local cmd_compile = string.format(
    "%s pdflatex -shell-escape -interaction=nonstopmode -output-directory=%s %s > /dev/null",
    TEX_ENV, CONFIG.TEMP_DIR, tex_file
  )
  exec(cmd_compile)

  -- B. Convert Generated PDFs
  -- Using tikzexternalize, one .tex might generate multiple .pdf files in TEMP_DIR.
  -- We process ALL PDFs found there.
  local generated_pdfs = get_files(CONFIG.TEMP_DIR, "pdf")
  
  for _, pdf_path in ipairs(generated_pdfs) do
    local pdf_name = basename(pdf_path)
    local name_no_ext = strip_ext(pdf_name)
    
    -- Skip the "main" bundle PDF if it exists (usually identical name to source)
    local source_name_no_ext = strip_ext(fname)
    if name_no_ext == source_name_no_ext and #generated_pdfs > 1 then
       -- This is likely the container PDF, skipping in favor of externalized parts
       goto continue 
    end

    local svg_temp = CONFIG.TEMP_DIR .. "/" .. name_no_ext .. ".svg"
    
    -- Convert PDF to SVG
    local cmd_convert = string.format(
      "dvisvgm --pdf --no-fonts --zoom=1.5 --output=%s %s > /dev/null 2>&1",
      svg_temp, pdf_path
    )
    exec(cmd_convert)

    -- C. Apply Color Theme
    local svg_content = read_file(svg_temp)
    if svg_content then
      -- Replace Colors with CSS Variables
      svg_content = svg_content:gsub("#000000", "currentColor")
      svg_content = svg_content:gsub("black", "currentColor")
      svg_content = svg_content:gsub("rgb%(0%%,0%%,0%%%)", "currentColor") -- dvisvgm specific
      svg_content = svg_content:gsub("#ff0000", "var(--c-brand)")
      svg_content = svg_content:gsub("red", "var(--c-brand)")
      
      -- D. Route to correct folder
      local dest_dir = CONFIG.SVG_OUT
      if name_no_ext:match("^card%-") or name_no_ext:match("^csp%-") then
        dest_dir = CONFIG.NAV_OUT
      end
      
      local final_path = dest_dir .. "/" .. name_no_ext .. ".svg"
      write_file(final_path, svg_content)
      print("   -> Generated: " .. final_path)
    end
    
    ::continue::
  end
end

print("\n>> Done.")