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
        window = {
          mappings = {
            -- neo-tree maps s to open_vsplit by default, which shadows leap
            ["s"] = function()
              require("lz.n").trigger_load("leap.nvim")
              require("leap").leap({ target_windows = { vim.api.nvim_get_current_win() } })
            end,
            ["<C-v>"] = "open_vsplit",
          },
        },
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
    "multiple-cursors.nvim",
    keys = {
      { "<C-S-j>", "<cmd>MultipleCursorsAddDown<CR>", mode = { "n", "i", "x" } },
      { "<C-S-k>", "<cmd>MultipleCursorsAddUp<CR>", mode = { "n", "i", "x" } },
      { "<C-S-n>", "<cmd>MultipleCursorsAddJumpNextMatch<CR>", mode = { "n", "i", "x" } },
      { "<C-S-l>", "<cmd>MultipleCursorsLock<CR>", mode = { "n", "i", "x" } },
      { "<C-S-Return>", "<cmd>MultipleCursorsAddDelete<CR>", mode = { "n", "i", "x" } },
      { "<leader>mca", "<cmd>MultipleCursorsAddMatches<CR>", mode = { "n", "x" } },
      { "<leader>mcA", "<cmd>MultipleCursorsAddMatchesV<CR>", mode = { "n", "x" } },
      {
        "I",
        function()
          vim.cmd("MultipleCursorsAddVisualArea")
          vim.api.nvim_feedkeys("i", "n", false)
        end,
        mode = "x",
      },
    },
    after = function()
      require("multiple-cursors").setup({
        pre_hook = function()
          require("lz.n").trigger_load("nvim-autopairs")
          require("nvim-autopairs").disable()
        end,
        post_hook = function()
          require("nvim-autopairs").enable()
        end,
      })
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
