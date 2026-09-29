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
        list = true;
        listchars = "space:·,tab: →";
      };
      keymaps = [
        { mode = "i"; key = "jj"; action = "<Esc>"; }
        { mode = "i"; key = "<C-k>"; action = "<Up>"; }
        { mode = "i"; key = "<C-j>"; action = "<Down>"; }
        { mode = "i"; key = "<C-h>"; action = "<Left>"; }
        { mode = "i"; key = "<C-l>"; action = "<Right>"; }
        { mode = "n"; key = "<leader><Tab>"; action = ":bn<CR>"; }
        { mode = "n"; key = "<leader><S-Tab>"; action = ":bp<CR>"; }
        { mode = "n"; key = "<leader>d"; action = ":bd<CR>"; }
        { mode = "n"; key = "<leader>w"; action = ":w<CR>"; }
        { mode = "n"; key = "<leader>q"; action = ":qa<CR>"; }
        { mode = [ "n" "v" ]; key = "<leader>y"; action = "\"+y"; }
        { mode = [ "n" "v" ]; key = "<leader>p"; action = "\"+p"; }
      ];

      # indent-blankline
      visuals.indent-blankline.enable = true;

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
      lazy.plugins.multicursors-nvim.keys = lib.mkForce [
        { mode = [ "n" "v" ]; key = "<leader>mcu"; action = ":MCunderCursor<CR>"; }
        { mode = [ "n" "v" ]; key = "<leader>mcp"; action = ":MCpattern<CR>"; }
        { mode = [ "n" "v" ]; key = "<leader>mcv"; action = ":MCvisual<CR>"; }
        { mode = [ "n" "v" ]; key = "<leader>mcb"; action = ":MCvisualPattern<CR>"; }
      ];

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
          { mode = [ "n" "x" "o" ]; key = "<leader>swa"; action = "<Plug>(sandwich-add)"; }
          { mode = [ "n" "x" ]; key = "<leader>swd"; action = "<Plug>(sandwich-delete)"; }
          { mode = [ "n" ]; key = "<leader>swdb"; action = "<Plug>(sandwich-delete-auto)"; }
          { mode = [ "n" "x" ]; key = "<leader>swr"; action = "<Plug>(sandwich-replace)"; }
          { mode = [ "n" ]; key = "<leader>swrb"; action = "<Plug>(sandwich-replace-auto)"; }
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
          cmdline = {
            completion.menu.auto_show = true;
            keymap = lib.mkForce {
              preset = "inherit";

              "<Esc>" = [
                "hide"
                # workaround for https://github.com/saghen/blink.cmp/issues/547
                (lib.generators.mkLuaInline ''
                  function()
                    if vim.fn.getcmdtype() ~= "" then
                      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-c>', true, true, true), 'n', true)
                    end
                  end
                '')
              ];
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
        # https://github.com/NotAShelf/nvf/blob/95afe7a794216f53e217c5148c6fbe0b668192cf/modules/plugins/languages/scala.nix#L137
        # vim.lsp.with is deprecated
        # scala.enable = true;
        rust.enable = true;
        typescript.enable = true;
        typst.enable = true;
        go.enable = true;
        # TODO: volar meson
      };
    };
  };
}
