-- Shared DAP utilities

local M = {}

--- Find an executable on $PATH, returning its full path or nil.
function M.which(bin)
  local p = vim.fn.exepath(bin)
  return (p ~= '' and p) or nil
end

return M
