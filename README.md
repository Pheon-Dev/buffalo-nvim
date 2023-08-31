# Buffalo-nvim

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
            color = "Keyword",
          }
        },
      ...
    },
...
```

---
