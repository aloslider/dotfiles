require("config.autocmds")
require("config.options")
require("config.keymaps")

require("config.lazy")
require("config.theme") -- ignored by git

require("config.lsp")

vim.lsp.enable({
  "lua_ls",
  "html",
  "roslyn_ls",
})

require("config.diagnostics")
