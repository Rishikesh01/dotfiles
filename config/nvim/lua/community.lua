-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  -- import/override with your plugins folder
  { import = "astrocommunity.markdown-and-latex.markdown-preview-nvim" },
  { import = "astrocommunity.debugging.telescope-dap-nvim" },
  { import = "astrocommunity.debugging.nvim-dap-virtual-text" },
  { import = "astrocommunity.debugging.persistent-breakpoints-nvim" },
  { import = "astrocommunity.quickfix.nvim-bqf" },
  { import = "astrocommunity.git.blame-nvim" },
  { import = "astrocommunity.colorscheme.onedarkpro-nvim" },
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.go" },
  { import = "astrocommunity.pack.ruby" },
  { import = "astrocommunity.search.nvim-spectre" },
  { import = "astrocommunity.editing-support.conform-nvim" },
  { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.recipes.vscode" },
  { import = "astrocommunity.recipes.picker-nvchad-theme" },
  { import = "astrocommunity.test.neotest" },
  { import = "astrocommunity.recipes.picker-lsp-mappings" },
}
