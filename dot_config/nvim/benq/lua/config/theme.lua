vim.cmd.colorscheme("vscode")

vim.api.nvim_set_hl(0, "@lsp.type.extensionMethod", { link = "@function.method" })
vim.api.nvim_set_hl(0, "@lsp.type.extensionMethod.cs", { link = "@function.method" })
