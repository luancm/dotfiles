-- AI inline completion (ghost text) via the opencode go subscription.
-- Frontend: minuet's virtualtext (README-recommended over LSP inline_completion).
-- Manual invoke: <A-]> (next / invoke when nothing shown); accept via the keymaps below.
return {
  {
    'milanglacier/minuet-ai.nvim',
    event = 'InsertEnter',
    -- opencode-profile machines only (config/profile.lua)
    cond = function()
      return require('config.profile').ai_backend == 'opencode'
    end,
    config = function()
      -- opencode go requires a stable session id sent as x-opencode-session.
      -- Persist one per machine so every request shares the same "conversation".
      local function opencode_session_id()
        local file = vim.fn.stdpath('data') .. '/opencode-session-id'
        local f = io.open(file, 'r')
        if f then
          local id = f:read('*l')
          f:close()
          if id and id ~= '' then
            return id
          end
        end
        local f = io.open('/proc/sys/kernel/random/uuid', 'r')
        local id
        if f then
          id = f:read('*l')
          f:close()
        elseif vim.uuid then
          id = vim.uuid()
        else
          math.randomseed(vim.uv.hrtime() % 0x7fffffff)
          local parts = {}
          for _ = 1, 4 do
            parts[#parts + 1] = string.format('%08x', math.random(0, 0x7fffffff))
          end
          id = table.concat(parts, '-')
        end
        local w = io.open(file, 'w')
        if w then
          w:write(id)
          w:close()
        end
        return id
      end
      local session_id = opencode_session_id()

      require('minuet').setup({
        -- Chat-based completion over the opencode go OpenAI-compatible endpoint.
        -- GLM-5.3-Flash is a chat model (no FIM endpoint on go), hence openai_compatible.
        provider = 'openai_compatible',
        request_timeout = 2.5,
        throttle = 1000,
        debounce = 400,
        provider_options = {
          openai_compatible = {
            api_key = 'OPENCODE_GO_API_KEY',
            end_point = 'https://opencode.ai/zen/go/v1/chat/completions',
            model = 'glm-5.3-flash',
            name = 'Opencode',
            optional = {
              max_tokens = 256,
              top_p = 0.9,
              -- glm on go emits reasoning_content that eats max_tokens; without
              -- this, budget is exhausted before any visible text (finish=length)
              reasoning_effort = 'none',
            },
            transform = {
              function(data)
                data.headers['x-opencode-session'] = session_id
                return data
              end,
            },
          },
        },
        virtualtext = {
          auto_trigger_ft = {
            'zig', 'lua', 'go', 'rust', 'python',
            'typescript', 'typescriptreact', 'javascript', 'javascriptreact',
            'sh', 'bash',
          },
          keymap = {
            -- SSH-safe: plain C-chords (Alt/Cmd don't survive ssh from macOS).
            -- Chosen to dodge blink.cmp keymaps (autocomplete.lua ones win while
            -- its menu is open; minuet's fire when its ghost text is visible).
            -- Builtin insert-mode bindings sacrificed: C-y (copy from line
            -- above), C-j (newline via ctrl), C-g, C-\ (rarely used).
            -- accept whole completion (Alt-Shift-A is unreachable over ssh)
            accept = '<C-y>',
            -- accept one line, then keep the rest as ghost text
            accept_line = '<C-j>',
            -- accept n lines (prompts for number)
            accept_n_lines = '<C-g>',
            -- cycle/manual invoke; blink menu takes priority via fallback_to_mappings
            prev = '<C-p>',
            next = '<C-n>',
            dismiss = '<C-\\>',
          },
        },
      })
    end,
  },
}
