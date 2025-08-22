-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    -- change colorscheme
    colorscheme = "astrodark",
    -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
    highlights = {
      init = { -- this table overrides highlights in all themes
        -- Normal = { bg = "#000000" },
        -- ["@variable.go"] = { fg = "#FFAE42" },
        --
        -- ["@variable.go"] = { fg = "#5E99B8" },
        -- ["@variable.go"] = { fg = "#57C7A0" },
        -- ["@property.go"] = { fg = "#D0679D", italic = true },
        --["@property.go"] = { fg = "#7dcfff", italic = true },
        ["@variable"] = { fg = "#EBCB8B" }, -- Electric blue for strong visibility
        ["@property"] = { fg = "#E05179", italic = true },
        ["@function.call"] = { fg = "#7dcfff" },
        ["@lsp.type.function.rust"] = { fg = "#7dcfff" },
      },
      astrodark = { -- a table of overrides/changes when applying the astrotheme theme
        -- Normal = { bg = "#000000" },
      },
    },
    -- Icons can be configured throughout the interface
    icons = {
      -- configure the loading of the lsp in the status line
      LSPLoading1 = "⠋",
      LSPLoading2 = "⠙",
      LSPLoading3 = "⠹",
      LSPLoading4 = "⠸",
      LSPLoading5 = "⠼",
      LSPLoading6 = "⠴",
      LSPLoading7 = "⠦",
      LSPLoading8 = "⠧",
      LSPLoading9 = "⠇",
      LSPLoading10 = "⠏",
    },
  },
}
