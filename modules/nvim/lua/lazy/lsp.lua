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
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc })
          end

          map("<leader>lgd", vim.lsp.buf.definition, "Go to definition")
          map("<leader>lgD", vim.lsp.buf.declaration, "Go to declaration")
          map("<leader>lgt", vim.lsp.buf.type_definition, "Go to type definition")
          map("<leader>lgi", vim.lsp.buf.implementation, "List implementations")
          map("<leader>lgr", vim.lsp.buf.references, "List references")
          map("<leader>lgn", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")
          map("<leader>lgp", function() vim.diagnostic.jump({ count = -1 }) end, "Previous diagnostic")
          map("<leader>le", vim.diagnostic.open_float, "Open diagnostic float")
          map("<leader>lH", vim.lsp.buf.document_highlight, "Document highlight")
          map("<leader>lS", vim.lsp.buf.document_symbol, "Document symbols")
          map("<leader>lh", vim.lsp.buf.hover, "Hover")
          map("<leader>ls", vim.lsp.buf.signature_help, "Signature help")
          map("<leader>ln", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>la", vim.lsp.buf.code_action, "Code action")
          map("<leader>lf", vim.lsp.buf.format, "Format")
        end,
      })

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
