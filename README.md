![Linux](https://img.shields.io/badge/Linux-%23.svg?logo=linux&color=FCC624&logoColor=black)
![macOS](https://img.shields.io/badge/macOS-%23.svg?logo=apple&color=000000&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-%23.svg?logo=windows&color=0078D6&logoColor=white)

<h1 align="center">
 buffalo-nvim
</h1>

<p align="center">
<img src="/buffalo-nvim.png" alt="buffalo-nvim" />
</p>

This is a [harpoon](https://github.com/ThePrimeagen/harpoon) like plugin that provides an interface
to navigate through buffers or tabs.

> Their respective totals can be displayed on the statusline, tabline or winbar.

<hr />
<h3 align="center">
 NOTE:
</h3>
<h6>Please note that this plugin is still in its early development stages. Breaking changes are to be expected!</h6>

<hr />
<h5 align="center">
 BUFFERS
</h5>
<p align="center">
<img src="assets/buffers.jpg" alt="buffalo-buffers" />
</p>

<hr />
<h5 align="center">
 TABS
</h5>
<p align="center">
<img src="assets/tabs.jpg" alt="buffalo-tabs" />
</p>

<hr />
<h5 align="center">
 STATUSLINE
</h5>

<p align="center">
<img src="assets/statusline.jpg" alt="buffalo-statusline" />
</p>
<p align="right">
  <i>tabs: <strong>4 </strong> | buffers: <strong>7  </strong>[lualine]</i>
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

-- buffers
map({ 't', 'n' }, '<C-Space>', buffalo.toggle_buf_menu, opts)

map('n', '<C-j>', buffalo.nav_buf_next, opts)
map('n', '<C-k>', buffalo.nav_buf_prev, opts)

-- tabpages
map({ 't', 'n' }, '<M-Space>', buffalo.toggle_tab_menu, opts)

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
  tab_commands = {  -- use default neovim commands for tabs e.g `tablast`, `tabnew` etc
    next = { -- you can use any unique name e.g `tabnext`, `tab_next`, `next`, `random` etc
      key = "<CR>",
      command = "tabnext"
    },
    close = {
      key = "c",
      command = "tabclose"
    },
    dd = {
      key = "dd",
      command = "tabclose"
    },
    new = {
      key = "n",
      command = "tabnew"
    }
  },
  buffer_commands = { -- use default neovim commands for buffers e.g `bd`, `edit`
    edit = {
      key = "<CR>",
      command = "edit"
    },
    vsplit = {
      key = "v",
      command = "vsplit"
    },
    split = {
      key = "h",
      command = "split"
    }
    buffer_delete = {
      key = "d",
      command = "bd"
    }
  },
  general_commands = {
    cycle = true, -- cycle through buffers or tabs
    exit_menu = "x", -- similar to 'q' and '<esc>'
  },
  go_to = {
    enabled = true,
    go_to_tab = "<leader>%s",
    go_to_buffer = "<M-%s>",
  },
  filter = {
    enabled = true,
    filter_tabs = "<M-t>",
    filter_buffers = "<M-b>",
  },
  ui = {
    width = 60,
    height = 10,
    row = 2,
    col = 2,
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
  }
})
```

---

## Tips

- Hit any number on the menu to navigate to that buffer or tab without having to scroll.
- Use normal keymap defaults for neovim e.g `dd` to delete a buffer, on the open menu.

---

## Highlights

- `BuffaloBorder`
- `BuffaloWindow`
- `BuffaloBuffersModified`
- `BuffaloBuffersCurrentLine`
- `BuffaloTabsCurrentLine`

---

## Acknowledgement

- ThePrimeagen's [Harpoon](https://github.com/ThePrimeagen/harpoon)
- J-Morano's [Buffer Manager](https://github.com/j-morano/buffer_manager.nvim)

---

## Contributions

- PRs and Issues are always welcome.
