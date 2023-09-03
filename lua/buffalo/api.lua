local api = {}

function api.get_tabs()
  return vim.api.nvim_list_tabpages()
end

function api.get_tab_wins(tabid)
  local wins = vim.api.nvim_tabpage_list_wins(tabid)
  return vim.tbl_filter(api.is_not_float_win, wins)
end

function api.get_current_tab()
  return vim.api.nvim_get_current_tabpage()
end

function api.get_tab_current_win(tabid)
  return vim.api.nvim_tabpage_get_win(tabid)
end

function api.get_tab_number(tabid)
  return vim.api.nvim_tabpage_get_number(tabid)
end

function api.get_wins()
  local wins = vim.api.nvim_list_wins()
  return vim.tbl_filter(api.is_not_float_win, wins)
end

function api.get_win_tab(winid)
  return vim.api.nvim_win_get_tabpage(winid)
end

function api.is_float_win(winid)
  return vim.api.nvim_win_get_config(winid).relative ~= ''
end

function api.is_not_float_win(winid)
  return vim.api.nvim_win_get_config(winid).relative == ''
end

function api.get_win_buf(winid)
  return vim.api.nvim_win_get_buf(winid)
end

function api.get_buf_type(bufid)
  return vim.api.nvim_buf_get_option(bufid, 'buftype')
end

function api.get_buf_is_changed(bufid)
  return vim.fn.getbufinfo(bufid)[1].changed == 1
end

return api
