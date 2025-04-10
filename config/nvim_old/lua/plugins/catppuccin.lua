return {
  { -- further customize the options set by the community
    "catppuccin",
    opts = {
      transparent_background = vim.g.transparent_enabled,
      flavour = "mocha",
      dim_inactive = {
        enabled = true,
        shade = "dark",
        percentage = 0.1,
      },
      integrations = {
        sandwich = false,
        noice = true,
        mini = true,
        leap = true,
        markdown = true,
        render_markdown = true,
        telescope = {
          enabled = true,
        },
        neotest = true,
        neotree = true,
        nvimtree = true,
        notify = true,
        flash = true,
        cmp = true,
        dap = true,
        dap_ui = true,
        overseer = true,
        treesitter = true,
        lsp_trouble = true,
        rainbow_delimiters = true,
        dropbar = {
          enabled = true,
        },
      },
    },
  },
}
