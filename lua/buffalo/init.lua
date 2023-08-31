local api = vim.api
local M = {}
local U = require('buffalo.utils')

---@class Data
---@field win_buf number|nil
---@field win number|nil
---@field name string
---@field active boolean

---@type Data[]
local data = {}
local width = 0
local is_enabled = false
local ns = api.nvim_create_namespace('buffalo')

---@class Config
local cfg = {
  ---@type 'none'|'single'|'double'|'rounded'|'solid'|'shadow'|table
  border = 'rounded',
  ---@type integer
  padding = 1,
  ---@type boolean
  icons = true,
  ---@type string
  hl_group = 'Keyword',
  ---@type string
  hl_group_inactive = 'Comment',
  ---@type string[]
  exclude = {},
  ---@type boolean
  show_all = false,
  ---@type 'row'|'column'
  display = 'row',
  ---@type 'left'|'right'|'center'
  horizontal = 'center',
  ---@type 'top'|'bottom'|'center'
  vertical = 'top',
}


local function load_buffers()
  data = {}

  local bufs = api.nvim_list_bufs()
  bufs = vim.tbl_filter(function(buf)
    if cfg.show_all then
      return true
    end

    local is_loaded = api.nvim_buf_is_loaded(buf)
    local is_listed = vim.fn.buflisted(buf) == 1

    if not (is_loaded and is_listed) then
      return false
    end

    return true
  end, bufs)

  for _, buf in pairs(bufs) do
    local name = api.nvim_buf_get_name(buf):match("[^\\/]+$") or ""
    local ext = string.match(name, "%w+%.(.+)") or name
    local icon = U.get_icon(name, ext, cfg)

    local ft = api.nvim_get_option_value('ft', { buf = buf })
    local is_excluded = vim.tbl_contains(cfg.exclude, ft)

    if not is_excluded and name ~= "" then
      local is_active = api.nvim_get_current_buf() == buf

      table.insert(data, {
        win = nil,
        win_buf = nil,
        name = icon .. " " .. name .. "",
        active = is_active,
      })
    end
  end
end


---@param name string
---@param is_active boolean
---@param data_idx number
local function create_win(name, is_active, data_idx)
  local function get_position()
    local res = {
      row = 0,
      col = 0,
    }

    if cfg.display == 'row' then
      res.row = U.get_position_vertical(cfg.vertical)
      res.col = width + 3
      width = width + #name + cfg.padding + 1
    end

    if cfg.display == 'column' then
      if cfg.horizontal == 'left' then
        res.col = 0
      elseif cfg.horizontal == 'right' then
        res.col = vim.o.columns - #name
      else
        res.col = vim.o.columns / 2 - #name / 2
      end

      res.row = width
      width = width + cfg.padding + 2
    end

    return res
  end

  -- setup buffer
  local buf = api.nvim_create_buf(false, true)
  data[data_idx].win_buf = buf
  api.nvim_buf_set_lines(buf, 0, -1, true, { " " .. name .. " " })

  local pos = get_position()

  -- create window
  local win_opts = {
    relative = 'editor',
    width = #name,
    height = 1,
    row = pos.row,
    col = pos.col,
    style = "minimal",
    border = cfg.border,
    focusable = false,
  }
  local win = api.nvim_open_win(buf, false, win_opts)
  data[data_idx].win = win

  -- configure window
  api.nvim_set_option_value('modifiable', false, { buf = buf })
  api.nvim_set_option_value('buflisted', false, { buf = buf })


  -- add highlight
  if is_active then
    api.nvim_buf_add_highlight(buf, ns, cfg.hl_group, 0, 0, -1)
    api.nvim_set_option_value('winhighlight', 'FloatBorder:' .. cfg.hl_group, { win = win })
  else
    api.nvim_buf_add_highlight(buf, ns, cfg.hl_group_inactive, 0, 0, -1)
    api.nvim_set_option_value('winhighlight', 'FloatBorder:' .. cfg.hl_group_inactive, { win = win })
  end
end

local function display_buffers()
  local max = U.get_max_width(data)
  width = U.get_position_horizontal(cfg, max, #data)

  for idx, v in pairs(data) do
    create_win(v.name, v.active, idx)
  end
end


---@param opts table
function M.setup(opts)
  -- load config
  opts = opts or {}
  for k, v in pairs(opts) do
    cfg[k] = v
  end

  -- start displaying
  is_enabled = true

  api.nvim_create_autocmd(U.events, {
    callback = function()
      if is_enabled then
        U.delete_buffers(data)
        load_buffers()
        display_buffers()
      end
    end
  })
end

function M.toggle()
  if is_enabled == false then
    U.delete_buffers(data)
    load_buffers()
    display_buffers()

    is_enabled = true
  else
    U.delete_buffers(data)
    is_enabled = false
  end
end

function M.buffers()
  local bufs = vim.api.nvim_list_bufs()
  bufs = vim.tbl_filter(function(buf)
    local is_loaded = vim.api.nvim_buf_is_loaded(buf)
    local is_listed = vim.fn.buflisted(buf) == 1

    if not (is_loaded and is_listed) then
      return false
    end

    return true
  end, bufs)
  local count = 0
  for _, buf in pairs(bufs) do
    count = count + 1
  end
  return count
end

return M
