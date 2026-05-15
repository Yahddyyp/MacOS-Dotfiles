return {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
        opts.options.theme = require("mauve-nvim.integrations.lualine")
        opts.sections.lualine_z = {
            function()
                return " " .. os.date("%I:%M %p")
            end,
        }
    end,
}

