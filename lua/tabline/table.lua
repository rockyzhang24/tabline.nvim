local tbl = {}

local remove = table.remove

function tbl.slice(tbl, first, last, step)
  local sliced = {}
  for i = first or 1, last or #tbl, step or 1 do
    sliced[#sliced+1] = tbl[i]
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

function tbl.min(tbl)
  local mink, minv = 1, math.huge
  for k, v in pairs(tbl) do
    if v < minv then
      mink, minv = k, v
    end
  end
  return minv, mink
end

function tbl.max(tbl)
  local maxk, maxv = 1, math.huge * -1
  for k, v in pairs(tbl) do
    if v > maxv then
      maxk, maxv = k, v
    end
  end
  return maxv, maxk
end

return tbl
