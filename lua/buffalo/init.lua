local Dev = require("buffalo.dev")
local api = require("buffalo.api")
local log = Dev.log
local buffer_is_valid = require("buffalo.utils").buffer_is_valid
local tab_is_valid = require("buffalo.utils").tab_is_valid
local merge_tables = require("buffalo.utils").merge_tables
--
local M = {}

M.marks = {}
M.tab_marks = {}

M.Config = M.Config or {}

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

function M.tabpages()
  local tabs = api.get_tabs()
  local count = 0
  for _, tab in pairs(tabs) do
    count = count + 1
  end
  return count
end

function M.init_buffers()
  local buffers = vim.api.nvim_list_bufs()

  for idx = 1, #buffers do
    local buf_id = buffers[idx]
    local buf_name = vim.api.nvim_buf_get_name(buf_id)
    local filename = buf_name
    -- if buffer is listed, then add to contents and marks
    if buffer_is_valid(buf_id, buf_name) then
      table.insert(
        M.marks,
        {
          filename = filename,
          buf_id = buf_id,
        }
      )
    end
  end
end

function M.init_tabs()
  local tabs = api.get_tabs()

  for idx = 1, #tabs do
    local tab_id = tabs[idx]
    local tab_name = api.get_tab_number(tab_id)
    local tab_wins = api.get_wins()
    -- if buffer is listed, then add to contents and marks
    -- if tab_is_valid(tab_id, tab_name, tab_wins) then
    table.insert(
      M.tab_marks,
      {
        tab_name = tab_name,
        tab_id = tab_id,
        tab_wins = tab_wins,
      }
    )
    -- end
  end
end

function M.setup(config)
  log.trace("setup(): Setting up...")

  if not config then
    config = {}
  end

  local default_config = {
    tab_commands = {
      edit = {
        key = "<CR>",
        command = "tabnext"
      }
    },
    buffer_commands = {
      edit = {
        key = "<CR>",
        command = "edit"
      }
    },
    cycle = true,
    exit_menu = "q",
  }

  local complete_config = merge_tables(default_config, config)

  M.Config = complete_config
  log.debug("setup(): Config", M.Config)
end

function M.get_config()
  log.trace("get_config()")
  return M.Config or {}
end

M.setup()

M.init_buffers()
M.init_tabs()

return M
