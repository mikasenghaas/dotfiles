-- cmp.rc.lua
--  configs for nvim-cmp
-- by: Mika Senghaas

local status, cmp = pcall(require, "cmp")
if (not status) then return end

local luasnip = require('luasnip')
local lspkind = require('lspkind')

-- helper
local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

-- toggle cmd
vim.cmd("command CmpStart lua require('cmp').setup.buffer { enabled = true }")
vim.cmd("command CmpStop lua require('cmp').setup.buffer { enabled = false }")

cmp.setup {
  sources = cmp.config.sources({
    { name = 'luasnip', priority = 5 },
    { name = 'nvim_lsp', priority = 4 },
    { name = 'path', priority = 3 },
    { name = 'buffer', priority = 2 },
    { name = 'emoji', priority = 1 },
  }),
  mapping = cmp.mapping.preset.insert({
    ['<C-c>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true
    }),
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable() 
      -- they way you will only jump inside the snippet region
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  experimental = {
    ghost_text = true,
  },
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol', -- show only symbol annotations
      maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
      ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
    })
  }
}

cmp.setup.cmdline(':', {
  sources = {
    { name = 'cmdline' }
  }
})

