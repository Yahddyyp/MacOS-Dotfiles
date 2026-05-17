-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("i", "jj", "<Esc>", { desc = "Escape insert mode" })
vim.keymap.set("i", "jk", "<Esc>", { desc = "Escape insert mode" })
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })

vim.keymap.set("n", "<Tab>", ":bnext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", ":bprev<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next match (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous match (centered)" })
vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })
vim.keymap.set("n", "x", '"_x', { desc = "Delete character without copying" })
vim.keymap.set("v", "p", '"_dP', { desc = "Paste without overwriting registry" })
vim.keymap.set(
  "n",
  "<leader>S",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Replace word under cursor" }
)
vim.keymap.set("n", "<leader>fX", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make file executable" })
vim.keymap.set("t", "jk", "<C-\\><C-n>", { noremap = true })
vim.keymap.set("n", "<leader>h", function()
  vim.cmd("enew")
  require("snacks").dashboard()
end, { desc = "Open dashboard" })
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP Rename" })

-- Redo and line navigation alternatives
vim.keymap.set("n", "U", "<C-r>", { desc = "Redo" })
vim.keymap.set("n", "<C-d>", "$", { desc = "Go to end of line" })
vim.keymap.set("n", "<C-a>", "^", { desc = "Go to start of line" })

vim.keymap.set("n", "<C-q>", "<cmd>bdelete<CR>", { desc = "Close current tab" }) -- shift+Quit to close current tab
vim.keymap.set("n", "g1", "<cmd>BufferLineGoToBuffer 1<CR>", { desc = "Go to buffer 1" })
vim.keymap.set("n", "g2", "<cmd>BufferLineGoToBuffer 2<CR>", { desc = "Go to buffer 2" })
vim.keymap.set("n", "g3", "<cmd>BufferLineGoToBuffer 3<CR>", { desc = "Go to buffer 3" })
vim.keymap.set("n", "g4", "<cmd>BufferLineGoToBuffer 4<CR>", { desc = "Go to buffer 4" })
vim.keymap.set("n", "g5", "<cmd>BufferLineGoToBuffer 5<CR>", { desc = "Go to buffer 5" })
vim.keymap.set("n", "g6", "<cmd>BufferLineGoToBuffer 6<CR>", { desc = "Go to buffer 6" })
vim.keymap.set("n", "g7", "<cmd>BufferLineGoToBuffer 7<CR>", { desc = "Go to buffer 7" })
vim.keymap.set("n", "g8", "<cmd>BufferLineGoToBuffer 8<CR>", { desc = "Go to buffer 8" })
vim.keymap.set("n", "g9", "<cmd>BufferLineGoToBuffer 9<CR>", { desc = "Go to buffer 9" })
vim.keymap.set("n", "g0", "<cmd>BufferLineGoToBuffer 10<CR>", { desc = "Go to buffer 10" })
vim.keymap.set("n", "<M-j>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Move to left buffer" }) -- Alt+j to move to left
vim.keymap.set("n", "<M-k>", "<cmd>BufferLineCycleNext<CR>", { desc = "Move to right buffer" }) -- Alt+k to move to right
vim.keymap.set("n", "<M-J>", "<cmd>BufferLineMovePrev<CR>", { desc = "Move buffer to the left" }) -- Alt+Shift+j grab to with you to left
vim.keymap.set("n", "<M-K>", "<cmd>BufferLineMoveNext<CR>", { desc = "Move buffer to the right" }) -- Alt+Shift+k grab to with you to right

vim.keymap.set("n", "<leader>si", function()
  require("telescope.builtin").find_files({
    attach_mappings = function(prompt_bufnr, map)
      map("i", "<CR>", function()
        local selection = require("telescope.actions.state").get_selected_entry()
        require("telescope.actions").close(prompt_bufnr)
        vim.cmd("split " .. selection.value)
      end)
      return true
    end,
  })
end, { desc = "Split horizontal with Telescope" })
vim.keymap.set("n", "<leader>sv", function()
  require("telescope.builtin").find_files({
    attach_mappings = function(prompt_bufnr, map)
      map("i", "<CR>", function()
        local selection = require("telescope.actions.state").get_selected_entry()
        require("telescope.actions").close(prompt_bufnr)
        vim.cmd("vsplit " .. selection.value)
      end)
      return true
    end,
  })
end, { desc = "Split vertical with Telescope" })
