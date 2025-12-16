
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