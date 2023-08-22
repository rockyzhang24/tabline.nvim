local tbl = {}

local add = table.insert

function tbl.slice(t, first, last)
  local sliced, n = {}, 0
  for i = first or 1, last or #t do
    n = n + 1
    sliced[n] = t[i]
  end
  return sliced
end

function tbl.copy(t)
  local t2 = {}
  for k, v in pairs(t) do
    t2[k] = v
  end
  return t2
end

function tbl.reverse(t)
  local n = #t
  local i = 1
  while i < n do
    t[i], t[n] = t[n], t[i]
    i = i + 1
    n = n - 1
  end
  return t
end

function tbl.filter(t, func)
  local dst = {}
  for k, v in ipairs(t) do
    if func(k, v) then
      add(dst, v)
    end
  end
  return dst
end

function tbl.map(t, func)
  for k, v in pairs(t) do
    t[k] = func(k, v)
  end
  return t
end

function tbl.mapnew(t, func)
  local new = {}
  for k, v in pairs(t) do
    new[k] = func(k, v)
  end
  return new
end

function tbl.index(t, val)
  for i, v in ipairs(t) do
    if v == val then
      return i
    end
  end
end

return tbl
