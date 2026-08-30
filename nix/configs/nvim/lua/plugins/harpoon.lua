return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")
    harpoon:setup()

    local keymap = vim.keymap.set

    keymap("n", "<leader>ha", function()
      harpoon:list():add()
    end, { desc = "Harpoon Add File" })
    keymap("n", "<leader>he", function()
      harpoon.ui:toggle_quick_menu(harpoon:list())
    end, { desc = "Harpoon Quick Menu" })

    keymap("n", "<C-h>", function()
      harpoon:list():select(1)
    end, { desc = "Harpoon to File 1" })
    keymap("n", "<C-t>", function()
      harpoon:list():select(2)
    end, { desc = "Harpoon to File 2" })
    keymap("n", "<C-n>", function()
      harpoon:list():select(3)
    end, { desc = "Harpoon to File 3" })
    keymap("n", "<C-s>", function()
      harpoon:list():select(4)
    end, { desc = "Harpoon to File 4" })

    keymap("n", "<C-S-P>", function()
      harpoon:list():prev()
    end, { desc = "Harpoon Prev" })
    keymap("n", "<C-S-N>", function()
      harpoon:list():next()
    end, { desc = "Harpoon Next" })

    -- Telescope integration
    local conf = require("telescope.config").values
    local function toggle_telescope(harpoon_files)
      local finder = function()
        local paths = {}
        for _, item in ipairs(harpoon_files.items) do
          table.insert(paths, item.value)
        end
        return require("telescope.finders").new_table({ results = paths })
      end

      require("telescope.pickers")
        .new({}, {
          prompt_title = "Harpoon",
          finder = finder(),
          previewer = conf.file_previewer({}),
          sorter = conf.generic_sorter({}),
        })
        :find()
    end

    keymap("n", "<leader>hh", function()
      toggle_telescope(harpoon:list())
    end, { desc = "Open Harpoon Telescope Window" })
  end,
}
