return {
  "nvim-mini/mini.notify",
  version = "*",
  opts = {},
  keys = {
    { "<ESC>", function() require("mini.notify").clear() end, desc = "Clear notification popup" },
  }
}
