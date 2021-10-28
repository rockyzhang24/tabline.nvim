local tbl = {}

local remove = table.remove

function tbl.slice(tbl, first, last, step)
  local sliced, n = {}, 0
  for i = first or 1, last or #tbl, step or 1 do
    n = n + 1
    sliced[n] = tbl[i]
  end
  return sliced
end

function tbl.copy(tbl)
  local t2 = {}
  for k,v in pairs(tbl) do
    t2[k] = v
  end
  return t2
end

function tbl.reverse(tbl)
  local n = #tbl
  local i = 1
  while i < n do
    tbl[i], tbl[n] = tbl[n], tbl[i]
    i = i + 1
    n = n - 1
  end
  return tbl
end

function tbl.filter(tbl, func)
  local ix, sz = 1, #tbl
  for k, v in ipairs(tbl) do
    if func(k, v) then
      tbl[ix] = v
      ix = ix + 1
    end
  end
  for i = ix, sz do tbl[i] = nil end
  return tbl
end

function tbl.filternew(tbl, func)
  local ix, sz, new = 1, #tbl, {}
  for k,v in pairs(tbl) do new[k] = v end
  for k, v in ipairs(new) do
    if func(k, v) then
      new[ix] = v
      ix = ix + 1
    end
  end
  for i = ix, sz do new[i] = nil end
  return new
end

function tbl.map(tbl, func)
  for k, v in pairs(tbl) do
    tbl[k] = func(k,v)
  end
  return tbl
end

function tbl.mapnew(tbl, func)
  local new = {}
  for k, v in pairs(tbl) do
    new[k] = func(k,v)
  end
  return new
end

function tbl.index(tbl, val)
  local ix = 1
  for _, v in ipairs(tbl) do
    if v == val then
      return ix
    end
    ix = ix + 1
  end
  return nil
end

function tbl.uniq(tbl)
  local seen = {}
  for k, v in pairs(tbl) do
    if seen[v] then
      remove(tbl, k)
    else
      seen[v] = true
    end
  end
  return tbl
end

return tbl
