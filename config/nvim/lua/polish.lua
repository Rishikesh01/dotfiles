vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go" },
  callback = vim.schedule_wrap(
    function(args) vim.keymap.set("n", "<Leader>lt", "<cmd>GoTestFunc<CR>", { buffer = true, desc = "run single test" }) end
  ),
  group = vim.api.nvim_create_augroup("Language tools", { clear = true }),
})

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

-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here
