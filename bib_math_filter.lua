
-- This snipped is a Pandoc Lua filter that processes Math elements
-- in the bibliography entries to ensure that math expressions are
-- correctly formatted with dollar sign delimiters in the output JSON.

function Math(el)
  -- Convert the Math object back to a literal string with $ delimiters
  if el.mathtype == 'DisplayMath' then
    return pandoc.Str("$$" .. el.text .. "$$")
  else
    return pandoc.Str("$" .. el.text .. "$")
  end
end


-- Process bibliography metadata
function Meta(meta)
  if meta.references then
    for i, ref in ipairs(meta.references) do
      
      -- Check if note field contains arXiv ID
      if ref.note then
        local note_str = pandoc.utils.stringify(ref.note)
        local arxiv_id = note_str:match("arXiv:([%w%.%-%/]+)")
        
        if arxiv_id then
          -- Create URL field if it doesn't exist
          if not ref.URL then
            ref.URL = pandoc.Str("https://arxiv.org/abs/" .. arxiv_id)
          end
          -- Remove note, since it only contained arxiv ID anyway
          ref.note = nil
        end
      end
      
    end
  end
  return meta
end