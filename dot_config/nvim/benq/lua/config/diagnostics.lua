vim.diagnostic.config({
  virtual_text = false,
  virtual_lines = {
    spacing = 2,
    source = "if_many",
    prefix = "●",
  },
  signs = true,
  update_in_insert = true,
  severity_sort = true,
  float = {
    border = "rounded",
    source = true,
  },
  jump = {
    wrap = true,
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float({
        bufnr = bufnr,
        scope = "cursor",
        focus = false,
      })
    end,
  },
})

vim.fn.sign_define('DapBreakpoint', {
  text = '⚪',
  texthl = 'DapBreakpointSymbol',
  linehl = 'DapBreakpoint',
  numhl = 'DapBreakpoint'
})
vim.fn.sign_define('DapStopped', {
  text = '🔴',
  texthl = 'yellow',
  linehl = 'DapBreakpoint',
  numhl = 'DapBreakpoint'
})
local a = 5
vim.fn.sign_define('DapBreakpointRejected', {
  text = '⭕',
  texthl = 'DapStoppedSymbol',
  linehl = 'DapBreakpoint',
  numhl = 'DapBreakpoint'
})

vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { underdotted = true, sp = "#e06c75" })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn",  { underdotted = true, sp = "#e5c07b" })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo",  { underdotted = true, sp = "#61afef" })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint",  { underdotted = true, sp = "#56b6c2" })
