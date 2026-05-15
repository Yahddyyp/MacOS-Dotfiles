return {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
        opts.options.theme = function()
            if vim.g.colors_name == "mauve" then
                return require("mauve-nvim.integrations.lualine")
            end
            return "auto"
        end
        opts.sections.lualine_z = {
            function()
                return " " .. os.date("%I:%M %p")
            end,
        }
    end,
}
