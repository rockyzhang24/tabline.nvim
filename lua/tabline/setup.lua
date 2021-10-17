-------------------------------------------------------------------------------
-- Initialization
-------------------------------------------------------------------------------

local define_main_cmd, cmd_mappings, cd_mappings

require'tabline.table'

local tabline = { -- internal tables {{{1
  closed_tabs = {},
  pinned = {},
}

tabline.v = { -- internal variables {{{1
  mode = 'auto',
  max_bufs = 10,
}

local settings = {  -- user settings {{{1
  filtering = true,
  show_right_corner = true,
  tab_number_in_left_corner = true,
  actual_buffer_number = false,
  dim_inactive_icons = true,
  show_full_path = false,
  main_cmd_name = 'Tab',
  mode_labels = 'secondary',
  modes = { 'auto', 'buffers', 'args' },
  scratch_label = '[Scratch]',
  unnamed_label = '[Unnamed]',
  mapleader = '<leader><leader>',
  cmd_mappings = true,
  cd_mappings = true,
}

local mappings = { -- mappings {{{1
  ['mode next'] =  { '<F5>', true },
  ['next'] =       { ']b', true },
  ['prev'] =       { '[b', true },
  ['filtering!'] = { settings.mapleader .. 'f', true },
  ['fullpath!'] =  { settings.mapleader .. '/', true },
  ['close'] =      { settings.mapleader .. 'q', true },
  ['pin'] =        { settings.mapleader .. 'p', true },
  ['bufname'] =    { nil, false },
  ['tabname'] =    { nil, false },
  ['buficon'] =    { nil, false },
  ['tabicon'] =    { nil, false },
  ['bufreset'] =   { nil, true },
  ['tabreset'] =   { nil, true },
  ['reopen'] =     { settings.mapleader .. 'u', true },
  ['resetall'] =   { nil, true },
  ['purge'] =      { settings.mapleader .. 'x', true },
  ['cleanup'] =    { settings.mapleader .. 'X', true },
}

settings.icons = { -- icons {{{1
  ['pin'] =      '📌', ['star'] =   '★',   ['book'] =     '📖',  ['lock'] =    '🔒',
  ['hammer'] =   '🔨', ['tick'] =   '✔',   ['cross'] =    '✖',   ['warning'] = '⚠',
  ['menu'] =     '☰',  ['apple'] =  '🍎',  ['linux'] =    '🐧',  ['windows'] = '❖',
  ['git'] =      '',  ['git2'] =   '⎇ ',  ['palette'] =  '🎨',  ['lens'] =    '🔍',
  ['flag'] =     '⚑',  ['flag2'] =  '🏁',  ['fire'] =     '🔥',  ['bomb'] =    '💣',
  ['home'] =     '🏠', ['mail'] =   '✉ ',  ['disk'] =     '🖪 ',  ['arrow'] =   '➤',
  ['terminal'] = '',
  ['tab'] = {"📂", "📁"},
}

settings.indicators = { -- indicators {{{1
  ['modified'] = settings.no_icons and '[+]'  or '*',
  ['readonly'] = settings.no_icons and '[RO]' or '🔒',
  ['scratch'] = settings.no_icons and  '[!]'  or '✓',
  ['pinned'] = settings.no_icons and   '[^]'  or '[📌]',
}

-- }}}

local function setup(sets)
  if not tabline.buffers then
    require'tabline.bufs'.init_bufs()
  end
  if not tabline.tabs then
    require'tabline.tabs'.init_tabs()
  end
  for k, v in pairs(sets or {}) do
    settings[k] = v
  end

  local cmd = define_main_cmd()
  cmd_mappings(cmd)
  cd_mappings()
end

function cd_mappings()
  local cmd = "lua require'tabline.cd'."
  if not settings.cd_mappings then return end
  for _, v in ipairs({ 'cdc', 'cdl', 'cdt', 'cdw' }) do
    if vim.fn.maparg(v) == '' then
      vim.cmd(string.format('nnoremap <silent> %s :<c-u>%s%s()<cr>', v, cmd, v))
    end
  end
  vim.cmd(string.format('nnoremap <silent> cd? :<c-u>%sinfo()<cr>', cmd))
end

function cmd_mappings(cmd) -- Define mappings for commands {{{1
  if not settings.cmd_mappings then return end
  for k, v in pairs(mappings) do
    if v[1] and vim.fn.mapcheck(v[1]) == '' then
      vim.cmd(string.format('nnoremap %s :<c-u>%s %s%s', v[1], cmd, k, v[2] and '<cr>' or '<space>'))
    end
  end
end

function define_main_cmd() -- Define main command {{{1
  vim.cmd([[
  command! -nargs=1 -complete=customlist,v:lua.require'tabline.cmds'.complete ]]
  .. settings.main_cmd_name .. [[ exe "lua require'tabline.cmds'.command(" string(<q-args>) . ")"]])
  return settings.main_cmd_name
end

-- }}}

return {
  setup = setup,
  tabline = tabline,
  settings = settings,
}
