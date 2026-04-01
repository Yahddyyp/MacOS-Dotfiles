return {
  "xiyaowong/transparent.nvim",
  config = function()
    require("transparent").setup({
      clear_prefix = "transparent",
      groups = {
        "Normal", "NormalNC", "Comment", "Constant", "Special", "Identifier",
        "Statement", "PreProc", "Type", "Underlined", "Todo", "String", "Function",
        "Conditional", "Repeat", "Operator", "Structure", "LineNr", "NonText",
        "SignColumn", "CursorLine", "CursorLineNr", "StatusLine", "StatusLineNC",
        "EndOfBuffer", "CursorColumn", "CursorLineNr", "FoldBackground",
        "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeWinSeparator",
      },
      exclude_groups = {},
    })
    require("transparent").clear_prefix("transparent")
    vim.g.transparent_enabled = true  -- Enable for themes that check this
  end,
}
