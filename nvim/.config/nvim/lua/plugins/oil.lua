--   return {
--    "stevearc/oil.nvim",
--    opts = {},
--    dependencies = { "nvim-tree/nvim-web-devicons" }, -- Opcional, para ícones
--    config = function()
--      require("oil").setup()
--      -- Atalho: Traço (-) abre a pasta atual
--      vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Abrir pasta pai" })
--    end,
--  }
return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  opts = {
    keymaps = {
      ["<BS>"] = "actions.parent", -- Backspace sobe um diretório
      ["-"]    = "actions.parent", -- O traço TAMBÉM sobe (resolve o conflito interno)
      ["<CR>"] = "actions.select", -- Enter entra no diretório/arquivo
      ["q"]    = "actions.close",  -- 'q' fecha o explorador
    },
    use_default_keymaps = false,
  },
  config = function(_, opts)
    require("oil").setup(opts)

    -- Atalho global: Abre o Oil SEMPRE na pasta do arquivo atual
    vim.keymap.set("n", "-", function()
      -- Pega o caminho absoluto da pasta do buffer atual
      local current_dir = vim.fn.expand("%:p:h")
      require("oil").open(current_dir)
    end, { desc = "Abrir Oil no diretório do buffer atual" })
  end,
}
