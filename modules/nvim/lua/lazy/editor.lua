return {
  {
    "neo-tree.nvim",
    cmd = "Neotree",
    keys = {
      { "<leader>e", "<cmd>Neotree float<CR>", desc = "NeoTree float" },
    },
    after = function()
      require("neo-tree").setup({
        close_if_last_window = true,
      })
    end,
  },
  {
    "leap.nvim",
    keys = {
      { "s", "<Plug>(leap)", mode = { "n", "x", "o" } },
      { "S", "<Plug>(leap-from-window)", mode = "n" },
    },
  },
  {
    "multicursors.nvim",
    keys = {
      { "<leader>mcu", "<cmd>MCunderCursor<CR>", mode = { "n", "v" }, desc = "Multicursor under cursor" },
      { "<leader>mcp", "<cmd>MCpattern<CR>", mode = { "n", "v" }, desc = "Multicursor pattern" },
      { "<leader>mcv", "<cmd>MCvisual<CR>", mode = { "n", "v" }, desc = "Multicursor visual" },
      { "<leader>mcb", "<cmd>MCvisualPattern<CR>", mode = { "n", "v" }, desc = "Multicursor visual pattern" },
    },
    after = function()
      require("multicursors").setup({})
    end,
  },
  {
    "vim-sandwich",
    before = function()
      vim.g.sandwich_no_default_key_mappings = 1
    end,
    keys = {
      { "<leader>swa", "<Plug>(sandwich-add)", mode = { "n", "x", "o" } },
      { "<leader>swd", "<Plug>(sandwich-delete)", mode = { "n", "x" } },
      { "<leader>swdb", "<Plug>(sandwich-delete-auto)", mode = "n" },
      { "<leader>swr", "<Plug>(sandwich-replace)", mode = { "n", "x" } },
      { "<leader>swrb", "<Plug>(sandwich-replace-auto)", mode = "n" },
    },
  },
  {
    "comment.nvim",
    lazy = false,
    after = function()
      require("Comment").setup()

      local api = require("Comment.api")

      vim.keymap.set("n", "<C-/>", api.toggle.linewise.current, { desc = "Toggle comment" })
      vim.keymap.set("x", "<C-/>", function()
        api.toggle.linewise(vim.fn.visualmode())
      end, { desc = "Toggle comment" })
    end,
  },
  {
    "nvim-autopairs",
    event = "InsertEnter",
    after = function()
      require("nvim-autopairs").setup({})
    end,
  },
}
