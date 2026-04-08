local find_cmd = {
  "fd",
  "--type", "f",
  "--type", "l",
  "--hidden",
  "--exclude", "Documents",
  "--exclude", "Public",
  "--exclude", "Music",
  "--exclude", "Movies",
  "--exclude", "Applications",
  "--exclude", "Library",
  "--exclude", ".cache",
  "--exclude", ".local",
  "--exclude", ".oh-my-zsh",
  "--exclude", ".zsh_sessions",
  "--exclude", ".vscode/extensions",
  "--exclude", ".vscode-oss",
  "--exclude", ".DS_Store",
  "--exclude", ".cargo/registry",
  "--exclude", ".config/opencode/node_modules",
  "--exclude", ".ssh",
  "--exclude", "atuin",
  "--exclude", "target/debug",
  "--exclude", ".config/raycast",
  "--exclude", ".git",
}

return {
  "nvim-telescope/telescope.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
  opts = {
    defaults = {
      file_ignore_patterns = {
        "Documents/",
        "Public/",
        "Music/",
        "Movies/",
        "Applications/",
        "Library/",
        ".cache/",
        ".local/",
        ".oh%-my%-zsh/",
        ".zsh_sessions/",
        ".vscode/extensions/",
        ".vscode%-oss/",
        ".DS_Store",
        "%.cargo/registry/",
        ".config/opencode/node_modules/",
        ".ssh/",
        "atuin/",
        "target/debug/",
        ".config/raycast/",
        "%.git/",
        "%.so$",
        "%.dylib$",
        "%.dll$",
        "%.exe$",
        "%.bin$",
        "%.o$",
        "%.a$",
        "%.pyc$",
        "%.class$",
        "%.jar$",
        "%.wasm$",
        "%.lock$",
      },
      mappings = {
        i = {
          ["<C-k>"] = "move_selection_previous",
          ["<C-j>"] = "move_selection_next",
        },
      },
    },
    pickers = {
      find_files = {
        hidden = true,
        no_ignore = false,
        find_command = find_cmd,
      },
    },
  },
  keys = {
    {
      "<leader>ff",
      function()
        require("telescope.builtin").find_files({ find_command = find_cmd })
      end,
      desc = "Find Files",
    },
    {
      "<leader><leader>",
      function()
        require("telescope.builtin").find_files({ find_command = find_cmd })
      end,
      desc = "Find Files",
    },
  },
}
