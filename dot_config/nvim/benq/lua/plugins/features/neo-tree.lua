return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    filesystem = {
      hijack_netrw_behavior = "disabled",
      follow_current_file = {
        enabled = true,
      },
      window = {
        mappings = {
          ["R"] = "easy",
        },
      },
      commands = {
        ["easy"] = function(state)
          local node = state.tree:get_node()
          local path = node.type == "directory" and node.path or vim.fs.dirname(node.path)
          require("easy-dotnet").create_new_item(path, function()
            require("neo-tree.sources.manager").refresh(state.name)
          end)
        end
      }
    },
  },
  keys = {
    {
      "<leader>e",
      function()
        require("neo-tree.command").execute({ toggle = true })
      end,
      desc = "Open neo-tree"
    },
  }
}
