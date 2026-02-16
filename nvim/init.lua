-- netrw を完全に無効化（neo-tree で置き換えるため）
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.
local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end
 
-- システムクリップボードとの連携を有効にする
vim.opt.clipboard:append("unnamedplus")

vim.keymap.set('n', '<C-c>', '"+y')
vim.keymap.set('v', '<C-c>', '"+y')

vim.keymap.set('n', '<C-a>', 'ggVG')
vim.keymap.set('v', '<C-a>', 'ggVG')

require "lazy_setup"
require "polish"

-- 自動保存: フォーカスを失ったとき・バッファを離れたとき・編集後に自動で保存
vim.opt.autowriteall = true
vim.api.nvim_create_autocmd({ "FocusLost", "BufLeave", "InsertLeave", "TextChanged" }, {
  pattern = "*",
  callback = function()
    if vim.bo.modified and vim.bo.buftype == "" and vim.fn.expand("%") ~= "" then
      vim.cmd("silent! write")
    end
  end,
})

-- nvim . でディレクトリを開いた場合、neo-tree だけ表示して untitled を出さない
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function(data)
    if vim.fn.isdirectory(data.file) == 1 then
      vim.cmd.cd(data.file)
      vim.schedule(function()
        -- neo-tree をサイドバーで開く
        require("neo-tree.command").execute({ source = "filesystem", position = "left" })
        -- untitled / ディレクトリの空ウィンドウを閉じる
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          local name = vim.api.nvim_buf_get_name(buf)
          local ft = vim.bo[buf].filetype
          if ft ~= "neo-tree" and (name == "" or vim.fn.isdirectory(name) == 1) then
            if #vim.api.nvim_list_wins() > 1 then
              pcall(vim.api.nvim_win_close, win, true)
            end
          end
        end
      end)
    end
  end,
})

