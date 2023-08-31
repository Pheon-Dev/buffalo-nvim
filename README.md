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
This plugin provides the total number of open buffers which can be displayed
in the statusline, tabline or winbar.
There is an option to delete, pin or mark them across sessions.
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
require('buffalo').buffers()
```

## Usage

```lua
-- Example in lualine
...
sections = {
  ...
      lualine_x = {
          {
            function()
              local buffers = require("buffalo").buffers()
              return "  " .. buffers
            end,
            color = { fg = "#ffaa00", bg = "#24273a",},
          }
        },
      ...
    },
...
```

---
