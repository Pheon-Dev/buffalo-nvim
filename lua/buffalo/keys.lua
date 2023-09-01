local M = {}

function M.keys()
  vim.api.nvim_buf_set_keymap(
    Buffalo_bufh,
    "n",
    "q",
    "<Cmd>lua require('buffalo.ui').toggle_quick_menu()<CR>",
    { silent = true }
  )
  vim.api.nvim_buf_set_keymap(
    Buffalo_bufh,
    "n",
    "<ESC>",
    "<Cmd>lua require('buffalo.ui').toggle_quick_menu()<CR>",
    { silent = true }
  )
  for _, value in pairs(config.select_menu_item_commands) do
    vim.api.nvim_buf_set_keymap(
      Buffalo_bufh,
      "n",
      value.key,
      "<Cmd>lua require('buffalo.ui').select_menu_item('" .. value.command .. "')<CR>",
      {}
    )
  end
  vim.cmd(
    string.format(
      "autocmd BufModifiedSet <buffer=%s> set nomodified",
      Buffalo_bufh
    )
  )
  vim.cmd(
    "autocmd BufLeave <buffer> ++nested ++once silent" ..
    " lua require('buffalo.ui').toggle_quick_menu()"
  )
  vim.cmd(
    string.format(
      "autocmd BufWriteCmd <buffer=%s>" ..
      " lua require('buffalo.ui').on_menu_save()",
      Buffalo_bufh
    )
  )
  -- Go to file hitting its line number
  local str = config.line_keys
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
end

return M
