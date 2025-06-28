vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go" },
  callback = vim.schedule_wrap(function(args)
    vim.keymap.set(
      "n",
      "<Leader>dt",
      function() require("dap-go").debug_test() end,
      { buffer = true, desc = "Debug single test" }
    )
  end),
  group = vim.api.nvim_create_augroup("debugger", { clear = true }),
})

vim.opt.guifont = { "FiraCode Nerd Font", "Noto Color Emoji", ":h18" }

if vim.g.neovide then
  if vim.g.neovide then
    vim.keymap.set(
      "n",
      "<leader>nn",
      function() vim.fn.jobstart({ "neovide" }, { detach = true }) end,
      { desc = "Open new blank Neovide window" }
    )
  end

  -- Insert Mode: Paste system clipboard with Ctrl+V
  vim.api.nvim_create_autocmd("InsertEnter", {
    pattern = "*",
    callback = function() vim.keymap.set("i", "<C-v>", "<C-r>+", { buffer = true, noremap = true, silent = true }) end,
  })

  -- Terminal Mode: Paste system clipboard with Ctrl+V (simulates typing)
  vim.api.nvim_create_autocmd("TermOpen", {
    pattern = "*",
    callback = function()
      vim.keymap.set("t", "<C-v>", function()
        local clipboard = vim.fn.getreg "+"
        vim.api.nvim_feedkeys(clipboard, "t", false)
      end, { buffer = true })
    end,
  })

  vim.api.nvim_create_autocmd("CmdlineEnter", {
    pattern = "*",
    callback = function() vim.cmd "cnoremap <C-v> <C-r>+" end,
  })

  -- Command-line mode: Ctrl + p to paste clipboard content
  -- vim.keymap.set("c", "<C-v>", function()
  --   local clip = vim.fn.getreg "+"
  --   vim.api.nvim_feedkeys(clip, "i", false)
  -- end, { desc = "Paste from clipboard in command-line mode" })
end
