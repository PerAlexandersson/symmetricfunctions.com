#!/usr/bin/env lua

-- =============================================================================
-- CONFIGURATION
-- =============================================================================

local CONFIG = {
  SRC_DIR  = "svg-tex/src",
  LIB_DIR  = "svg-tex/lib",
  TEMP_DIR = "temp/svg-tex",
  NAV_OUT  = "assets/nav-images",
  SVG_OUT  = "assets/svg-images"
}

-- Setup Environment
local PWD = os.getenv("PWD")
local ABS_LIB = PWD .. "/" .. CONFIG.LIB_DIR
local TEX_ENV = string.format("TEXINPUTS=.:%s/:", ABS_LIB)

-- =============================================================================
-- HELPERS
-- =============================================================================

local function exec(cmd)
  local success = os.execute(cmd)
  if success == 0 or success == true then return true end
  return false 
end

local function read_file(path)
  local f = io.open(path, "rb")
  if not f then return nil end
  local content = f:read("*all")
  f:close()
  return content
end

local function write_file(path, content)
  local f = io.open(path, "wb")
  if not f then error("Cannot open " .. path .. " for writing") end
  f:write(content)
  f:close()
end

local function get_files(dir, extension)
  local files = {}
  local p = io.popen('find "' .. dir .. '" -maxdepth 1 -name "*.' .. extension .. '"')
  for file in p:lines() do table.insert(files, file) end
  p:close()
  return files
end

local function basename(path)
  return path:match("^.+/(.+)$") or path
end

-- =============================================================================
-- CORE LOGIC
-- =============================================================================

print(">> Setting up directories...")
exec("mkdir -p " .. CONFIG.TEMP_DIR)
exec("mkdir -p " .. CONFIG.NAV_OUT)
exec("mkdir -p " .. CONFIG.SVG_OUT)

local tex_sources = get_files(CONFIG.SRC_DIR, "tex")

for _, tex_path in ipairs(tex_sources) do
  local fname = basename(tex_path)
  print("\n>> Processing Bundle: " .. fname)

  -- 1. EXTRACT FILENAMES FROM SOURCE
  -- Scan the .tex file for \tikzsetnextfilename{...}
  local source_content = read_file(tex_path)
  local page_names = {}
  for name in source_content:gmatch("\\tikzsetnextfilename%s*{([^{}]+)}") do
    table.insert(page_names, name)
  end

  -- 2. COMPILE TO MULTI-PAGE PDF
  -- No externalize flags needed. Just standard compilation.
  exec("rm -f " .. CONFIG.TEMP_DIR .. "/*.pdf") -- clean previous
  exec("cp " .. tex_path .. " " .. CONFIG.TEMP_DIR .. "/")
  
  local cmd_compile = string.format(
    "cd %s && %s pdflatex -interaction=nonstopmode %s > /dev/null",
    CONFIG.TEMP_DIR, TEX_ENV, fname
  )
  exec(cmd_compile)

  -- 3. SPLIT PDF INTO SVGs
  local pdf_name = fname:gsub("%.tex$", ".pdf")
  local pdf_full_path = CONFIG.TEMP_DIR .. "/" .. pdf_name
  
  -- Check if PDF exists
  local f = io.open(pdf_full_path, "r")
  if f then 
    f:close() 
    
    -- If we found named pages in the source, use them. 
    -- Otherwise (standard file), just use the filename.
    if #page_names > 0 then
      print(string.format("   Found %d named figures.", #page_names))
      
      for i, out_name in ipairs(page_names) do
        local svg_temp = CONFIG.TEMP_DIR .. "/" .. out_name .. ".svg"
        
        -- dvisvgm -p flag extracts specific page
        local cmd_convert = string.format(
          "dvisvgm --pdf -p %d --no-fonts --zoom=1.5 --output=%s %s > /dev/null 2>&1",
          i, svg_temp, pdf_full_path
        )
        exec(cmd_convert)
        
        -- Process and Move
        local svg_content = read_file(svg_temp)
        if svg_content then
          -- Color replacement
          svg_content = svg_content:gsub("#000000", "currentColor")
          svg_content = svg_content:gsub("black", "currentColor")
          svg_content = svg_content:gsub("rgb%(0%%,0%%,0%%%)", "currentColor")
          svg_content = svg_content:gsub("#ff0000", "var(--c-brand)")
          
          -- Routing
          local dest_dir = CONFIG.SVG_OUT
          if out_name:match("^card%-") or out_name:match("^csp%-") or out_name:match("6%-vertex") then
            dest_dir = CONFIG.NAV_OUT
          end
          
          local final_path = dest_dir .. "/" .. out_name .. ".svg"
          write_file(final_path, svg_content)
          print("   -> Generated: " .. final_path)
        end
      end
      
    else
      -- SINGLE FILE CASE (No \tikzsetnextfilename found)
      -- Just convert page 1 to [filename].svg
      local out_name = fname:gsub("%.tex$", "")
      local svg_temp = CONFIG.TEMP_DIR .. "/" .. out_name .. ".svg"
      
      exec(string.format(
        "dvisvgm --pdf -p 1 --no-fonts --zoom=1.5 --output=%s %s > /dev/null 2>&1",
        svg_temp, pdf_full_path
      ))
      
      local svg_content = read_file(svg_temp)
      if svg_content then
          -- (Same processing logic as above...)
          svg_content = svg_content:gsub("#000000", "currentColor")
          svg_content = svg_content:gsub("black", "currentColor")
          svg_content = svg_content:gsub("rgb%(0%%,0%%,0%%%)", "currentColor")
          svg_content = svg_content:gsub("#ff0000", "var(--c-brand)")

          local dest_dir = CONFIG.SVG_OUT
          if out_name:match("^card%-") then dest_dir = CONFIG.NAV_OUT end
          
          local final_path = dest_dir .. "/" .. out_name .. ".svg"
          write_file(final_path, svg_content)
          print("   -> Generated: " .. final_path)
      end
    end
  else
    print("   Error: PDF not generated.")
  end
end

print("\n>> Done.")