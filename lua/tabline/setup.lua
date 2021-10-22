-------------------------------------------------------------------------------
-- Initialization
-------------------------------------------------------------------------------

local M, has_done_setup = {}, false

local tbl = require'tabline.table'

M.tabline = { -- internal tables {{{1
  closed_tabs = {},
  pinned = {},
  valid = {},
  order = { unfiltered = {} },
  recent = { unfiltered = {} },
}

M.tabline.v = { -- internal variables {{{1
  mode = 'auto',
  max_bufs = 10,
}

M.settings = {  -- user settings {{{1
  filtering = true,
  show_right_corner = true,
  tab_number_in_left_corner = true,
  bufline_style = 'order',
  dim_inactive_icons = true,
  show_full_path = false,
  clickable_bufline = true,
  max_recent = 10,
  main_cmd_name = 'Tab',
  mode_labels = 'secondary',
  modes = { 'auto', 'buffers', 'args' },
  scratch_label = '[Scratch]',
  unnamed_label = '[Unnamed]',
  mapleader = '<leader><leader>',
  default_mappings = true,
  cd_mappings = true,
}

M.settings.icons = { -- icons {{{1
  ['pin'] =      '📌', ['star'] =   '★',   ['book'] =     '📖',  ['lock'] =    '🔒',
  ['hammer'] =   '🔨', ['tick'] =   '✔',   ['cross'] =    '✖',   ['warning'] = '⚠',
  ['menu'] =     '☰',  ['apple'] =  '🍎',  ['linux'] =    '🐧',  ['windows'] = '❖',
  ['git'] =      '',  ['git2'] =   '⎇ ',  ['palette'] =  '🎨',  ['lens'] =    '🔍',
  ['flag'] =     '⚑',  ['flag2'] =  '🏁',  ['fire'] =     '🔥',  ['bomb'] =    '💣',
  ['home'] =     '🏠', ['mail'] =   '✉ ',  ['disk'] =     '🖪 ',  ['arrow'] =   '➤',
  ['terminal'] = '',
  ['tab'] = {"📂", "📁"},
}

M.settings.indicators = { -- indicators {{{1
  ['modified'] = M.settings.no_icons and '[+]'  or '*',
  ['readonly'] = M.settings.no_icons and '[RO]' or '🔒',
  ['scratch'] = M.settings.no_icons and  '[!]'  or '✓',
  ['pinned'] = M.settings.no_icons and   '[^]'  or '[📌]',
}

local MAPPINGS = { -- default mappings {{{1
  ['mode next'] =  { '<F5>', true },
  ['next'] =       { ']b', true },
  ['prev'] =       { '[b', true },
  ['away'] =       { nil, true },
  ['left'] =       { nil, true },
  ['right'] =      { nil, true },
  ['filtering!'] = { M.settings.mapleader .. 'f', true },
  ['fullpath!'] =  { M.settings.mapleader .. '/', true },
  ['close'] =      { M.settings.mapleader .. 'q', true },
  ['pin!'] =       { M.settings.mapleader .. 'p', true },
  ['bufname'] =    { nil, false },
  ['tabname'] =    { nil, false },
  ['buficon'] =    { nil, false },
  ['tabicon'] =    { nil, false },
  ['bufreset'] =   { nil, true },
  ['tabreset'] =   { nil, true },
  ['reopen'] =     { M.settings.mapleader .. 'u', true },
  ['resetall'] =   { nil, true },
  ['purge'] =      { M.settings.mapleader .. 'x', true },
  ['cleanup'] =    { M.settings.mapleader .. 'X', true },
}

-- }}}

-------------------------------------------------------------------------------
-- Local functions
-------------------------------------------------------------------------------

local function set_mappings(mappings) -- Define mappings {{{1
  local c = M.settings.main_cmd_name
  if c then
    for k, v in pairs(mappings) do
      if v[1] and vim.fn.mapcheck(v[1]) == '' then
        vim.cmd(string.format('nnoremap %s :<c-u>%s %s%s', v[1], c, k, v[2] and '<cr>' or '<space>'))
      end
    end
  end
end

local function set_cd_mappings() -- Define cd mappings {{{1
  local cmd = "lua require'tabline.cd'."
  if not M.settings.cd_mappings then return end
  for _, v in ipairs({ 'cdc', 'cdl', 'cdt', 'cdw' }) do
    if vim.fn.maparg(v) == '' then
      vim.cmd(string.format('nnoremap <silent> %s :<c-u>%s%s()<cr>', v, cmd, v))
    end
  end
  vim.cmd(string.format('nnoremap <silent> cd? :<c-u>%sinfo()<cr>', cmd))
end

local function define_main_cmd() -- Define main command {{{1
  vim.cmd([[
  command! -nargs=1 -complete=customlist,v:lua.require'tabline.cmds'.complete ]] ..
  M.settings.main_cmd_name .. [[ exe "lua require'tabline.cmds'.command(" string(<q-args>) . ")"
  ]])
end

-- }}}


-------------------------------------------------------------------------------
-- Module functions
-------------------------------------------------------------------------------

function M.setup(opts)
  if not M.tabline.buffers then
    require'tabline.bufs'.init_bufs()
  end
  if not M.tabline.tabs then
    require'tabline.tabs'.init_tabs()
  end
  for k, v in pairs(opts or {}) do
    M.settings[k] = v
  end

  define_main_cmd()
  has_done_setup = true
end

function M.mappings(maps)
  if not has_done_setup then
    return
  end
  local mappings = M.settings.default_mappings
                   and maps and vim.tbl_extend('force', MAPPINGS, maps)
                   or MAPPINGS or maps
  if mappings then
    set_mappings(mappings)
  end
  if M.settings.cd_mappings then
    set_cd_mappings()
  end
end

return M
