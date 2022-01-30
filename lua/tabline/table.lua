local tbl = {}

local remove = table.remove

function tbl.slice(t, first, last, step)
  local sliced, n = {}, 0
  for i = first or 1, last or #t, step or 1 do
    n = n + 1
    sliced[n] = t[i]
  end
  return sliced
end

function tbl.copy(t)
  local t2 = {}
  for k,v in pairs(t) do
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
  local ix, sz = 1, #t
  for k, v in ipairs(t) do
    if func(k, v) then
      t[ix] = v
      ix = ix + 1
    end
  end
  for i = ix, sz do t[i] = nil end
  return t
end

function tbl.filternew(t, func)
  local ix, sz, new = 1, #t, {}
  for k,v in pairs(t) do new[k] = v end
  for k, v in ipairs(new) do
    if func(k, v) then
      new[ix] = v
      ix = ix + 1
    end
  end
  for i = ix, sz do new[i] = nil end
  return new
end

function tbl.map(t, func)
  for k, v in pairs(t) do
    t[k] = func(k,v)
  end
  return t
end

function tbl.mapnew(t, func)
  local new = {}
  for k, v in pairs(t) do
    new[k] = func(k,v)
  end
  return new
end

function tbl.index(t, val)
  local ix = 1
  for _, v in ipairs(t) do
    if v == val then
      return ix
    end
    ix = ix + 1
  end
  return nil
end

function tbl.uniq(t)
  local seen = {}
  for k, v in pairs(t) do
    if seen[v] then
      remove(t, k)
    else
      seen[v] = true
    end
  end
  return t
end

return tbl
