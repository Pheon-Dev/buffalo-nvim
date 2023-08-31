vim.api.nvim_create_user_command(
  'BuffaloToggle',
  require('buffalo').toggle,
  {}
)
