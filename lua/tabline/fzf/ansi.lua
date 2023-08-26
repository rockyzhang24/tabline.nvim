local o = vim.o
local printf = string.format

local colors = {
  dark = {
    black = 235,
    blue = 63,
    cyan = 159,
    green = 41,
    magenta = 213,
    red = 196,
    yellow = 229,
  },
  light = {
    black = 235,
    blue = 21,
    cyan = 24,
    green = 22,
    magenta = 201,
    red = 196,
    yellow = 130,
  },
}

return {
  black = function(str)
    return printf('\x1b[38;5;%dm%s\x1b[m', colors[o.bg].black, str)
  end,
  red = function(str)
    return printf('\x1b[38;5;%dm%s\x1b[m', colors[o.bg].red, str)
  end,
  green = function(str)
    return printf('\x1b[38;5;%dm%s\x1b[m', colors[o.bg].green, str)
  end,
  yellow = function(str)
    return printf('\x1b[38;5;%dm%s\x1b[m', colors[o.bg].yellow, str)
  end,
  blue = function(str)
    return printf('\x1b[38;5;%dm%s\x1b[m', colors[o.bg].blue, str)
  end,
  magenta = function(str)
    return printf('\x1b[38;5;%dm%s\x1b[m', colors[o.bg].magenta, str)
  end,
  cyan = function(str)
    return printf('\x1b[38;5;%dm%s\x1b[m', colors[o.bg].cyan, str)
  end,
}
