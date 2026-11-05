return {
  {
    "indent-blankline.nvim",
    lazy = false,
    after = function()
      require("ibl").setup()
    end,
  },
  {
    "lualine.nvim",
    lazy = false,
    after = function()
      require("lualine").setup()
    end,
  },
  {
    "bufferline.nvim",
    lazy = false,
    after = function()
      require("bufferline").setup({
        options = { numbers = "none" },
      })
    end,
  },
  {
    "which-key.nvim",
    event = "DeferredUIEnter",
    after = function()
      require("which-key").setup()
    end,
  },
}
