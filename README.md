![Linux](https://img.shields.io/badge/Linux-%23.svg?logo=linux&color=FCC624&logoColor=black)
![macOS](https://img.shields.io/badge/macOS-%23.svg?logo=apple&color=000000&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-%23.svg?logo=windows&color=0078D6&logoColor=white)

<h1 align="center">
 buffalo-nvim
</h1>

<p align="center">
<img src="https://i.pinimg.com/136x136/56/d2/8c/56d28c3798343d509e9b51973ee6ce56.jpg" alt="buffalo-nvim" />
</p>

<p align="center">
This is a <span><a src="https://github.com/ThePrimeagen/harpoon">harpoon</a></span> like plugin that provides a UI
to open buffers or tabs (+windows). Their respective totals can be displayed on the statusline,
  tabline or winbar.
</p>

## Installation

Using [Lazy](https://github.com/folke/lazy.nvim)

```lua
  {
     'Pheon-Dev/buffalo-nvim'
  }
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use 'Pheon-Dev/buffalo-nvim'
```

Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'Pheon-Dev/buffalo-nvim'
```

## Setup

```lua
-- default config
require('buffalo').setup({})
```

## Usage

```lua
-- Keymaps
local opts = { noremap = true }
local map = vim.keymap.set
local buffalo = require("buffalo.ui")

map({ 't', 'n' }, '<C-Space>', buffalo.toggle_buf_menu, opts)
map({ 't', 'n' }, '<M-Space>', buffalo.toggle_tab_menu, opts)
-- Next/Prev
map('n', '<C-j>', buffalo.nav_buf_next, opts)
map('n', '<C-k>', buffalo.nav_buf_prev, opts)
map('n', '<C-n>', buffalo.nav_tab_next, opts)
map('n', '<C-p>', buffalo.nav_tab_prev, opts)

-- Example in lualine
...
sections = {
  ...
  lualine_x = {
      {
        function()
          local buffers = require("buffalo").buffers()
          local tabpages = require("buffalo").tabpages()
          return "󱂬 " .. buffers .. " 󰓩 " .. tabpages
        end,
        color = { fg = "#ffaa00", bg = "#24273a",},
      }
    },
  ...
    },
...
```

---

## Config

```lua
require("buffalo").setup({
  tab_commands = {
    edit = {
      key = "<CR>",
      command = "tabnext"
    },
    v = {
      key = "<C-x>",
      command = "tabclose"
    },
    h = {
      key = "<C-n>",
      command = "tabnew"
    }
  },
  buffer_commands = {
    edit = {
      key = "<CR>",
      command = "edit"
    },
    v = {
      key = "<C-v>",
      command = "vsplit"
    },
    h = {
      key = "<C-h>",
      command = "split"
    }
  },
})
```

---
