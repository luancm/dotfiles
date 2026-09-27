-- GitHub Copilot inline suggestions — the work-profile counterpart to
-- minuet (gated via config/profile.lua).
return {
  {
    'github/copilot.vim',
    event = 'InsertEnter',
    cond = function()
      return require('config.profile').ai_backend == 'copilot'
    end,
  },
}
