require("config.filetypes")
require("config.keymaps")
require("config.options")
require("config.autocmds")

require("config.lazy")
require("config.theme") -- ignored by git

vim.lsp.enable({
  "html",
  "lua_ls",
  "nixd",
  "roslyn_ls",
})

require("config.diagnostics")
