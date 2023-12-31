local Path          = require("plenary.path")
local buffalo       = require("buffalo")
local popup         = require("plenary.popup")
local utils         = require("buffalo.utils")
local log           = require("buffalo.dev").log
local marks         = require("buffalo").marks
local api           = require("buffalo.api")

local M             = {}

Buffalo_win_id      = nil
Buffalo_bufh        = nil
Buffalo_Tabs_win_id = nil
Buffalo_Tabs_bufh   = nil

local initial_marks = {}
local config        = buffalo.get_config()

local function close_menu(force_save)
  force_save = force_save or false

  vim.api.nvim_win_close(Buffalo_win_id, true)

  Buffalo_win_id = nil
  Buffalo_bufh = nil
end

local function close_tabs_menu(force_save)
  force_save = force_save or false

  vim.api.nvim_win_close(Buffalo_Tabs_win_id, true)

  Buffalo_Tabs_win_id = nil
  Buffalo_Tabs_bufh = nil
end
local opts = { noremap = true }
local map  = vim.keymap.set

local function create_window(title)
  log.trace("_create_window()")

  local width = config.ui.width or 60
  local height = config.ui.height or 10
  local row = config.ui.row or 2
  local col = config.ui.col or 2

  local borderchars = config.ui.borderchars or { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
  local bufnr = vim.api.nvim_create_buf(false, false)

  local Buffalo_win_id, win = popup.create(bufnr, {
    title = "Buffalo [" .. title .. "]",
    highlight = "BuffaloWindow",
    titlehighlight = "BuffaloTitle",
    line = math.floor(((vim.o.lines - height) / row) - 1),
    col = math.floor((vim.o.columns - width) / col),
    minwidth = width,
    minheight = height,
    borderchars = borderchars,
  })

  vim.api.nvim_win_set_option(
    win.border.win_id,
    "winhl",
    "Normal:BuffaloBorder"
  )

  return {
    bufnr = bufnr,
    win_id = Buffalo_win_id,
  }
end


local function string_starts(string, start)
  return string.sub(string, 1, string.len(start)) == start
end

local function can_be_deleted(bufname, bufnr)
  return (
    vim.api.nvim_buf_is_valid(bufnr)
    and (not string_starts(bufname, "term://"))
    and (not vim.bo[bufnr].modified)
    and bufnr ~= -1
  )
end

local function is_buffer_in_marks(bufnr)
  for _, mark in pairs(marks) do
    if mark.buf_id == bufnr then
      return true
    end
  end
  return false
end

local function get_mark_by_name(name, specific_marks)
  local ref_name = nil
  for _, mark in pairs(specific_marks) do
    ref_name = mark.filename
    if string_starts(mark.filename, "term://") then
      ref_name = utils.get_short_term_name(mark.filename)
    else
      ref_name = utils.normalize_path(mark.filename)
    end
    if name == ref_name then
      return mark
    end
  end
  return nil
end

local function update_buffers()
  for _, mark in pairs(initial_marks) do
    if not is_buffer_in_marks(mark.buf_id) then
      if can_be_deleted(mark.filename, mark.buf_id) then
        vim.api.nvim_buf_clear_namespace(mark.buf_id, -1, 1, -1)
        vim.api.nvim_buf_delete(mark.buf_id, {})
      end
    end
  end

  for idx, mark in pairs(marks) do
    local bufnr = vim.fn.bufnr(mark.filename)
    if bufnr == -1 then
      vim.cmd("badd " .. mark.filename)
      marks[idx].buf_id = vim.fn.bufnr(mark.filename)
    end
  end
end

local function remove_mark(idx)
  marks[idx] = nil
  if idx < #marks then
    for i = idx, #marks do
      marks[i] = marks[i + 1]
    end
  end
end

local function update_marks()
  for idx, mark in pairs(marks) do
    if not utils.buffer_is_valid(mark.buf_id, mark.filename) then
      remove_mark(idx)
    end
  end
  for _, buf in pairs(vim.api.nvim_list_bufs()) do
    local bufname = vim.api.nvim_buf_get_name(buf)
    if utils.buffer_is_valid(buf, bufname) and not is_buffer_in_marks(buf) then
      table.insert(marks, {
        filename = bufname,
        buf_id = buf,
      })
    end
  end
end

function M.toggle_buf_menu()
  log.trace("toggle_buf_menu()")
  if Buffalo_win_id ~= nil and vim.api.nvim_win_is_valid(Buffalo_win_id) then
    if vim.api.nvim_buf_get_changedtick(vim.fn.bufnr()) > 0 then
      M.on_menu_save()
    end
    close_menu(true)
    update_buffers()
    return
  end
  local current_buf_id = -1
  current_buf_id = vim.fn.bufnr()

  local win_info = create_window("buffers")
  local contents = {}
  initial_marks = {}

  Buffalo_win_id = win_info.win_id
  Buffalo_bufh = win_info.bufnr

  update_marks()

  local current_buf_line = 1
  local line = 1
  local modified_lines = {}
  for idx, mark in pairs(marks) do
    if vim.fn.buflisted(mark.buf_id) ~= 1 then
      marks[idx] = nil
    else
      local current_mark = marks[idx]
      initial_marks[idx] = {
        filename = current_mark.filename,
        buf_id = current_mark.buf_id,
      }
      if vim.bo[current_mark.buf_id].modified then
        table.insert(modified_lines, line)
      end
      if current_mark.buf_id == current_buf_id then
        current_buf_line = line
      end
      local display_filename = current_mark.filename
      display_filename = utils.normalize_path(display_filename)
      contents[line] = string.format("%s", display_filename)
      line = line + 1
    end
  end

  vim.api.nvim_set_option_value("number", true, { win = Buffalo_win_id })
  vim.api.nvim_buf_set_name(Buffalo_bufh, "buffalo-buffers")
  vim.api.nvim_buf_set_lines(Buffalo_bufh, 0, #contents, false, contents)
  vim.api.nvim_buf_set_option(Buffalo_bufh, "filetype", "buffalo")
  vim.api.nvim_buf_set_option(Buffalo_bufh, "buftype", "acwrite")
  vim.api.nvim_buf_set_option(Buffalo_bufh, "bufhidden", "delete")
  vim.cmd(string.format(":call cursor(%d, %d)", current_buf_line, 1))
  vim.api.nvim_buf_set_keymap(
    Buffalo_bufh,
    "n",
    "q",
    "<Cmd>lua require('buffalo.ui').toggle_buf_menu()<CR>",
    { silent = true }
  )
  vim.api.nvim_buf_set_keymap(
    Buffalo_bufh,
    "n",
    config.general_commands.exit_menu,
    "<Cmd>lua require('buffalo.ui').toggle_buf_menu()<CR>",
    { silent = true }
  )
  vim.api.nvim_buf_set_keymap(
    Buffalo_bufh,
    "n",
    "<ESC>",
    "<Cmd>lua require('buffalo.ui').toggle_buf_menu()<CR>",
    { silent = true }
  )
  for _, value in pairs(config.buffer_commands) do
    if type(value.command) == "string" then
      vim.api.nvim_buf_set_keymap(
        Buffalo_bufh,
        "n",
        value.key,
        "<Cmd>lua require('buffalo.ui').select_menu_item('" .. value.command .. "')<CR>",
        {}
      )
    end
    if type(value.command) == "function" then
      vim.keymap.set(
        "n",
        value.key,
        value.command,
        {buffer = Buffalo_bufh }
      )
    end
  end
  vim.cmd(
    string.format(
      "autocmd BufModifiedSet <buffer=%s> set nomodified",
      Buffalo_bufh
    )
  )
  vim.cmd(
    "autocmd BufLeave <buffer> ++nested ++once silent" ..
    " lua require('buffalo.ui').toggle_buf_menu()"
  )
  vim.cmd(
    string.format(
      "autocmd BufWriteCmd <buffer=%s>" ..
      " lua require('buffalo.ui').on_menu_save()",
      Buffalo_bufh
    )
  )
  local str = "1234567890"

  for i = 1, #str do
    local c = str:sub(i, i)
    vim.api.nvim_buf_set_keymap(
      Buffalo_bufh,
      "n",
      c,
      string.format(
        "<Cmd>%s <bar> lua require('buffalo.ui')" ..
        ".select_menu_item()<CR>",
        i
      ),
      {}
    )
  end


  for _, modified_line in pairs(modified_lines) do
    vim.api.nvim_buf_add_highlight(
      Buffalo_bufh,
      -1,
      "BuffaloBuffersModified",
      modified_line - 1,
      0,
      -1
    )
  end
  vim.api.nvim_buf_add_highlight(
    Buffalo_bufh,
    -1,
    "BuffaloBuffersCurrentLine",
    current_buf_line - 1,
    0,
    -1
  )
end

function M.toggle_tab_menu()
  log.trace("toggle_tab_menu()")
  if Buffalo_Tabs_win_id ~= nil and vim.api.nvim_win_is_valid(Buffalo_Tabs_win_id) then
    close_tabs_menu(true)
    return
  end
  local tabid = api.get_current_tab()
  local current_tab_id = api.get_tab_number(tabid)
  local tabs = api.get_tabs()

  local win_info = create_window("tabpages")
  local contents = {}

  Buffalo_Tabs_win_id = win_info.win_id
  Buffalo_Tabs_bufh = win_info.bufnr

  local current_tab_line = 1

  for idx = 1, #tabs do
    local current_tab = api.get_tab_number(idx)
    if current_tab == current_tab_id then
      current_tab_line = idx
    end

    if current_tab == 0 then
      return
    end
    if current_tab > 0 then
      local twins = api.get_tab_wins(idx)
      local window = #twins > 1 and "[ " .. #twins .. " windows ]" or "[ " .. #twins .. " window ]"
      contents[idx] = string.format("Tab %s %s", current_tab, window)
    else
      contents[idx] = string.format("Tab [ deleted ]")
    end
  end

  vim.api.nvim_set_option_value("number", true, { win = Buffalo_Tabs_win_id })

  vim.api.nvim_buf_set_name(Buffalo_Tabs_bufh, "buffalo-tabs")
  vim.api.nvim_buf_set_lines(Buffalo_Tabs_bufh, 0, #contents, false, contents)
  vim.api.nvim_buf_set_option(Buffalo_Tabs_bufh, "filetype", "buffalo")
  vim.api.nvim_buf_set_option(Buffalo_Tabs_bufh, "buftype", "acwrite")
  vim.api.nvim_buf_set_option(Buffalo_Tabs_bufh, "bufhidden", "delete")
  vim.cmd(string.format(":call cursor(%d, %d)", current_tab_line, 1))
  vim.api.nvim_buf_set_keymap(
    Buffalo_Tabs_bufh,
    "n",
    config.general_commands.exit_menu,
    "<Cmd>lua require('buffalo.ui').toggle_tab_menu()<CR>",
    { silent = true }
  )
  vim.api.nvim_buf_set_keymap(
    Buffalo_Tabs_bufh,
    "n",
    "q",
    "<Cmd>lua require('buffalo.ui').toggle_tab_menu()<CR>",
    { silent = true }
  )
  vim.api.nvim_buf_set_keymap(
    Buffalo_Tabs_bufh,
    "n",
    "<ESC>",
    "<Cmd>lua require('buffalo.ui').toggle_tab_menu()<CR>",
    { silent = true }
  )
  for _, value in pairs(config.tab_commands) do
    vim.api.nvim_buf_set_keymap(
      Buffalo_Tabs_bufh,
      "n",
      value.key,
      "<Cmd>lua require('buffalo.ui').select_tab_menu_item('" .. value.command .. "')<CR>",
      {}
    )
  end
  vim.cmd(
    string.format(
      "autocmd BufModifiedSet <buffer=%s> set nomodified",
      Buffalo_Tabs_bufh
    )
  )
  vim.cmd(
    "autocmd BufLeave <buffer> ++nested ++once silent" ..
    " lua require('buffalo.ui').toggle_tab_menu()"
  )
  vim.cmd(
    string.format(
      "autocmd BufWriteCmd <buffer=%s>" ..
      " lua require('buffalo.ui').on_menu_save()",
      Buffalo_Tabs_bufh
    )
  )
  local str = "1234567890"

  for i = 1, #str do
    local c = str:sub(i, i)
    vim.api.nvim_buf_set_keymap(
      Buffalo_Tabs_bufh,
      "n",
      c,
      string.format(
        "<Cmd>%s <bar> lua require('buffalo.ui')" ..
        ".select_tab_menu_item()<CR>",
        i
      ),
      {}
    )
  end
  vim.api.nvim_buf_add_highlight(
    Buffalo_Tabs_bufh,
    -1,
    "BuffaloTabsCurrentLine",
    current_tab_line - 1,
    0,
    -1
  )
end

function M.select_tab_menu_item(command)
  local idx = vim.fn.line(".")
  close_tabs_menu(true)
  M.nav_tab(idx, command)
end

function M.select_menu_item(command)
  local idx = vim.fn.line(".")
  if vim.api.nvim_buf_get_changedtick(vim.fn.bufnr()) > 0 then
    M.on_menu_save()
  end
  close_menu(true)
  M.nav_buf(idx, command)
  update_buffers()
end

local function get_menu_items()
  log.trace("_get_menu_items()")
  local lines = vim.api.nvim_buf_get_lines(Buffalo_bufh, 0, -1, true)
  local indices = {}

  for _, line in pairs(lines) do
    if not utils.is_white_space(line) then
      table.insert(indices, line)
    end
  end

  return indices
end

local function set_mark_list(new_list)
  log.trace("set_mark_list(): New list:", new_list)

  local original_marks = utils.deep_copy(marks)
  marks = {}
  for _, v in pairs(new_list) do
    if type(v) == "string" then
      local filename = v
      local buf_id = nil
      local current_mark = get_mark_by_name(filename, original_marks)
      if current_mark then
        filename = current_mark.filename
        buf_id = current_mark.buf_id
      else
        buf_id = vim.fn.bufnr(v)
      end
      table.insert(marks, {
        filename = filename,
        buf_id = buf_id,
      })
    end
  end
end

function M.on_menu_save()
  log.trace("on_menu_save()")
  set_mark_list(get_menu_items())
end

function M.nav_tab(id, command)
  log.trace("nav_buf(): Navigating to", id)

  if command == nil or command == "tabnext" then
    local tabid = api.get_tab_number(id)
    if tabid ~= -1 then
      vim.cmd(tabid .. "tabnext")
    end
  elseif command == "tabclose" then
    -- vim.api.nvim_tabpage_del_var(id, "buffalo")
    vim.cmd(id .. "tabclose")
  else
    vim.cmd(id .. command)
  end
end

function M.nav_buf(id, command)
  log.trace("nav_buf(): Navigating to", id)
  update_marks()

  local mark = marks[id]
  if not mark then
    return
  end
  if command == nil or command == "edit" then
    local bufnr = vim.fn.bufnr(mark.filename)
    if bufnr ~= -1 then
      vim.cmd("buffer " .. bufnr)
    else
      vim.cmd("edit " .. mark.filename)
    end
  else
    vim.cmd(command .. " " .. mark.filename)
  end
end

local function get_current_buf_line()
  local current_buf_id = vim.fn.bufnr()
  for idx, mark in pairs(marks) do
    if mark.buf_id == current_buf_id then
      return idx
    end
  end
  log.error("get_current_buf_line(): Could not find current buffer in marks")
  return -1
end

function M.nav_tab_next()
  log.trace("nav_tab_next()")
  vim.cmd("tabnext")
end

function M.nav_tab_prev()
  log.trace("nav_tab_prev()")
  vim.cmd("tabprev")
end

function M.nav_buf_next()
  log.trace("nav_buf_next()")
  update_marks()
  local current_buf_line = get_current_buf_line()
  if current_buf_line == -1 then
    return
  end
  local next_buf_line = current_buf_line + 1
  if next_buf_line > #marks then
    if config.general_commands.cycle then
      M.nav_buf(1)
    end
  else
    M.nav_buf(next_buf_line)
  end
end

function M.nav_buf_prev()
  log.trace("nav_buf_prev()")
  update_marks()
  local current_buf_line = get_current_buf_line()
  if current_buf_line == -1 then
    return
  end
  local prev_buf_line = current_buf_line - 1
  if prev_buf_line < 1 then
    if config.general_commands.cycle then
      M.nav_buf(#marks)
    end
  else
    M.nav_buf(prev_buf_line)
  end
end

function M.location_window(options)
  local default_options = {
    relative = "editor",
    style = "minimal",
    width = 30,
    height = 15,
    row = 2,
    col = 2,
  }
  options = vim.tbl_extend("keep", options, default_options)

  local bufnr = options.bufnr or vim.api.nvim_create_buf(false, true)
  local win_id = vim.api.nvim_open_win(bufnr, true, options)

  return {
    bufnr = bufnr,
    win_id = win_id,
  }
end

function M.save_menu_to_file(filename)
  log.trace("save_menu_to_file()")
  if filename == nil or filename == "" then
    filename = vim.fn.input("Enter filename: ")
    if filename == "" then
      return
    end
  end
  local file = io.open(filename, "w")
  if file == nil then
    log.error("save_menu_to_file(): Could not open file for writing")
    return
  end
  for _, mark in pairs(marks) do
    file:write(Path:new(mark.filename):absolute() .. "\n")
  end
  file:close()
end

function M.load_menu_from_file(filename)
  log.trace("load_menu_from_file()")
  if filename == nil or filename == "" then
    filename = vim.fn.input("Enter filename: ")
    if filename == "" then
      return
    end
  end
  local file = io.open(filename, "r")
  if file == nil then
    log.error("load_menu_from_file(): Could not open file for reading")
    return
  end
  local lines = {}
  for line in file:lines() do
    table.insert(lines, line)
  end
  file:close()
  set_mark_list(lines)
  update_buffers()
end

local go_to = config.go_to
if go_to.enabled then
  local keys = "1234567890"

  for i = 1, #keys do
    local buffer = keys:sub(i, i)
    map(
      'n',
      string.format(go_to.go_to_buffer, buffer),
      function() M.nav_buf(i) end,
      opts
    )
  end

  for i = 1, #keys do
    local tab = keys:sub(i, i)
    map(
      'n',
      string.format(go_to.go_to_tab, tab),
      function() M.nav_tab(i) end,
      opts
    )
  end
end

local filter = config.filter
if filter.enabled then
  map({ 't', 'n' }, filter.filter_tabs, function()
    M.toggle_tab_menu()

    vim.defer_fn(function()
      vim.fn.feedkeys('/')
    end, 50)
  end, opts)

  map({ 't', 'n' }, filter.filter_buffers, function()
    M.toggle_buf_menu()

    vim.defer_fn(function()
      vim.fn.feedkeys('/')
    end, 50)
  end, opts)
end
return M
