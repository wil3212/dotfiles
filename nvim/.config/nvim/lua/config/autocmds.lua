  -- autocmds.lua  

-- Autocomando para inserir data/hora ao criar um novo arquivo no diário
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*/diary/*.md",
  callback = function()
    local caption = os.date("# %Y-%m-%d %H:%M")
    vim.api.nvim_buf_set_lines(0, 0, 0, false, { caption, "", "" })
  end,
})

-- Atualiza os links do diário automaticamente ao entrar no índice
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "diary.md",
  command = "VimwikiDiaryGenerateLinks",
})


----------------------------------------------------------------
-- Forçar as cores sempre que o tipo de arquivo for vimwiki ou markdown

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "vimwiki", "markdown" },
  callback = function()
    local yellow = "#e3b52d"
    -- Sobrescreve o link que o plugin criou (VimwikiHeader1 -> Title)
    -- e define a cor diretamente
    vim.api.nvim_set_hl(0, 'VimwikiHeader1', { fg = yellow, bold = true })
    vim.api.nvim_set_hl(0, 'VimwikiHeader2', { fg = yellow, bold = true })
    vim.api.nvim_set_hl(0, 'VimwikiHeader3', { fg = yellow, bold = true })
    
    -- Faz o mesmo para os grupos de Markdown puro
    vim.api.nvim_set_hl(0, 'markdownH1', { fg = yellow, bold = true })
    vim.api.nvim_set_hl(0, 'markdownH2', { fg = yellow, bold = true })
  end,
})

    --  -- Força o reconhecimento de arquivos de texto puro
    --  vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    --    pattern = "*.txt",
    --    command = "set filetype=text",
    --  })

-- Adicione ao seu init.lua para ver os arquivos abertos
-- vim.opt.showtabline = 2
--
--
-- -- ~/.config/nvim/init.lua

-- Melhora o Enter no Vimwiki para abrir arquivos externos corretamente

 -- Motor Reativo e Enter para Vimwiki
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "vimwiki", "markdown" },
  callback = function(args)
    local bufnr = args.buf

    -- ==========================================
    -- 1. COMPORTAMENTO DO ENTER (Links)
    -- ==========================================
    vim.keymap.set('n', '<CR>', function()
      local line = vim.api.nvim_get_current_line()
      if line:match("%(.-%.txt%)") or line:match("%(.-%.py%)") then return "gf"
      else return "<Plug>VimwikiFollowLink" end
    end, { buffer = true, expr = true, noremap = false })

    -- ==========================================
    -- 2. CORREÇÃO VISUAL (Conceal Limpo)
    -- ==========================================
    vim.opt_local.conceallevel = 3 
    vim.opt_local.concealcursor = ""
    
    -- Agora escondemos silenciosamente os @@
    vim.schedule(function()
      -- 1. Regra para o @@@: Esconde o bloco INTEIRO (Expressão invisível)
      vim.cmd([[syntax match MathHidden /@@@.\{-}@@@/ conceal containedin=ALL]])
      -- 2. Regra para o @@: Pinta o meio, esconde as bordas.
      -- O regex /@\@<!@@@\@!/ significa: "Exatamente @@. Se tiver um terceiro @ antes ou depois, IGNORE."
      vim.cmd([[syntax region MathExpr matchgroup=EvalDelim start=/@\@<!@@@\@!/ end=/@\@<!@@@\@!/ concealends containedin=ALL]])
      vim.cmd([[hi default link MathExpr ExpressaoMath]])
    end)    

    -- Tema do Holograma
    vim.api.nvim_set_hl(0, 'ResultadoMath', { fg = '#e32d2d', italic = true, bold = true })
    -- NOVO: Tema da expressão matemática (Azul claro, mude o hex se quiser outra cor)
    vim.api.nvim_set_hl(0, 'ExpressaoMath', { fg = '#88c0d0', italic = true })

    -- ==========================================
    -- 3. MOTOR REATIVO (Top-to-Bottom)
    -- ==========================================
    local calc_ns = vim.api.nvim_create_namespace("CalculadoraVimwiki")

    local function atualizar_calculos()
      vim.api.nvim_buf_clear_namespace(bufnr, calc_ns, 0, -1)
      local env = {}
      for k, v in pairs(math) do env[k] = v end

      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      
       for i, line in ipairs(lines) do
        
        -- PASSO A: Tenta achar a sintaxe @@@ (Substituição Total Inline)
        local s3, e3, expr3 = line:find("@@@%s*(.-)%s*@@@")
        
        if s3 then
          local func = load("return " .. expr3, "calc", "t", env)
          if func then
            local status, result = pcall(func)
            if status and type(result) == "number" then
              -- virt_text_pos = "inline" injeta o holograma EXATAMENTE onde o texto sumiu
              vim.api.nvim_buf_set_extmark(bufnr, calc_ns, i - 1, s3 - 1, {
                virt_text = { { tostring(result), "ResultadoMath" } },
                virt_text_pos = "inline",
              })
            end
          end
          
        else
          -- PASSO B: Se não tem @@@, procura a sintaxe normal @@ (Variáveis ou EOL)
          local expr2 = line:match("@@%s*(.-)%s*@@")
          
          if expr2 then
            local var_name, var_expr = expr2:match("^([%a_]+)%s*=(.*)$")
            
            if var_name and var_expr then
              -- É uma declaração (ex: a = 5)
              local func = load("return " .. var_expr, "calc", "t", env)
              if func then
                local status, result = pcall(func)
                if status and type(result) == "number" then
                  env[var_name] = result 
                end
              end
            else
              -- É um cálculo EOL (ex: a + 5)
              local func = load("return " .. expr2, "calc", "t", env)
              if func then
                local status, result = pcall(func)
                if status and type(result) == "number" then
                  vim.api.nvim_buf_set_extmark(bufnr, calc_ns, i - 1, -1, {
                    virt_text = { { "  ǁ = " .. result, "ResultadoMath" } },
                    virt_text_pos = "eol",
                  })
                end
              end
            end
          end
        end
      end

    end

    -- ==========================================
    -- GATILHOS AUTOMÁTICOS
    -- ==========================================
    vim.api.nvim_create_autocmd({"TextChanged", "InsertLeave"}, {
      buffer = bufnr,
      callback = atualizar_calculos,
    })
    atualizar_calculos()
  end,
})


-- backupppp

---- Melhora o Enter no Vimwiki para abrir arquivos externos corretamente
--vim.api.nvim_create_autocmd("FileType", {
--  pattern = "vimwiki",
--  callback = function()
--    vim.keymap.set('n', '<CR>', function()
--      local line = vim.api.nvim_get_current_line()
--      -- Se a linha parecer um link de arquivo Markdown padrão [txt](path)
--      if line:match("%(.-%.txt%)") or line:match("%(.-%.py%)") then
--        return "gf"
--      else
--        -- Se não, usa o Enter padrão do Vimwiki (VimwikiFollowLink)
--        return "<Plug>VimwikiFollowLink"
--      end
--    end, { buffer = true, expr = true, noremap = false })
--  end,
--})

 -- Muda a cor da barra de status ao entrar e sair do Vimwiki
local status_group = vim.api.nvim_create_augroup("VimwikiStatus", { clear = true })

-- Ao ENTRAR em um buffer do Vimwiki, a barra fica amarela
vim.api.nvim_create_autocmd({"BufEnter", "WinEnter"}, {
  group = status_group,
  pattern = "*.md",
  callback = function()
    if vim.bo.filetype == "vimwiki" or vim.bo.filetype == "markdown" then
      -- Fundo amarelo, texto preto
      vim.api.nvim_set_hl(0, 'StatusLine', { bg = '#e3b52d', fg = '#000000', bold = true })
    end
  end,
})

-- Ao SAIR do Vimwiki (indo para outro arquivo ou Oil), volta ao normal
vim.api.nvim_create_autocmd({"BufLeave", "WinLeave"}, {
  group = status_group,
  pattern = "*",
  callback = function()
    -- Fundo escuro, texto claro (padrão do terminal)
    vim.api.nvim_set_hl(0, 'StatusLine', { bg = '#333333', fg = '#ffffff', bold = false })
  end,
})
