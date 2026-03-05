# open.nvim

A Neovim plugin to open files with external programs based on filetype.

## Setup

```lua
require("open").setup({
    filetype = {
        pdf = { 'sioyek', { '--new-window' } },
        png = 'open',
    }
})
```

## Key Bindings

```lua
vim.keymap.set('n', '<leader>o', require('open').open)
vim.keymap.set('n', '<leader>ob', function() require('open').open('~/books') end)
```

- `<leader>o` - Open Telescope to search and select files, then open with the configured program
- `<leader>ob` - Same as above, but searches in `~/books`

## User Command

```vim
:OpenFile <filename>
```

Opens the specified file with its configured program.

## Dependencies

* Telescope
* Ripgrep
