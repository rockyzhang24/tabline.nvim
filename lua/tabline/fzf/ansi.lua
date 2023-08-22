local fn = vim.fn
local sub = string.sub
local tbl = require('tabline.table')

-- if vim.o.t_Co == 256 then
--   colors = { black = 30, red = 31, green = 32, yellow = 33, blue = 34, magenta = 35, cyan = 36 }
--   -- colors = { black = 235, red = 196, green = 41, yellow = 229, blue = 63, magenta = 213, cyan = 159 }
-- elseif vim.o.t_Co == 16 then
--   colors = { black = 0, red = 9, green = 10, yellow = 11, blue = 12, magenta = 13, cyan = 14 }
-- else
--   colors = { black = 0, red = 1, green = 2, yellow = 3, blue = 4, magenta = 5, cyan = 6 }
-- end

local colors = {
  black = 235,
  red = 196,
  green = 41,
  yellow = 229,
  blue = 63,
  magenta = 213,
  cyan = 159,
}

local function get_color(attr, group)
  local fam = vim.o.termguicolors and 'gui' or 'cterm'
  local pat = vim.o.termguicolors and '^#%x+$' or '^%d+$'
  local code = fn.synIDattr(fn.synIDtrans(fn.hlID(group)), attr, fam)
  return string.find(code, pat) and code or ''
end

local function csi(color, fg)
  local prefix = fg and '38;' or '48;'
  if sub(color, 1, 1) == '#' then
    return prefix
      .. '2;'
      .. table.concat(
        tbl.map(
          { sub(color, 2, 3), sub(color, 4, 5), sub(color, 6, 7) },
          function(_, v)
            return fn.str2nr(v, 16)
          end
        ),
        ';'
      )
  end
  return prefix .. '5;' .. color
end

local function ansi(str, group, default, bold)
  local fg = get_color('fg', group)
  local bg = get_color('bg', group)
  local color = csi(fg == '' and colors[default] or fg, true)
    .. (bg == '' and '' or csi(bg, false))
  return string.format('\x1b[%s%sm%s\x1b[m', color, bold and ';1' or '', str)
end

return {
  black = function(str, group)
    return ansi(str or '', group or '', 'black')
  end,
  red = function(str, group)
    return ansi(str or '', group or '', 'red')
  end,
  green = function(str, group)
    return ansi(str or '', group or '', 'green')
  end,
  yellow = function(str, group)
    return ansi(str or '', group or '', 'yellow')
  end,
  blue = function(str, group)
    return ansi(str or '', group or '', 'blue')
  end,
  magenta = function(str, group)
    return ansi(str or '', group or '', 'magenta')
  end,
  cyan = function(str, group)
    return ansi(str or '', group or '', 'cyan')
  end,
}
