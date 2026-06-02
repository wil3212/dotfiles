  return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local builtin = require('telescope.builtin')

    -- 1. The Global Search (Searches where you opened Neovim)
    vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find Files (Root)" })
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Live Grep (Root)" })

    -- 2. The Oil/Local Fix (Searches ONLY in the folder of the file you are currently editing)
    vim.keymap.set('n', '<leader>fd', function()
      builtin.find_files({ cwd = vim.fn.expand('%:p:h') })
    end, { desc = "Find Files (Current Directory)" })

    -- 3. The Vimwiki Silver Bullet (ALWAYS searches your wiki, no matter where Neovim is)
    vim.keymap.set('n', '<leader>fw', function()
      builtin.find_files({ cwd = "~/vimwiki" })
    end, { desc = "Find in Vimwiki" })
    
    vim.keymap.set('n', '<leader>gw', function()
      builtin.live_grep({ cwd = "~/vimwiki" })
    end, { desc = "Grep in Vimwiki" })
  end
}
