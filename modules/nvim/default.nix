{ pkgs, lib, config, ... }: {
  programs.mnw = {
    enable = true;
    appName = "nvim";
    aliases = [ "vim" "v" ];
    desktopEntry = true;

    extraBinPath = with pkgs; [
      # lsp
      nixd
      lua-language-server
      rust-analyzer
      typescript-language-server
      clang-tools
      tinymist
      marksman
      yaml-language-server
      vscode-json-languageserver
      taplo

      # pickers / search
      ripgrep
      fd
    ];

    initLua = ''
      require("myconfig")
      require("lz.n").load("lazy")
    '';

    plugins = {
      dev.myconfig = {
        pure = lib.fileset.toSource {
          root = ./.;
          fileset = ./lua;
        };
        impure = "${config.home.homeDirectory}/Projects/nix/home/modules/nvim";
      };

      start = with pkgs.vimPlugins; [
        lz-n
        friendly-snippets
      ];

      opt = let
        treesitter = pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
          p.bash
          p.c
          p.comment
          p.cpp
          p.javascript
          p.json
          p.lua
          p.markdown
          p.markdown_inline
          p.nix
          p.query
          p.regex
          p.rust
          p.toml
          p.tsx
          p.typescript
          p.typst
          p.vim
          p.vimdoc
          p.yaml
        ]);
      in with pkgs.vimPlugins; [
        treesitter
        nvim-lspconfig
        blink-cmp

        neo-tree-nvim
        leap-nvim
        multicursors-nvim
        vim-sandwich
        comment-nvim
        nvim-autopairs
        auto-session

        gitsigns-nvim
        indent-blankline-nvim
        lualine-nvim
        bufferline-nvim
        which-key-nvim
      ];
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
