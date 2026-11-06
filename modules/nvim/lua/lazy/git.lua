return {
  {
    "gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    after = function()
      require("gitsigns").setup({
        on_attach = function(bufnr)
          local gs = require("gitsigns")

          local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
          end

          map("]c", function() gs.nav_hunk("next") end, "Next hunk")
          map("[c", function() gs.nav_hunk("prev") end, "Previous hunk")

          map("<leader>hs", gs.stage_hunk, "Stage hunk")
          map("<leader>hu", gs.undo_stage_hunk, "Undo stage hunk")
          map("<leader>hr", gs.reset_hunk, "Reset hunk")
          map("<leader>hS", gs.stage_buffer, "Stage buffer")
          map("<leader>hR", gs.reset_buffer, "Reset buffer")
          map("<leader>hP", gs.preview_hunk, "Preview hunk")
          map("<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
          map("<leader>tb", gs.toggle_current_line_blame, "Toggle blame")
          map("<leader>hd", gs.diffthis, "Diff this")
          map("<leader>hD", function() gs.diffthis("~") end, "Diff project")
          map("<leader>td", gs.toggle_deleted, "Toggle deleted")
        end,
      })
    end,
  },
}
