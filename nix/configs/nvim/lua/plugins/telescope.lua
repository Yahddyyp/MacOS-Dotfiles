return {
  "nvim-telescope/telescope.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
  },

  opts = {
    defaults = {
      file_ignore_patterns = {
        "%.git/",
      },

      mappings = {
        i = {
          ["<C-k>"] = "move_selection_previous",
          ["<C-j>"] = "move_selection_next",
        },
      },
    },
  },

  keys = {
    {
      "<leader>ff",
      function()
        require("telescope.builtin").find_files({ hidden = true })
      end,
      desc = "Find Files",
    },
    {
      "<leader><leader>",
      function()
        require("telescope.builtin").find_files({ hidden = true })
      end,
      desc = "Find Files",
    },
  },
}
