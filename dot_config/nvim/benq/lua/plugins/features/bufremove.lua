return {
	"nvim-mini/mini.bufremove",
	version = false,
	opts = {},
  keys = {
    { "<leader>bu", function() require("mini.bufremove").delete() end, desc = "Delete buffer" },
  },
}
