return {
  "ray-x/lsp_signature.nvim",
  event = "InsertEnter",
  opts = {
    always_trigger = false,
    max_height = 40,
    min_height = 2,
    max_width = 10,
    doc_lines = 40,
    hint_prefix = {
      above = "↙ ",
      current = "← ",
      below = "↖ ",
    },
    toggle_key = '<M-x>',
    select_signature_key = '<M-s>',
  },
  keys = {
    {
      mode = { "n" },
      "<leader>k",
      function()
        vim.lsp.buf.signature_help({
          max_width = math.floor(vim.o.columns * 0.6),
          height = 14,
          wrap = true,
          anchor_bias = "above",
        })
      end,
      desc = "Toggle signature help",
    },
  },
}
