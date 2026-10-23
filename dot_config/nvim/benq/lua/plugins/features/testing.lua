return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("easy-dotnet.neotest")
        }
      })
    end,
    keys = {
      { "<leader>trn", function() require("neotest").run.run() end,                     desc = "Run nearest test" },
      { "<leader>tra", function() require("neotest").run.run({ suite = true }) end,     desc = "Run all tests" },
      { "<leader>td",  function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Run nearest test with debugger" },
      { "<leader>ts",  function() require("neotest").summary.toggle() end,              desc = "Toggle test summary" },
    }
  }
}
