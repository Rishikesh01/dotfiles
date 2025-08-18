-- You can also add or configure plugins by creating files in this `plugins/` folder
-- PLEASE REMOVE THE EXAMPLES YOU HAVE NO INTEREST IN BEFORE ENABLING THIS FILE
-- Here are some examples:

---@type LazySpec
return {

  -- install without yarn or npm

  {
    "nvim-neotest/neotest",
    dependencies = {
      "rouge8/neotest-rust",
    },
    opts = function(_, opts)
      opts.adapters = vim.list_extend(opts.adapters or {}, {
        require "neotest-rust" {
          args = { "--no-capture", "--cargo-quiet" },
        },
      })
    end,
  },

  {
    "Rishikesh01/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },

  -- install with yarn or npm
  {
    "Rishikesh01/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "yarn install && yarn build",
    init = function() vim.g.mkdp_filetypes = { "markdown" } end,
    ft = { "markdown" },
  },

  -- {
  --   "sphamba/smear-cursor.nvim",
  --   opts = {
  --     legacy_computing_symbols_support = true,
  --     smear_between_buffers = true,
  --     scroll_buffer_space = true,
  --     smear_between_neighbor_lines = true,
  --     stiffness = 0.8, -- 0.6      [0, 1]
  --     trailing_stiffness = 0.5, -- 0.4      [0, 1]
  --     stiffness_insert_mode = 0.7, -- 0.5      [0, 1]
  --     trailing_stiffness_insert_mode = 0.7, -- 0.5      [0, 1]
  --     damping = 0.8, -- 0.65     [0, 1]
  --     damping_insert_mode = 0.8, -- 0.7      [0, 1]
  --     distance_stop_animating = 0.5,
  --   },
  --   enabled = not vim.g.neovide,
  -- },
  -- {
  --   "folke/snacks.nvim",
  --   opts = function(_, opts)
  --     opts.picker = {
  --       preview = "main",
  --       layout = {
  --         box = "vertical",
  --         backdrop = false,
  --         width = 0,
  --         height = 0.4,
  --         position = "bottom",
  --         border = "top",
  --         title = " {title} {live} {flags}",
  --         title_pos = "left",
  --         { win = "input", height = 1, border = "bottom" },
  --         {
  --           box = "horizontal",
  --           { win = "list", border = "none" },
  --           { win = "preview", title = "{preview}", width = 0.6, border = "left" },
  --         },
  --       },
  --     }
  --   end,
  -- },

  -- {
  --   "folke/snacks.nvim",
  --   optional = true,
  --   specs = {
  --     {
  --       "AstroNvim/astroui",
  --       ---@param opts AstroUIOpts
  --       opts = function(_, opts)
  --         if not opts.highlights then opts.highlights = {} end
  --         local original_init = opts.highlights.init
  --         local init_function
  --         if type(original_init) == "table" then
  --           init_function = function() return original_init end
  --         else
  --           init_function = original_init
  --         end
  --         opts.highlights.init = require("astrocore").patch_func(init_function, function(orig, colors_name)
  --           local highlights = orig(colors_name) or {}
  --
  --           local get_hlgroup = require("astroui").get_hlgroup
  --           -- get highlights from highlight groups
  --           local bg = get_hlgroup("Normal").bg
  --           local bg_alt = get_hlgroup("Visual").bg
  --           local green = get_hlgroup("String").fg
  --           local red = get_hlgroup("Error").fg
  --           -- return a table of highlights for telescope based on
  --           -- colors gotten from highlight groups
  --           highlights.SnacksPickerBorder = { fg
  --           = bg_alt, bg = bg }
  --           highlights.SnacksPicker = { bg = bg }
  --           highlights.SnacksPickerPreviewBorder = { fg = bg, bg = bg }
  --           highlights.SnacksPickerPreview = { bg = bg }
  --           highlights.SnacksPickerPreviewTitle = { fg = bg, bg = green }
  --           highlights.SnacksPickerBoxBorder = { fg = bg, bg = bg }
  --           highlights.SnacksPickerInputBorder = { fg = bg, bg = bg }
  --           highlights.SnacksPickerInputSearch = { fg = red, bg = bg }
  --           highlights.SnacksPickerListBorder = { fg = bg, bg = bg }
  --           highlights.SnacksPickerList = { bg = bg }
  --           highlights.SnacksPickerListTitle = { fg = bg, bg = bg }
  --           return highlights
  --         end)
  --       end,
  --     },
  --   },
  -- },
  -- == Examples of Adding Plugins ==

  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      if not opts.formatters_by_ft then opts.formatters_by_ft = {} end
      opts.log_level = vim.log.levels.DEBUG
      opts.formatters_by_ft.go = { "gofmt", "goimports" }
    end,
  },

  "andweeb/presence.nvim",
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function() require("lsp_signature").setup() end,
  },

  -- == Examples of Overriding Plugins ==

  -- customize dashboard options
  {
    "folke/snacks.nvim",
    opts = {
      dashboard = {
        preset = {
          header = table.concat({
            " █████  ███████ ████████ ██████   ██████ ",
            "██   ██ ██         ██    ██   ██ ██    ██",
            "███████ ███████    ██    ██████  ██    ██",
            "██   ██      ██    ██    ██   ██ ██    ██",
            "██   ██ ███████    ██    ██   ██  ██████ ",
            "",
            "███    ██ ██    ██ ██ ███    ███",
            "████   ██ ██    ██ ██ ████  ████",
            "██ ██  ██ ██    ██ ██ ██ ████ ██",
            "██  ██ ██  ██  ██  ██ ██  ██  ██",
            "██   ████   ████   ██ ██      ██",
          }, "\n"),
        },
      },
    },
  },

  {
    "nvim-neotest/neotest",
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      table.insert(
        opts.adapters,
        require "neotest-golang" {
          go_test_args = { "-count=1", "-parallel=1", "-v" },
        }
      )
    end,
  },
  -- You can disable default plugins as follows:
  --{ "max397574/better-escape.nvim", enabled = false },

  -- You can also easily customize additional setup of plugins that is outside of the plugin's setup call
  {
    "L3MON4D3/LuaSnip",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.luasnip"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom luasnip configuration such as filetype extend or custom snippets
      local luasnip = require "luasnip"
      luasnip.filetype_extend("javascript", { "javascriptreact" })
    end,
  },

  {
    "windwp/nvim-autopairs",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom autopairs configuration such as custom rules
      local npairs = require "nvim-autopairs"
      local Rule = require "nvim-autopairs.rule"
      local cond = require "nvim-autopairs.conds"
      npairs.add_rules(
        {
          Rule("$", "$", { "tex", "latex" })
            -- don't add a pair if the next character is %
            :with_pair(cond.not_after_regex "%%")
            -- don't add a pair if  the previous character is xxx
            :with_pair(
              cond.not_before_regex("xxx", 3)
            )
            -- don't move right when repeat character
            :with_move(cond.none())
            -- don't delete if the next character is xx
            :with_del(cond.not_after_regex "xx")
            -- disable adding a newline when you press <cr>
            :with_cr(cond.none()),
        },
        -- disable for .vim files, but it work for another filetypes
        Rule("a", "a", "-vim")
      )
    end,
  },
}
