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
