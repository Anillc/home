return {
  {
    "auto-session",
    lazy = false,
    after = function()
      require("auto-session").setup({
        auto_restore_enabled = true,
        auto_session_suppress_abbreviate = true,
      })
    end,
  },
}
