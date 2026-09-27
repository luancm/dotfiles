-- Machine declaration read by AI plugin conds: profile=work|personal from
-- ~/.config/dotfiles/machine.conf (semantics in lib/machine_profile.sh).
-- ai_backend derives from the profile; an explicit ai_backend= line overrides.
local M = {}

local conf = {}
do
  local file = io.open(vim.fs.normalize('~/.config/dotfiles/machine.conf'), 'r')
  if file then
    for line in file:lines() do
      local key, value = line:match('^%s*([%w_]+)%s*=%s*(.-)%s*$')
      if key then
        conf[key] = value
      end
    end
    file:close()
  end
end

M.profile = conf.profile or 'unknown'

local derived = { personal = 'opencode', work = 'copilot' }
local known = { opencode = true, copilot = true, none = true }
M.ai_backend = (conf.ai_backend and known[conf.ai_backend] and conf.ai_backend)
  or derived[M.profile]
  or 'none'

return M
