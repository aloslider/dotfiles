-- Highlight on yanking
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight in yanking",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- LSP
vim.keymap.del('n', "gra")
vim.keymap.del('n', "gri")
vim.keymap.del('n', "grn")
vim.keymap.del('n', "grr")
vim.keymap.del('n', "grt")

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LspKeymaps", { clear = true }),
  desc = "LSP keymaps",
  callback = function(event)
    local map = function(keys, func, desc, mode)
      mode = mode or "n"
      vim.keymap.set(mode, keys, func, {
        buffer = event.buf,
        desc = "[LSP] " .. desc,
        noremap = true,
        silent = true,
      })
    end

		map("<leader>ra", vim.lsp.buf.code_action, "Code action")
		map("<leader>rn", vim.lsp.buf.rename, "Rename")
		map("<leader>rr", vim.lsp.buf.references, "References")
		map("<leader>ri", vim.lsp.buf.implementation, "Go to implementation")
		map("<leader>rt", vim.lsp.buf.type_definition, "Go to type definition")
    map("<leader>rd", vim.lsp.buf.definition, "Go to definition")
    map("<leader>rD", vim.lsp.buf.declaration, "Go to declaration")
    map("<leader>K", vim.lsp.buf.hover, "Hover documentation")
  end,
})
