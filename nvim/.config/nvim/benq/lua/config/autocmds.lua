-- Highlight on yanking
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight in yanking",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})
