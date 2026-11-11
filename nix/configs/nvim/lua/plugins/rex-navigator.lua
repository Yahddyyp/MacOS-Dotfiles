return {
  "baggiponte/rex-navigator.nvim",
  enabled = vim.env.REX_SESSION ~= nil and vim.env.REX_SESSION ~= "",
  cmd = {
    "RexNavigateLeft",
    "RexNavigateDown",
    "RexNavigateUp",
    "RexNavigateRight",
  },
  keys = {
    { "<c-h>", "<cmd>RexNavigateLeft<cr>", desc = "Navigate Left" },
    { "<c-j>", "<cmd>RexNavigateDown<cr>", desc = "Navigate Down" },
    { "<c-k>", "<cmd>RexNavigateUp<cr>", desc = "Navigate Up" },
    { "<c-l>", "<cmd>RexNavigateRight<cr>", desc = "Navigate Right" },
  },
}
