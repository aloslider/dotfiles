require("config.autocmds")
require("config.options")
require("config.keymaps")

require("config.lazy")
require("config.theme") -- ignored by git

vim.lsp.enable({ "nixd" }) -- installed locally

})
