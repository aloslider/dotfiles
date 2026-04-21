require("config.autocmds")
require("config.filetypes")
require("config.keymaps")
require("config.options")

require("config.lazy")
require("config.theme") -- ignored by git

require("config.lsp")

vim.lsp.enable({
  "lua_ls",
  "html",
  "roslyn_ls",
})

require("config.diagnostics")
