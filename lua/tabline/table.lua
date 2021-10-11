local remove = table.remove

function table.slice(tbl, first, last, step)
  local sliced = {}
  for i = first or 1, last or #tbl, step or 1 do
    sliced[#sliced+1] = tbl[i]
  end
  return sliced
end

function table.copy(tbl)
  local t2 = {}
  for k,v in pairs(tbl) do
    t2[k] = v
  end
  return t2
end

function table.filter(tbl, func)
    local new_index = 1
    local size_orig = #tbl
    for k, v in ipairs(tbl) do
        if func(v, k) then
            tbl[new_index] = v
            new_index = new_index + 1
        end
    end
    for i = new_index, size_orig do tbl[i] = nil end
end

function table.map(tbl, func)
  for k, v in pairs(tbl) do
    tbl[k] = func(k,v)
  end
  return tbl
end

function table.mapnew(tbl, func)
  local new = {}
  for k, v in pairs(tbl) do
    new[k] = func(k,v)
  end
  return new
end

function table.index(tbl, val)
  local ix = 1
  for _, v in ipairs(tbl) do
    if v == val then
      return ix
    end
    ix = ix + 1
  end
  return nil
end

function table.uniq(tbl)
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
