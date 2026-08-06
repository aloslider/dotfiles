return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install({
        "bash",
        "c",
        "c_sharp",
        "caddy",
        "css",
        "csv",
        "html",
        "javascript",
        "json",
        "latex",
        "markdown",
        "markdown_inline",
        "nix",
        "sql",
        "typescript",
        "typst",
        "vimdoc",
        "yaml",
        "zsh",
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    init = function()
      vim.g.no_plugin_maps = true
    end,
    opts = {
      -- select = {
      --   enable = true,
      --   lookahead = true,
      --   keymaps = {
      --     ["aa"] = "@parameter.outer",
      --     ["ia"] = "@parameter.inner",
      --     ["af"] = "@function.outer",
      --     ["if"] = "@function.inner",
      --     ["ac"] = "@class.outer",
      --     ["ic"] = "@class.inner",
      --   }
      -- },
    }
  }
}
