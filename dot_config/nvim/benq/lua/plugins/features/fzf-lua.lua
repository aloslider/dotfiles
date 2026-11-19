local function search_in_root()
  local oil_ok, oil = pcall(require, "oil")
  if oil_ok and vim.bo.filetype == "oil" then
    return oil.get_current_dir()
  end
  local buf = vim.api.nvim_buf_get_name(0)
  if buf ~= "" and vim.fn.filereadable(buf) == 1 then
    return vim.fn.fnamemodify(buf, ":p:h")
  end
  return vim.fn.getcwd()
end

local function parse_cheatsheet(path)
  local cheats = {}
  if vim.fn.filereadable(path) ~= 1 then return cheats end
  for _, line in ipairs(vim.fn.readfile(path)) do
    line = vim.trim(line)
    if line ~= "" and not vim.startswith(line, "#") then
      local desc, code = line:match("^(.-)%s*|%s*(.+)$")
      if desc and code then
        table.insert(cheats, { desc, code })
      end
    end
  end
  return cheats
end

local function command_palette()
  local fzf = require("fzf-lua")
  local plugin = require("lazy.core.config").plugins["cheatsheet.nvim"]
  local sources = {
    vim.fn.stdpath("config") .. "/cheatsheet.txt",
  }

  if plugin then
    table.insert(sources, plugin.dir .. "/cheatsheets/cheatsheet-default.txt")
  end

  local lines, lookup = {}, {}
  for _, path in ipairs(sources) do
    for _, cheat in ipairs(parse_cheatsheet(path)) do
      local line = string.format("%-50s  %s", cheat[1], cheat[2])
      if not lookup[line] then
        table.insert(lines, line)
        lookup[line] = cheat[2]
      end
    end
  end

  local function cmdline_part(code)
    return code:match("^:([^%[{]*)")
  end

  fzf.fzf_exec(lines, {
    prompt = "Cheats> ",
    winopts = { fullscreen = false, height = 0.5, width = 0.7 },
    actions = {
      ["default"] = function(sel)
        local code = sel and lookup[sel[1]]
        if not code then return end
        local cmd = cmdline_part(code)
        if cmd then
          vim.api.nvim_feedkeys(":" .. cmd, "n", false)
        else
          vim.fn.setreg("+", code)
          vim.notify("Copied: " .. code)
        end
      end,
      -- Alt-Enter: execute immediately (only for plain commands)
      ["alt-enter"] = function(sel)
        local code = sel and lookup[sel[1]]
        local cmd = code and cmdline_part(code)
        if cmd then vim.cmd(cmd) end
      end,
    },
  })
end

return {
  "ibhagwan/fzf-lua",
  dependencies = {
    { "nvim-tree/nvim-web-devicons" },
    { "doctorfree/cheatsheet.nvim", lazy = true }
  },
  opts = {
    winopts = {
      fullscreen = true,
      preview = {
        layout = "vertical",
        vertical = "up:70%",
      }
    },
    keymap = {
      builtin = {
        true,
        ["<M-j>"] = "preview-down",
        ["<M-k>"] = "preview-up",
        ["<C-M-j>"] = "preview-page-down",
        ["<C-M-k>"] = "preview-page-up",
      },
      fzf = {
        ["ctrl-q"] = "select-all+accept"
      }
    }
  },
  keys = {
    {
      "<leader>ff",
      function() require("fzf-lua").files() end,
      desc = "Find files in project directory"
    },
    {
      "<leader>fF",
      function() require("fzf-lua").files({ cwd = search_in_root() }) end,
      desc = "Find files in current buffer's directory"
    },
    {
      "<leader>fg",
      function() require("fzf-lua").live_grep() end,
      desc = "Find by grepping in project directory"
    },
    {
      "<leader>fG",
      function() require("fzf-lua").live_grep({ cwd = search_in_root() }) end,
      desc = "Find by grepping in current buffer's directory"
    },
    {
      "<leader>fc",
      function() require("fzf-lua").files({ cwd = vim.fn.stdpath("config") }) end,
      desc = "Find in nvim config"
    },
    {
      "<leader>fh",
      function()
        require("fzf-lua").helptags()
      end,
      desc = "Find in help",
    },
    {
      "<leader>fk",
      function()
        require("fzf-lua").keymaps()
      end,
      desc = "Find keymaps",
    },
    {
      "<leader>fB",
      function()
        require("fzf-lua").builtin()
      end,
      desc = "Find built-in FZF",
    },
    {
      "<leader>fw",
      function()
        require("fzf-lua").grep_cword()
      end,
      desc = "Find current word",
    },
    {
      "<leader>fW",
      function()
        require("fzf-lua").grep_cWORD()
      end,
      desc = "Find current WORD",
    },
    {
      "<leader>fd",
      function()
        require("fzf-lua").diagnostics_document()
      end,
      desc = "Find diagnostics",
    },
    {
      "<leader>fr",
      function()
        require("fzf-lua").resume()
      end,
      desc = "Find resume",
    },
    {
      "<leader>fo",
      function()
        require("fzf-lua").oldfiles()
      end,
      desc = "Find old files",
    },
    {
      "<leader><leader>",
      function()
        require("fzf-lua").buffers()
      end,
      desc = "Find existing buffers",
    },
    {
      "<leader>/",
      function()
        require("fzf-lua").lgrep_curbuf()
      end,
      desc = "Live grep the current buffer",
    },
    {
      "<leader>fp",
      command_palette,
      desc = "Find command",
    }
  }
}
