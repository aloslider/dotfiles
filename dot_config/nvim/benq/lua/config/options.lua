vim.opt.winborder = "rounded"
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.showtabline = 2
vim.opt.signcolumn = "yes"
vim.opt.showmode = false
vim.opt.wrap = true
vim.opt.cursorcolumn = false
vim.opt.ignorecase = true
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.list = false
vim.opt.listchars = {
  tab = "→ ",
  space = "·",
  nbsp = "⍽",
  trail = "·",
  extends = "…",
  precedes = "…",
  eol = "↲",
}

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldtext = ""
vim.opt.foldlevel = 99
vim.opt.fillchars:append({ fold = " " })

vim.filetype.add({
  pattern = {
    ["%.sh%.tmpl$"] = "sh",
    ["%.toml%.tmpl$"] = "toml",
  }
})
