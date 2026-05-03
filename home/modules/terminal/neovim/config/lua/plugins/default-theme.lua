-- Default theme loader
-- On startup, reads ~/.config/kernix/current-theme and loads the
-- corresponding neovim.lua from the themes directory via dofile().
-- Falls back to ayu-mirage if no theme is set.
-- Runtime theme switching is handled by kernix-theme-apply-neovim
-- via neovim's RPC (--server), so no file watcher is needed.

local function load_kernix_theme()
  -- Read current theme name
  local theme_file = vim.fn.expand('~/.config/kernix/current-theme')
  local f = io.open(theme_file, 'r')
  if not f then return false end
  local theme_name = f:read('*l')
  f:close()
  if not theme_name or theme_name == '' then return false end
  theme_name = theme_name:gsub('%s+', '')

  -- Find the theme's neovim.lua in the themes directory
  local themes_dir = vim.fn.expand('~/.local/share/kernix/themes')
  local nvim_lua = themes_dir .. '/' .. theme_name .. '/neovim.lua'

  if vim.fn.filereadable(nvim_lua) ~= 1 then return false end

  -- Load and execute the theme spec
  local ok, spec = pcall(dofile, nvim_lua)
  if ok and spec and type(spec) == 'table' then
    for _, s in ipairs(spec) do
      if type(s) == 'table' and s.config then
        local cok = pcall(s.config, nil, s.opts or {})
        return cok
      end
    end
  end
  return false
end

return {
  -- Fallback colorscheme (loaded by lazy.nvim if kernix theme fails)
  {
    'Shatur/neovim-ayu',
    priority = 1000,
    lazy = false,
    config = function()
      require('ayu').setup { mirage = true }
      -- Try kernix theme first, fall back to ayu-mirage
      if not load_kernix_theme() then
        vim.cmd.colorscheme('ayu-mirage')
      end
    end,
  },
}
