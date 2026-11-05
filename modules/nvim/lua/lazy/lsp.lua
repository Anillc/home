return {
  {
    "nvim-treesitter",
    lazy = false,
    after = function()
      require("nvim-treesitter").setup()

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          pcall(vim.treesitter.start, ev.buf)
        end,
      })
    end,
  },
  {
    "nvim-lspconfig",
    lazy = false,
    after = function()
      vim.lsp.enable({
        "nixd",
        "lua_ls",
        "rust_analyzer",
        "ts_ls",
        "clangd",
        "tinymist",
        "marksman",
        "yamlls",
        "jsonls",
        "taplo",
      })
    end,
  },
}
