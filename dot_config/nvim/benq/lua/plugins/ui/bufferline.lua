return {
  "akinsho/bufferline.nvim",
  lazy = false,
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",
  opts = {},
  keys = {
    { "<leader>bh",     "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer left" },
    { "<leader>bl",     "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer right" },
  },
}
