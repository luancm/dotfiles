vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.undofile = true

-- vim.opt.clipboard = "unnamedplus"
vim.opt.smartindent = true

vim.g.mapleader = " "

-- to be used in plugins or custom configs
vim.g.have_nerd_font = true

vim.g.loaded_snippet = 1

-- npm-global CLIs (opencode, ...) live under nvm's node bin, which is only
-- added to PATH when nvm lazy-loads in zsh. nvim spawns binaries directly
-- with its inherited PATH, so make the newest nvm-managed bin dir findable.
if vim.fn.executable("opencode") == 0 then
  local matches = vim.fn.glob(vim.fs.normalize("~/.nvm/versions/node/*/bin/opencode"), true, true)
  table.sort(matches, function(a, b)
    local function ver(p)
      local ok, v = pcall(vim.version.parse, p:match("node/(.-)/bin/"))
      return ok and v or vim.version.parse("0")
    end
    return ver(a) < ver(b)
  end)
  local best = matches[#matches]
  if best then
    vim.env.PATH = vim.fs.dirname(best) .. ":" .. vim.env.PATH
  end
end

-- Keymaps
-- C-h/j/k/l are owned by vim-tmux-navigator (see plugins/vim-tmux-navigator.lua).
-- Half-page scroll stays on the native C-d / C-u (with zz recenter).
vim.keymap.set({ "n", "v" }, "<C-d>", "<C-d>zz", { desc = "Half page down" })
vim.keymap.set({ "n", "v" }, "<C-u>", "<C-u>zz", { desc = "Half page up" })

vim.keymap.set("n", "<leader><space>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlights" })

-- From theprimeagen
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set("n", "<leader>fr", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "[F]ind and [Replace]" })

-- Diagnostics
vim.diagnostic.config({
	virtual_text = true,
	severity_sort = true,
	float = { border = "rounded", source = true },
})

vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Previous [D]iagnostic" })
vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Next [D]iagnostic" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror" })
