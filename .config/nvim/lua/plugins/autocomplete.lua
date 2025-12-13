return {
  { -- Autocompletion
    "saghen/blink.cmp",
    event = "VimEnter",
    version = "1.*",
    dependencies = {
      -- Snippet Engine
      {
        "L3MON4D3/LuaSnip",
        version = "2.*",
        build = (function()
          return "make install_jsregexp"
        end)(),
        dependencies = {},
        opts = {},
      },
      "folke/lazydev.nvim",
      -- GitHub Copilot (official plugin with auth support)
      {
        "github/copilot.vim",
        cmd = "Copilot",
        event = "InsertEnter",
      },
      -- Copilot source for blink.cmp (keeps Copilot ghost text + adds menu items)
      {
        "fang2hou/blink-copilot",
      },
      -- color-menu
      {
        "xzbdmw/colorful-menu.nvim",
        opts = { highlighters = { 'treesitter' } },
      },
    },
    --- @module "blink.cmp"
    --- @type blink.cmp.Config
    opts = {
      keymap = {
        -- See :h blink-cmp-config-keymap for defining your own keymap
        preset = "none",


        ["<C-space>"] = { "show", "show_documentation", "hide_documentation", "fallback" },
        ["<C-e>"] = { "cancel", "hide", "fallback" },

        ["<CR>"] = { "accept", "fallback" },

        ["<Right>"] = { "select_and_accept", "fallback" },
        ["<C-l>"] = { "select_and_accept", "fallback" },

        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },

        ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
        ["<C-n>"] = { "select_next", "fallback_to_mappings" },

        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },

        ["<C-k>"] = { "show_signature", "hide_signature", "fallback" },
      },

      appearance = {
        -- "mono" (default) for "Nerd Font Mono" or "normal" for "Nerd Font"
        -- Adjusts spacing to ensure icons are aligned
        nerd_font_variant = "normal",
      },

      completion = {
        keyword = { range = 'full' },

        -- By default, you may press `<c-space>` to show the documentation.
        -- Optionally, set `auto_show = true` to show the documentation after a delay.
        documentation = { auto_show = true, auto_show_delay_ms = 500 },

        menu = {
          auto_show = true,
          draw = {
            -- We don't need label_description now because label and label_description are already
            -- combined together in label by colorful-menu.nvim.
            columns = {
              { "label",      gap = 1 },
              { "kind_icon",  "kind" },
              { "source_name" },
            },
            components = {
              label = {
                text = function(ctx)
                  return require("colorful-menu").blink_components_text(ctx)
                end,
                highlight = function(ctx)
                  return require("colorful-menu").blink_components_highlight(ctx)
                end,
              },
            },
            treesitter = { 'lsp' },
          },
        },
        ghost_text = {
          enabled = true,
          show_without_selection = true,
        },

        list = {
          selection = {
            preselect = false,
            auto_insert = true
          },
        },
      },

      sources = {
        default = { "lsp", "path", "snippets", "lazydev", "copilot" },
        providers = {
          lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
          copilot = {
            name = "copilot",
            module = "blink-copilot",
            async = true,
            score_offset = 50,
          },
        },
      },

      snippets = { preset = "luasnip" },

      -- Blink.cmp includes an optional, recommended rust fuzzy matcher,
      -- which automatically downloads a prebuilt binary when enabled.
      --
      -- By default, we use the Lua implementation instead, but you may enable
      -- the rust implementation via `"prefer_rust_with_warning"`
      --
      -- See :h blink-cmp-config-fuzzy for more information
      fuzzy = { implementation = "prefer_rust_with_warning" },

      -- Shows a signature help window while you type arguments for a function
      signature = { enabled = true },

      -- Configurations for the cmdline only
      cmdline = {
        keymap = { preset = 'inherit' },
        fuzzy = { implementation = "prefer_rust_with_warning" },
        completion = {
          menu = {
            auto_show = true
          },
          list = {
            selection = {
              preselect = false,
            },
          },
        },
      },
    },
    configuration = function()
    end
  },
  {
    "L3MON4D3/LuaSnip",
    -- follow latest release.
    version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    -- install jsregexp (optional!).
    build = "make install_jsregexp"
  }
}
