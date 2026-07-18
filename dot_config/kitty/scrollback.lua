local buffer = 0
local table = table.concat(vim.api.nvim_buf_get_lines(buffer, 0, -1, false), "\n")

if table ~= "" and table:sub(-1) ~= "\n" then
  table = table .. "\n"
end

vim.api.nvim_buf_set_lines(buffer, 0, -1, false, {})
local channel = vim.api.nvim_open_term(buffer, {})
vim.api.nvim_chan_send(channel, table)
vim.bo.modified = false
vim.opt.clipboard = "unnamedplus"
vim.api.nvim_create_autocmd("TextYankPost", { buffer = buffer, callback = function() vim.schedule(function() vim.cmd("qa!") end) end })
vim.api.nvim_create_autocmd("QuitPre", { buffer = buffer, callback = function() vim.bo.modified = false end })
vim.cmd("normal! G")
