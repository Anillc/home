{ pkgs, lib, ... }: {
  programs.nvf = {
    enable = true;
    defaultEditor = true;
    settings.vim = {
      vimAlias = true;
      globals = {
        mapleader = " ";
        maplocalleader = "，";
      };
      options = {
        shiftwidth = 2;
        tabstop = 2;
        cursorline = true;
        wrap = false;
        winborder = "single";
      };
      keymaps = [
        { mode = "i"; key = "jj"; action = "<Esc>"; }
        { mode = "n"; key = "<leader><Tab>"; action = ":bn<CR>"; }
        { mode = "n"; key = "<leader><S-Tab>"; action = ":bp<CR>"; }
        { mode = "n"; key = "<leader>d"; action = ":bd<CR>"; }
        { mode = "n"; key = "<leader>w"; action = ":w<CR>"; }
        { mode = "n"; key = "<leader>q"; action = ":qa<CR>"; }
        { mode = [ "n" "v" ]; key = "<leader>y"; action = "\"+y"; }
        { mode = [ "n" "v" ]; key = "<leader>p"; action = "\"+p"; }
      ];

      # whichKey
      binds.whichKey.enable = true;

      # bufferline
      tabline.nvimBufferline = {
        enable = true;
        setupOpts.options.numbers = "none";
      };

      # lualine
      statusline.lualine.enable = true;

      # neo-tree
      filetree.neo-tree = {
        enable = true;
        setupOpts.close_if_last_window = true;
      };
      lazy.plugins.neo-tree-nvim.keys = [
        { mode = "n"; key = "<leader>e"; action = ":Neotree float<CR>"; }
      ];

      # leap
      lazy.plugins.leap-nvim = {
        package = "leap-nvim";
        keys = [
          { mode = [ "n" "x" "o" ]; key = "s"; action = "<Plug>(leap)"; }
          { mode = "n"; key = "S"; action = "<Plug>(leap-from-window)"; }
        ];
      };

      # multicursor
      utility.multicursors.enable = true;

      # comment-nvim
      comments.comment-nvim = {
        enable = true;
        mappings = {
          toggleCurrentLine = "<C-/>";
          toggleSelectedBlock = "<C-/>";
          toggleSelectedLine = "<C-/>";
        };
      };

      # nvim-autopairs
      autopairs.nvim-autopairs.enable = true;

      # sandwich
      lazy.plugins.vim-sandwich = {
        package = pkgs.vimPlugins.vim-sandwich;
        setupOpts.no_default_key_mappings = 1;
        keys = [
          { mode = [ "n" "x" "o" ]; key = "<leader>sa"; action = "<Plug>(sandwich-add)"; }
          { mode = [ "n" "x" ]; key = "<leader>sd"; action = "<Plug>(sandwich-delete)"; }
          { mode = [ "n" ]; key = "<leader>sdb"; action = "<Plug>(sandwich-delete-auto)"; }
          { mode = [ "n" "x" ]; key = "<leader>sr"; action = "<Plug>(sandwich-replace)"; }
          { mode = [ "n" ]; key = "<leader>srb"; action = "<Plug>(sandwich-replace-auto)"; }
        ];
      };

      # nvim-session-manager
      session.nvim-session-manager = {
        enable = true;
        setupOpts.autoload_mode = lib.generators.mkLuaInline ''
          (function()
            if vim.fn.getcwd() == vim.env.HOME then
              return sm.AutoloadMode.LastSession
            else
              return { sm.AutoloadMode.GitSession, sm.AutoloadMode.CurrentDir }
            end
          end)()
        '';
      };

      # gitsigns
      git.gitsigns.enable = true;

      # wakatime
      utility.vim-wakatime.enable = true;

      # blink-cmp
      autocomplete.blink-cmp = {
        enable = true;
        setupOpts = {
          completion = {
            keyword.range = "full";
            documentation = {
              auto_show = true;
              auto_show_delay_ms = 500;
            };
          };
          keymap = lib.mkForce {
            preset = "none";

            "<C-s>" = [ "show" "show_documentation" "hide_documentation" ];
            "<Esc>" = [ "hide" "fallback" ];
            "<Tab>" = [ "select_and_accept" "snippet_forward" "fallback" ];
            "<S-Tab>" = [ "snippet_backward" "fallback" ];
            "<Up>" = [ "select_prev" "fallback" ];
            "<Down>" = [ "select_next" "fallback" ];
            "<C-k>" = [ "select_prev" "fallback_to_mappings" ];
            "<C-j>" = [ "select_next" "fallback_to_mappings" ];
            "<C-h>" = [ "scroll_documentation_up" "fallback_to_mappings" ];
            "<C-l>" = [ "scroll_documentation_down" "fallback_to_mappings" ];
            "<C-d>" = [ "show_signature" "hide_signature" "fallback_to_mappings" ];
          };
        };
      };

      # lsp
      lsp.enable = true;
      languages = {
        enableTreesitter = true;
        enableFormat = true;

        nix.enable = true;
        markdown.enable = true;
        json.enable = true;
        yaml.enable = true;
        bash.enable = true;
        clang.enable = true;
        scala.enable = true;
        rust.enable = true;
        ts.enable = true;
        typst.enable = true;
        go.enable = true;
        # TODO: volar meson
      };
    };
  };
}
