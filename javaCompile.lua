local M = {}

function M.run_java()
  local bufname = vim.fn.expand '%:t' -- Get current file name
  local filepath = vim.fn.expand '%:p:h' -- Get file directory
  local classname = vim.fn.expand '%:t:r' -- Get class name without extension

  if bufname:sub(-5) ~= '.java' then
    print 'Not a Java file!'
    return
  end

  local cmd_compile = string.format('javac "%s/%s"', filepath, bufname)
  local cmd_run = string.format('java -cp "%s" %s', filepath, classname)

  -- Compile the Java file
  local compile_result = vim.fn.system(cmd_compile)
  if vim.v.shell_error ~= 0 then
    print('Compilation failed:\n' .. compile_result)
    return
  end

  -- Open a floating terminal
  local buf = vim.api.nvim_create_buf(false, true)
  local width = vim.o.columns
  local height = vim.o.lines
  local win_opts = {
    relative = 'editor',
    width = math.floor(width * 1),
    height = math.floor(height * 0.3),
    row = math.floor(height * 0.65), -- Position at the bottom
    col = math.floor(width * 0.1),
    style = 'minimal',
    border = 'solid',
  }

  local win = vim.api.nvim_open_win(buf, true, win_opts)

  -- Start the Java program in an interactive terminal buffer
  vim.fn.termopen(cmd_run)

  -- Allow user to manually close the floating terminal with <Esc>
  vim.api.nvim_buf_set_keymap(buf, 'n', '<Esc>', '<cmd>lua vim.api.nvim_win_close(' .. win .. ', true)<CR>', { noremap = true, silent = true })
end

-- Map <F9> to run Java files
vim.api.nvim_set_keymap('n', '<F9>', '<cmd>lua require("Kickstart.javaCompile").run_java()<CR>', { noremap = true, silent = true })

return M
