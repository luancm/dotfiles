-- Machine declaration read by AI plugin conds: profile=work|personal from
-- $XDG_CONFIG_HOME/dotfiles/machine.conf (semantics in lib/machine_profile.sh).
-- ai_backend derives from the profile; an explicit ai_backend= line overrides.
local M = {}

local function conf_path()
  local base = vim.env.XDG_CONFIG_HOME
  if base == nil or base == '' then
    base = vim.fs.normalize('~/.config')
  end
  return base .. '/dotfiles/machine.conf'
end

local function warn(msg)
  vim.schedule(function()
    vim.notify('machine.conf: ' .. msg, vim.log.levels.WARN)
  end)
end

local conf = {}
do
  local file = io.open(conf_path(), 'r')
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

-- 'unknown' is what ./install writes when it cannot ask; other values are typos.
local profiles = { work = true, personal = true }
if conf.profile and not profiles[conf.profile] and conf.profile ~= 'unknown' then
  warn(('profile=%s is not work or personal; AI plugins are off'):format(conf.profile))
end
M.profile = profiles[conf.profile] and conf.profile or 'unknown'

local derived = { personal = 'opencode', work = 'copilot' }
local known = { opencode = true, copilot = true, none = true }
if conf.ai_backend and not known[conf.ai_backend] then
  warn(('ai_backend=%s is not opencode, copilot or none; ignored'):format(conf.ai_backend))
end
M.ai_backend = (conf.ai_backend and known[conf.ai_backend] and conf.ai_backend)
  or derived[M.profile]
  or 'none'

return M
