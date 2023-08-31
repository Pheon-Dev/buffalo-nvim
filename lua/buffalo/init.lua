local M = {}

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
