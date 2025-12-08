#!/usr/bin/env lua

-- =============================================================================
-- SVG Generator from TeX Sources
-- =============================================================================
-- Compiles .tex files to PDF, then converts each page to SVG format.
-- Supports both named figures (via \tikzsetnextfilename) and automatic naming.
--
-- Directory Structure:
--   - CONFIG.SRC_DIR: Source .tex files
--   - CONFIG.LIB_DIR: TeX library files (added to TEXINPUTS)
--   - CONFIG.TEMP_DIR: Temporary build directory
--   - CONFIG.NAV_OUT: Output for card-* prefixed SVGs
--   - CONFIG.SVG_OUT: Output for all other SVGs
-- =============================================================================

-- =============================================================================
-- DEPENDENCIES
-- =============================================================================

local file_reading = dofile("file_reading.lua")
local utils        = dofile("utils.lua")

local file_exists  = file_reading.file_exists
local read_file    = file_reading.read_file
local print_info   = utils.print_info
local print_warn   = utils.print_warn
local print_error  = utils.print_error

-- =============================================================================
-- CONFIGURATION
-- =============================================================================

local CONFIG = {
  SRC_DIR  = "svg-tex/src",
  LIB_DIR  = "svg-tex/lib",
  TEMP_DIR = "temp/svg-tex",
  NAV_OUT  = "assets/nav-images",
  SVG_OUT  = "assets/svg-images",
  ICO_OUT  = "assets/icons"
}

-- =============================================================================
-- ENVIRONMENT SETUP
-- =============================================================================

local PWD = os.getenv("PWD")
if not PWD then
  print_error("PWD environment variable not set")
  os.exit(1)
end

local ABS_LIB = PWD .. "/" .. CONFIG.LIB_DIR
local TEX_ENV = string.format("TEXINPUTS=.:%s/:", ABS_LIB)

-- =============================================================================
-- HELPER FUNCTIONS
-- =============================================================================

--- Execute a shell command and return success status.
--- @param cmd string Shell command to execute
--- @return boolean true if command succeeded, false otherwise
local function exec(cmd)
  local success = os.execute(cmd)
  return (success == 0 or success == true)
end

--- Find all files in a directory with a specific extension.
--- @param dir string Directory to search
--- @param extension string File extension (without dot)
--- @return table Array of file paths
local function get_files(dir, extension)
  local files = {}
  local handle = io.popen('find "' .. dir .. '" -maxdepth 1 -name "*.' .. extension .. '"')
  if not handle then
    print_warn("Failed to search directory: %s", dir)
    return files
  end
  
  for file in handle:lines() do
    table.insert(files, file)
  end
  handle:close()
  return files
end

--- Extract filename from a full path.
--- @param path string Full file path
--- @return string Filename without directory
local function basename(path)
  return path:match("^.+/(.+)$") or path
end

--- Get the number of pages in a PDF file.
--- @param pdf_path string Path to PDF file
--- @return number Number of pages (defaults to 1 if detection fails)
local function get_pdf_page_count(pdf_path)
  local cmd = string.format("pdfinfo %s | grep 'Pages:' | awk '{print $2}'", pdf_path)
  local handle = io.popen(cmd)
  if not handle then
    print_warn("Failed to get page count for %s", pdf_path)
    return 1
  end
  
  local result = handle:read("*a")
  handle:close()
  
  local count = tonumber(result)
  return count or 1
end

--- Extract figure names from TeX source using \tikzsetnextfilename{...}.
--- @param content string TeX file content
--- @return table Array of figure names
local function extract_figure_names(content)
  local names = {}
  for name in content:gmatch("\\tikzsetnextfilename%s*{([^{}]+)}") do
    table.insert(names, name)
  end
  return names
end

--- Determine output directory based on filename pattern.
--- @param name string Output filename
--- @return string Output directory path
local function get_output_dir(name)
  if name:match("^card%-") then
    return CONFIG.NAV_OUT
  elseif name:match("^icon%-") then
    return CONFIG.ICO_OUT
  end
  return CONFIG.SVG_OUT
end

--- Convert a single PDF page to SVG.
--- @param pdf_path string Path to source PDF
--- @param page_num number Page number to extract
--- @param output_path string Path for output SVG
--- @return boolean true if conversion succeeded
local function pdf_page_to_svg(pdf_path, page_num, output_path)
  local temp_svg = CONFIG.TEMP_DIR .. "/" .. basename(output_path)
  local cmd = string.format(
    "dvisvgm --pdf -p %d --no-fonts --zoom=1.5 --output=%s %s > /dev/null 2>&1",
    page_num, temp_svg, pdf_path
  )
  
  if not exec(cmd) then
    return false
  end
  
  if not file_exists(temp_svg) then
    return false
  end
  
  return exec("mv " .. temp_svg .. " " .. output_path)
end

-- =============================================================================
-- MAIN PROCESSING
-- =============================================================================

--- Process a single TeX source file.
--- @param tex_path string Path to .tex file
local function process_tex_file(tex_path)
  local fname = basename(tex_path)
  print_info("Processing: %s", fname)
  
  -- Read source and extract figure names
  local source_content = read_file(tex_path, "TeX source", false)
  if not source_content then
    print_error("Failed to read source: %s", tex_path)
    return
  end
  
  local figure_names = extract_figure_names(source_content)
  
  -- Compile TeX to PDF
  exec("rm -f " .. CONFIG.TEMP_DIR .. "/*.pdf")
  exec("cp " .. tex_path .. " " .. CONFIG.TEMP_DIR .. "/")
  
  local compile_cmd = string.format(
    "cd %s && %s pdflatex -interaction=nonstopmode %s > /dev/null 2>&1",
    CONFIG.TEMP_DIR, TEX_ENV, fname
  )
  
  if not exec(compile_cmd) then
    print_error("Compilation failed: %s", fname)
    return
  end
  
  -- Check if PDF was generated
  local pdf_name = fname:gsub("%.tex$", ".pdf")
  local pdf_path = CONFIG.TEMP_DIR .. "/" .. pdf_name
  
  if not file_exists(pdf_path) then
    print_error("PDF not generated: %s", fname)
    return
  end
  
  -- Strategy A: Named figures found in source
  if #figure_names > 0 then
    print_info("   Found %d named figure(s)", #figure_names)
    
    for i, fig_name in ipairs(figure_names) do
      local output_dir = get_output_dir(fig_name)
      local output_path = output_dir .. "/" .. fig_name .. ".svg"
      
      if pdf_page_to_svg(pdf_path, i, output_path) then
        print_info("   ✓ %s", output_path)
      else
        print_warn("   ✗ Failed to generate page %d: %s", i, fig_name)
      end
    end
    
  -- Strategy B: No named figures - process all pages with automatic naming
  else
    local page_count = get_pdf_page_count(pdf_path)
    print_info("   No named figures, processing %d page(s)", page_count)
    
    local base_name = fname:gsub("%.tex$", "")
    
    for page_num = 1, page_count do
      local page_suffix = (page_count > 1) and ("-" .. page_num) or ""
      local output_name = base_name .. page_suffix
      local output_dir = get_output_dir(output_name)
      local output_path = output_dir .. "/" .. output_name .. ".svg"
      
      if pdf_page_to_svg(pdf_path, page_num, output_path) then
        print_info("   ✓ %s", output_path)
      else
        print_warn("   ✗ Failed to generate page %d", page_num)
      end
    end
  end
end

-- =============================================================================
-- MAIN EXECUTION
-- =============================================================================

print_info("Setting up directories...")
exec("mkdir -p " .. CONFIG.TEMP_DIR)
exec("mkdir -p " .. CONFIG.NAV_OUT)
exec("mkdir -p " .. CONFIG.SVG_OUT)
exec("mkdir -p " .. CONFIG.ICO_OUT)

print_info("Searching for TeX sources in: %s", CONFIG.SRC_DIR)
local tex_sources = get_files(CONFIG.SRC_DIR, "tex")

if #tex_sources == 0 then
  print_warn("No .tex files found in %s", CONFIG.SRC_DIR)
  os.exit(0)
end

print_info("Found %d TeX source(s)", #tex_sources)

for _, tex_path in ipairs(tex_sources) do
  process_tex_file(tex_path)
end

print_info("Done.")