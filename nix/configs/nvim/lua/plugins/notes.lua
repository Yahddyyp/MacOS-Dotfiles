return {
  {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      workspaces = {
        {
          name = "personal",
          path = "~/Desktop/e/Vault",
        },
      },
      ui = {
        enable = false,
      },
    },
    config = function(_, opts)
      require("obsidian").setup(opts)

      -- force a clean re-render once obsidian has fully attached, so load
      -- order between obsidian.nvim and render-markdown.nvim can't leave
      -- half-applied extmarks on the buffer
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          vim.opt_local.conceallevel = 3
          vim.opt_local.concealcursor = "nc"
          vim.schedule(function()
            pcall(vim.cmd, "RenderMarkdown enable")
          end)
        end,
      })
    end,
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },            -- if you use the mini.nvim suite
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.icons" }, -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },

  -- {
  --   "3rd/image.nvim",
  --   build = false, -- so it doesn't try to build the rock
  --   opts = {
  --     processor = "magick_cli",
  --   },
  -- },
}
