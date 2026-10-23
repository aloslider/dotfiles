return {
  "GustavEikaas/easy-dotnet.nvim",
  enabled = true,
  lazy = false,
  dependencies = { "nvim-lua/plenary.nvim", "mfussenegger/nvim-dap", "ibhagwan/fzf-lua", },
  opts = {
    test_runner = {
      neotest_integration = true,
    },
  },
  keys = {
    { "<leader>dn", "<cmd>Dotnet<cr>", desc = "Open easy-dotnet" },
  }
}
