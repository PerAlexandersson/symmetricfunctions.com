-- Exercise the real SVG driver without touching sources, assets or compilers.
local mode = assert(arg[1])
local real_dofile = dofile
local files = real_dofile("file_reading.lua")
local converted = false
files.read_file = function()
  if mode == "source-read" then return nil end
  if mode == "named-conversion" then return [[\tikzsetnextfilename{audit}]] end
  return ""
end
files.file_exists = function(path)
  if path:match("%.pdf$") then return mode ~= "missing-pdf" end
  return converted and path:match("^temp/svg%-tex/.*%.svg$") ~= nil
end
dofile = function(path)
  if path == "file_reading.lua" then return files end
  return real_dofile(path)
end
io.popen = function(command)
  local finding = command:match("^find ")
  if finding and mode == "find-open" then return nil end
  return {
    lines = function()
      local done = mode == "empty"
      return function()
        if not done then done = true; return "svg-tex/src/audit.tex" end
      end
    end,
    read = function()
      if command:match("^pdfinfo ") then
        return mode == "page-count" and "Pages: 0" or "Pages: 2"
      end
      return "0"
    end,
    close = function()
      if (finding and mode == "find-exit") or
          (command:match("^pdfinfo ") and mode == "pdfinfo") then
        return nil, "exit", 1
      end
      return true, "exit", 0
    end,
  }
end
os.execute = function(command)
  if (mode == "mkdir" and command:match("^mkdir ")) or
      (mode == "cleanup" and command:match("^rm ")) or
      (mode == "copy" and command:match("^cp ")) or
      (mode == "compile" and command:find("pdflatex", 1, true)) or
      (mode == "move" and command:match("^mv ")) then
    return nil, "exit", 1
  end
  if command:match("^dvisvgm ") or command:match("^pdftocairo ") then
    if mode == "conversion" or mode == "named-conversion" or
        (mode == "fallback" and command:match("^dvisvgm ")) then
      return nil, "exit", 1
    end
    converted = true
  end
  return true, "exit", 0
end
arg = {}
real_dofile("tex_to_svg.lua")
