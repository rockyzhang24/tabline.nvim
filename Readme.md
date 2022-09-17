### tabline.nvim

This is a lua version of [vim-xtabline](https://github.com/mg979/vim-xtabline).

Most features are the same, and most themes are also supported.
It should look generally better, and be faster and more accurate (there is no
tabline caching, so tabline is updated in real-time).

Add to your vimrc (or run in command line):

    lua require'tabline.setup'.setup()

to load plugin with default settings. If you want default mappings, also add:

    lua require'tabline.setup'.mappings(true)

If you want to customize the settings, execute:

    :Tabline config

General documentation:

    :help tabline-nvim

Consult `:help tnv-settings` to understand the meaning of the different
settings.
