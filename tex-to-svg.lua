#!/usr/bin/env lua

-- =============================================================================
-- DEPENDENCIES
-- =============================================================================

-- Ensure we can load the helper files from the root directory
local file_reading = dofile("file_reading.lua")
local utils        = dofile("utils.lua")

local print_info   = utils.print_info
local print_warn   = utils.print_warn
local print_error  = utils.print_error
local read_file    = file_reading.read_file

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
-- TEXINPUTS needs absolute path and trailing colon
local TEX_ENV = string.format("TEXINPUTS=.:%s/:", ABS_LIB)

-- =============================================================================
-- HELPERS
-- =============================================================================

local function exec(cmd)
  local success = os.execute(cmd)
  if success == 0 or success == true then return true end
  return false 
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

print_info("Setting up directories...")
exec("mkdir -p " .. CONFIG.TEMP_DIR)
exec("mkdir -p " .. CONFIG.NAV_OUT)
exec("mkdir -p " .. CONFIG.SVG_OUT)

local tex_sources = get_files(CONFIG.SRC_DIR, "tex")

for _, tex_path in ipairs(tex_sources) do
  local fname = basename(tex_path)
  print_info("Processing Bundle: %s", fname)

  -- 1. EXTRACT FILENAMES FROM SOURCE
  -- Scan the .tex file for \tikzsetnextfilename{...}
  -- read_file returns content or nil (exits if strict, but we use strict=false here to be safe)
  local source_content = read_file(tex_path, "TeX source", true)
  local page_names = {}
  
  if source_content then
    for name in source_content:gmatch("\\tikzsetnextfilename%s*{([^{}]+)}") do
      table.insert(page_names, name)
    end
  end

  -- 2. COMPILE TO MULTI-PAGE PDF
  exec("rm -f " .. CONFIG.TEMP_DIR .. "/*.pdf") -- clean previous
  exec("cp " .. tex_path .. " " .. CONFIG.TEMP_DIR .. "/")
  
  local cmd_compile = string.format(
    "cd %s && %s pdflatex -interaction=nonstopmode %s > /dev/null",
    CONFIG.TEMP_DIR, TEX_ENV, fname
  )
  
  if not exec(cmd_compile) then
    print_error("Compilation failed for %s", fname)
  else
    -- 3. SPLIT PDF INTO SVGs
    local pdf_name = fname:gsub("%.tex$", ".pdf")
    local pdf_full_path = CONFIG.TEMP_DIR .. "/" .. pdf_name
    
    -- Check if PDF exists using our helper
    if file_reading.file_exists(pdf_full_path) then 
      
      -- Strategy A: Named Figures found in source
      if #page_names > 0 then
        print(string.format("   Found %d named figures.", #page_names))
        
        for i, out_name in ipairs(page_names) do
          local svg_temp = CONFIG.TEMP_DIR .. "/" .. out_name .. ".svg"
          
          -- Routing Logic
          local dest_dir = CONFIG.SVG_OUT
          if out_name:match("^card%-") then
            dest_dir = CONFIG.NAV_OUT
          end
          local final_path = dest_dir .. "/" .. out_name .. ".svg"

          -- Convert Page i -> Temp SVG
          local cmd_convert = string.format(
            "dvisvgm --pdf -p %d --no-fonts --zoom=1.5 --output=%s %s > /dev/null 2>&1",
            i, svg_temp, pdf_full_path
          )
          exec(cmd_convert)
          
          -- Move to destination (No color substitution)
          if file_reading.file_exists(svg_temp) then
            exec("mv " .. svg_temp .. " " .. final_path)
            print("   -> Generated: " .. final_path)
          else
            print_warn("Failed to extract page %d for %s", i, out_name)
          end
        end
        
      -- Strategy B: Single File (No \tikzsetnextfilename found)
      else
        local out_name = fname:gsub("%.tex$", "")
        local svg_temp = CONFIG.TEMP_DIR .. "/" .. out_name .. ".svg"
        
        -- Routing Logic
        local dest_dir = CONFIG.SVG_OUT
        if out_name:match("^card%-") then dest_dir = CONFIG.NAV_OUT end
        local final_path = dest_dir .. "/" .. out_name .. ".svg"
        
        -- Convert Page 1 -> Temp SVG
        exec(string.format(
          "dvisvgm --pdf -p 1 --no-fonts --zoom=1.5 --output=%s %s > /dev/null 2>&1",
          svg_temp, pdf_full_path
        ))
        
        -- Move to destination
        if file_reading.file_exists(svg_temp) then
          exec("mv " .. svg_temp .. " " .. final_path)
          print("   -> Generated: " .. final_path)
        end
      end
      
    else
      print_error("PDF not generated for %s", fname)
    end
  end
end

print_info("Done.")