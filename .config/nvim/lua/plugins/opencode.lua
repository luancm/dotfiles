-- Targeted AI actions via the running opencode server (tmux flow friendly):
-- selection/cursor context injection, prompt history, and :diffpatch review
-- (da accept / dr reject / dp+do per-hunk) when opencode edits files.
-- Finds an already-running `opencode` daemon automatically; otherwise starts one.
return {
  'nickjvandyke/opencode.nvim',
  version = '*',
  keys = {
    { '<leader>oa', function() require('opencode').ask('@this: ') end, mode = { 'n', 'x' }, desc = '[O]pencode [A]sk' },
    { '<leader>os', function() require('opencode').select() end, mode = { 'n', 'x' }, desc = '[O]pencode [S]elect' },
    { '<leader>oe', function() require('opencode').prompt('Explain @this') end, mode = { 'n', 'x' }, desc = '[O]pencode [E]xplain' },
    { '<leader>of', function() require('opencode').prompt('Fix @diagnostics') end, desc = '[O]pencode [F]ix diagnostics' },
    { 'go', function() return require('opencode').operator('@this') end, expr = true, desc = 'Send range to [O]pencode' },
    { 'goo', function() return require('opencode').operator('@this') .. '_' end, expr = true, desc = 'Send line to [O]pencode' },
  },
  config = function()
    vim.g.opencode_opts = {}
  end,
}
