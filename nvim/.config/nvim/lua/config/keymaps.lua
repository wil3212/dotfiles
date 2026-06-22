  -- keymaps.lua

-- Atalho para inserir o timestamp manualmente a qualquer momento (Ctrl + t)
vim.keymap.set('n', '<C-t>', 'i<C-R>=strftime("%H:%M ")<CR><Esc>', { desc = 'Insere Horário' })


-- Toggle do "Zen Scroll" (Centralizar cursor na tela)
vim.keymap.set("n", "<leader>z", function()
  -- Lê o valor atual do scrolloff
  local current_scrolloff = vim.opt.scrolloff:get()
  
  if current_scrolloff == 999 then
    -- Se estiver ligado, desliga (0 deixa o cursor tocar as bordas, 8 deixa uma margem)
    vim.opt.scrolloff = 2 
    print("Zen Scroll: OFF")
  else
    -- Se estiver desligado, trava o cursor no meio da tela
    vim.opt.scrolloff = 999
    
    -- Opcional: Centraliza a tela imediatamente ao ligar
    vim.cmd("normal! zz") 
    print("Zen Scroll: ON (Centralizado)")
  end
end, { desc = "Toggle Scrolloff (Center Cursor)" })
