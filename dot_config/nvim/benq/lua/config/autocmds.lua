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

-- Floating terminal
vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>")

local state = {
  floating = {
    buf = -1,
    win = -1,
  }
}

local function create_floating_window(opts)
  opts = opts or {}

  local width = opts.width or math.floor(vim.o.columns * 0.8)
  local height = opts.height or math.floor(vim.o.lines * 0.8)

  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local buf = nil
  if vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true)
  end

  local win_config = {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    style = "minimal",
    border = "rounded",
  }

  local win = vim.api.nvim_open_win(buf, true, win_config)

  return { buf = buf, win = win }
end

local toggle_terminal = function()
  if not vim.api.nvim_win_is_valid(state.floating.win) then
    state.floating = create_floating_window { buf = state.floating.buf }
    if vim.bo[state.floating.buf].buftype ~= "terminal" then
      vim.cmd.terminal()
    end
  else
    vim.api.nvim_win_hide(state.floating.win)
  end
end

vim.api.nvim_create_user_command("FloatingTerminal", toggle_terminal, {})
vim.keymap.set({ "n", "t" }, "<leader>tt", toggle_terminal, { desc = "Toggle floating terminal" })
