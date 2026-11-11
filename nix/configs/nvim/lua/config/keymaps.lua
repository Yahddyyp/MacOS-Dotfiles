-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

-- Insert mode
vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Files
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })

-- Buffers
vim.keymap.set("n", "<Tab>", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", "<cmd>bprev<cr>", { desc = "Previous buffer" })

for i = 1, 9 do
  vim.keymap.set("n", "g" .. i, "<cmd>BufferLineGoToBuffer " .. i .. "<cr>", {
    desc = "Go to buffer " .. i,
  })
end

vim.keymap.set("n", "g0", "<cmd>BufferLineGoToBuffer 10<cr>", { desc = "Go to buffer 10" })

-- Search and movement
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

vim.keymap.set("n", "n", "nzzzv", { desc = "Next match, centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous match, centered" })

vim.keymap.set({ "n", "o", "x" }, "H", "^", { desc = "Start of line" })
vim.keymap.set({ "n", "o", "x" }, "L", "$", { desc = "End of line" })

-- Editing
vim.keymap.set("n", "U", "<C-r>", { desc = "Redo" })
vim.keymap.set("n", "x", '"_x', { desc = "Delete character without copying" })

vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })

vim.keymap.set("n", "<leader>S", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], {
  desc = "Replace word under cursor",
})

-- LSP
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
