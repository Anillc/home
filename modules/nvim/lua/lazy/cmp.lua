return {
  {
    "blink.cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    after = function()
      require("blink.cmp").setup({
        completion = {
          keyword = { range = "full" },
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 500,
          },
        },
        cmdline = {
          completion = { menu = { auto_show = true } },
          keymap = {
            preset = "inherit",
            ["<Esc>"] = {
              "hide",
              function()
                if vim.fn.getcmdtype() ~= "" then
                  vim.api.nvim_feedkeys(
                    vim.api.nvim_replace_termcodes("<C-c>", true, true, true),
                    "n",
                    true
                  )
                end
              end,
            },
          },
        },
        keymap = {
          preset = "none",
          ["<C-s>"] = { "show", "show_documentation", "hide_documentation" },
          ["<Esc>"] = { "hide", "fallback" },
          ["<Tab>"] = { "select_and_accept", "snippet_forward", "fallback" },
          ["<S-Tab>"] = { "snippet_backward", "fallback" },
          ["<Up>"] = { "select_prev", "fallback" },
          ["<Down>"] = { "select_next", "fallback" },
          ["<C-k>"] = { "select_prev", "fallback_to_mappings" },
          ["<C-j>"] = { "select_next", "fallback_to_mappings" },
          ["<C-h>"] = { "scroll_documentation_up", "fallback_to_mappings" },
          ["<C-l>"] = { "scroll_documentation_down", "fallback_to_mappings" },
          ["<C-d>"] = { "show_signature", "hide_signature", "fallback_to_mappings" },
        },
      })
    end,
  },
}
