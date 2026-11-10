-- Options

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local o = vim.opt
o.number = true
o.signcolumn = "yes"
o.cursorline = true
o.wrap = false
o.termguicolors = true
o.expandtab = true
o.tabstop = 4
o.shiftwidth = 4
o.smartindent = true
o.ignorecase = true
o.smartcase = true
o.mouse = "a"
o.clipboard = "unnamedplus"
o.updatetime = 250
o.splitbelow = true
o.splitright = true

local undodir = vim.fn.stdpath("state") .. "/undo"
vim.fn.mkdir(undodir, "p")
o.undofile = true
o.undodir = undodir

-- lazy.nvim bootstrap

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- DAP adapters
-- Top-level so keymaps can call it. Adapters only register if the
-- executable is on PATH (debugpy for Python, codelldb for C/C++/Rust).

local function setup_dap_adapters()
	local dap = require("dap")

	local python = vim.fn.exepath("python3")
	if python ~= "" then
		dap.adapters.python = {
			type = "executable",
			command = python,
			args = { "-Xfrozen_modules=off", "-m", "debugpy.adapter" },
		}
		dap.configurations.python = {
			{
				type = "python",
				request = "launch",
				name = "Launch current file",
				program = "${file}",
				console = "integratedTerminal",
			},
		}
	end

	local codelldb = vim.fn.exepath("codelldb")
	if codelldb ~= "" then
		dap.adapters.codelldb = {
			type = "server",
			port = "${port}",
			executable = { command = codelldb, args = { "--port", "${port}" } },
		}
		local configs = {
			{
				name = "Launch executable",
				type = "codelldb",
				request = "launch",
				program = function()
					return vim.fn.input("Executable path: ", vim.fn.getcwd() .. "/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
			},
			{
				name = "Attach to process",
				type = "codelldb",
				request = "attach",
				pid = require("dap.utils").pick_process,
				cwd = "${workspaceFolder}",
			},
		}
		dap.configurations.c = configs
		dap.configurations.cpp = configs
		dap.configurations.rust = configs
	end
end

-- Plugins

require("lazy").setup({
	-- Completion
	{
		"saghen/blink.cmp",
		version = "1.*",
		dependencies = { "rafamadriz/friendly-snippets" },
		opts = {
			keymap = {
				preset = "default",
				["<Tab>"] = { "select_next", "fallback" },
				["<S-Tab>"] = { "select_prev", "fallback" },
			},
			appearance = { nerd_font_variant = "mono" },
			completion = {
				documentation = { auto_show = true, auto_show_delay_ms = 200 },
				ghost_text = { enabled = true },
				menu = { border = "rounded" },
			},
			signature = { enabled = true },
			sources = { default = { "lsp", "path", "snippets", "buffer" } },
			fuzzy = { implementation = "lua" }, -- avoids Rust binary issues on NixOS
		},
	},

	-- Auto-close brackets and quotes (Alt+e wraps the next text in a pair)
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {
			check_ts = true,
			fast_wrap = {},
			disable_filetype = { "TelescopePrompt", "vim" },
		},
	},

	-- LSP (servers come from Nix)
	{
		"neovim/nvim-lspconfig",
		dependencies = { "saghen/blink.cmp" },
		config = function()
			vim.lsp.config("*", {
				capabilities = require("blink.cmp").get_lsp_capabilities(),
			})
			vim.lsp.enable({
				"lua_ls",
				"nixd",
				"pyright",
				"clangd",
				"rust_analyzer",
				"ts_ls",
				"bashls",
				"gopls",
			})
		end,
	},

	-- Formatting
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				nix = { "nixfmt" },
				python = { "ruff_format" },
				sh = { "shfmt" },
				bash = { "shfmt" },
				javascript = { "prettier" },
				javascriptreact = { "prettier" },
				typescript = { "prettier" },
				typescriptreact = { "prettier" },
				json = { "prettier" },
				jsonc = { "prettier" },
				html = { "prettier" },
				css = { "prettier" },
				markdown = { "prettier" },
				yaml = { "prettier" },
			},
			format_on_save = { timeout_ms = 2000, lsp_format = "fallback" },
		},
	},

	-- Linting (skips linters that aren't on PATH)
	{
		"mfussenegger/nvim-lint",
		config = function()
			local lint = require("lint")
			lint.linters_by_ft = {
				nix = { "statix" },
				lua = { "luacheck" },
				python = { "ruff" },
				sh = { "shellcheck" },
				bash = { "shellcheck" },
				c = { "cpplint" },
				cpp = { "cpplint" },
				javascript = { "eslint_d" },
				javascriptreact = { "eslint_d" },
				typescript = { "eslint_d" },
				typescriptreact = { "eslint_d" },
				css = { "stylelint" },
				yaml = { "yamllint" },
				markdown = { "markdownlint" },
				dockerfile = { "hadolint" },
				go = { "golangci_lint" },
			}

			local function installed(names)
				return vim.tbl_filter(function(name)
					local linter = lint.linters[name]
					local exe = linter and linter.cmd
					if type(exe) == "function" then
						exe = exe()
					end
					return exe and vim.fn.executable(exe) == 1
				end, names)
			end

			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
				group = vim.api.nvim_create_augroup("AutomaticLinting", { clear = true }),
				callback = function()
					local names = lint.linters_by_ft[vim.bo.filetype]
					if names then
						lint.try_lint(installed(names))
					end
				end,
			})
		end,
	},

	-- Treesitter (main branch API)
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main",
		lazy = false,
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").install({
				"lua",
				"nix",
				"python",
				"bash",
				"c",
				"cpp",
				"rust",
				"javascript",
				"typescript",
				"tsx",
				"json",
				"yaml",
				"toml",
				"markdown",
				"markdown_inline",
				"html",
				"css",
				"regex",
			})
			vim.api.nvim_create_autocmd("FileType", {
				callback = function()
					pcall(vim.treesitter.start)
				end,
			})
		end,
	},

	-- Navigation
	{ "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			view = { width = 30 },
			renderer = { group_empty = true },
			filters = { dotfiles = false },
		},
	},
	{
		"nvim-pack/nvim-spectre",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("spectre").setup()
		end,
	},

	-- Terminal
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		opts = {
			open_mapping = [[<C-\>]],
			direction = "float",
			start_in_insert = true,
			persist_mode = false,
			close_on_exit = true,
			shade_terminals = false,
			float_opts = {
				border = "rounded",
				width = function()
					return math.floor(vim.o.columns * 0.6)
				end,
				height = function()
					return math.floor(vim.o.lines * 0.4)
				end,
			},
			highlights = {
				Normal = { guibg = "#1f1f1f" },
				NormalFloat = { guibg = "#1f1f1f" },
				FloatBorder = { guifg = "#666666", guibg = "#1f1f1f" },
			},
		},
	},

	-- UI
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local bg, fg, gray = "#1f1f1f", "#d4d4d4", "#666666"
			local function mode_hl(color)
				return { a = { fg = bg, bg = color, gui = "bold" } }
			end
			require("lualine").setup({
				options = {
					globalstatus = true,
					component_separators = "",
					section_separators = "",
					theme = {
						normal = vim.tbl_extend("force", mode_hl("#569cd6"), {
							b = { fg = fg, bg = "#292929" },
							c = { fg = fg, bg = bg },
						}),
						insert = mode_hl("#608b4e"),
						visual = mode_hl("#c586c0"),
						replace = mode_hl("#f44747"),
						inactive = {
							a = { fg = gray, bg = bg },
							b = { fg = gray, bg = bg },
							c = { fg = gray, bg = bg },
						},
					},
				},
			})
		end,
	},
	{
		"akinsho/bufferline.nvim",
		version = "*",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = { options = { numbers = "ordinal" } },
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			spec = {
				{ "<leader>b", group = "buffer" },
				{ "<leader>c", group = "code" },
				{ "<leader>d", group = "debug" },
				{ "<leader>f", group = "find" },
				{ "<leader>g", group = "git" },
				{ "<leader>q", group = "session" },
				{ "<leader>s", group = "search" },
				{ "<leader>t", group = "terminal" },
				{ "<leader>w", group = "window" },
				{ "<leader>x", group = "diagnostics" },
			},
		},
	},
	{ "folke/trouble.nvim", opts = {} },
	{ "folke/todo-comments.nvim", dependencies = { "nvim-lua/plenary.nvim" }, opts = {} },
	{ "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
	{ "RRethy/vim-illuminate" },

	-- Notifications (replaces vim.notify)
	{
		"rcarriga/nvim-notify",
		config = function()
			local notify = require("notify")
			notify.setup({
				render = "wrapped-compact",
				stages = "fade",
				timeout = 2500,
				max_width = 60,
				fps = 60,
				background_colour = "#1f1f1f",
			})
			vim.notify = notify
		end,
	},

	-- Start screen
	{
		"goolord/alpha-nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("alpha").setup(require("alpha.themes.startify").config)
		end,
	},

	-- Editing helpers
	{ "kylechui/nvim-surround", version = "*", event = "VeryLazy", opts = {} },
	{ "numToStr/Comment.nvim", opts = {} },

	-- Debugging
	{
		"mfussenegger/nvim-dap",
		dependencies = { "rcarriga/nvim-dap-ui", "nvim-neotest/nvim-nio" },
		config = function()
			local dap, dapui = require("dap"), require("dapui")
			dapui.setup()
			dap.listeners.after.event_initialized["dapui"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui"] = function()
				dapui.close()
			end

			vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
			vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
			vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticWarn", linehl = "Visual" })

			setup_dap_adapters()
		end,
	},

	-- Git and history
	{ "lewis6991/gitsigns.nvim", opts = {} },
	{ "sindrets/diffview.nvim", dependencies = { "nvim-lua/plenary.nvim" }, opts = {} },
	{
		"mbbill/undotree",
		config = function()
			vim.g.undotree_WindowLayout = 2
			vim.g.undotree_SplitWidth = 35
			vim.g.undotree_SetFocusWhenToggle = 1
			vim.g.undotree_ShortIndicators = 1
		end,
	},

	-- Sessions
	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		opts = {
			dir = vim.fn.stdpath("state") .. "/sessions/",
			need = 1,
			branch = true,
		},
	},

	-- Discord presence (privacy-friendly: hides file and project names)
	{
		"andweeb/presence.nvim",
		event = "VeryLazy",
		opts = {
			auto_update = true,
			neovim_image_text = "Neovim",
			main_image = "neovim",
			buttons = false,
			enable_line_number = false,
			show_time = true,
			editing_text = "Editing a file",
			workspace_text = "Working on a project",
		},
	},
}, {
	lockfile = vim.fn.stdpath("state") .. "/lazy-lock.json",
})

-- Colors (re-applied after any colorscheme change)

local colors = {
	bg = "#1f1f1f",
	fg = "#d4d4d4",
	red = "#f44747",
	green = "#608b4e",
	yellow = "#dcdcaa",
	blue = "#569cd6",
	purple = "#c586c0",
	cyan = "#4ec9b0",
	gray = "#666666",
	white = "#ffffff",
}

local function apply_colors()
	local c = colors
	local function hl(group, spec)
		vim.api.nvim_set_hl(0, group, spec)
	end
	local function hl_all(groups)
		for group, spec in pairs(groups) do
			hl(group, spec)
		end
	end

	-- Editor
	hl_all({
		Normal = { fg = c.fg, bg = c.bg },
		NormalFloat = { fg = c.fg, bg = c.bg },
		CursorLine = { bg = "#292929" },
		CursorLineNr = { fg = c.blue, bold = true },
		LineNr = { fg = c.gray },
	})

	-- Syntax
	hl_all({
		Comment = { fg = c.gray, italic = true },
		Constant = { fg = c.cyan },
		String = { fg = c.green },
		Character = { fg = c.green },
		Number = { fg = c.cyan },
		Boolean = { fg = c.blue },
		Identifier = { fg = c.fg },
		Function = { fg = c.yellow },
		Statement = { fg = c.purple },
		Keyword = { fg = c.purple },
		Type = { fg = c.blue },
		Operator = { fg = c.fg },
		Delimiter = { fg = c.fg },
		Special = { fg = c.cyan },
		Error = { fg = c.red },
		Todo = { fg = c.yellow, bold = true },
	})

	-- Treesitter
	hl_all({
		["@variable"] = { fg = c.fg },
		["@function"] = { fg = c.yellow },
		["@keyword"] = { fg = c.purple },
		["@type"] = { fg = c.blue },
		["@string"] = { fg = c.green },
		["@constant"] = { fg = c.cyan },
		["@number"] = { fg = c.cyan },
		["@comment"] = { fg = c.gray, italic = true },
	})

	-- Diagnostics
	local diag = { Error = c.red, Warn = c.yellow, Info = c.blue, Hint = c.cyan }
	for name, color in pairs(diag) do
		hl("Diagnostic" .. name, { fg = color })
		hl("DiagnosticUnderline" .. name, { undercurl = true, sp = color })
	end

	-- Telescope
	hl_all({
		TelescopeNormal = { fg = c.fg, bg = c.bg },
		TelescopeBorder = { fg = c.gray, bg = c.bg },
		TelescopeSelection = { fg = c.white, bg = "#333333" },
		TelescopeMatching = { fg = c.blue, bold = true },
	})
end

vim.api.nvim_create_autocmd("ColorScheme", { callback = apply_colors })
vim.cmd("highlight clear")
vim.opt.background = "dark"
apply_colors()

-- Diagnostics

vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	underline = true,
	severity_sort = true,
	update_in_insert = false,
	float = { border = "rounded", source = "if_many" },
})

-- Autocmds

-- Tidy terminal buffers (:terminal, toggleterm, DAP)
vim.api.nvim_create_autocmd("TermOpen", {
	group = vim.api.nvim_create_augroup("TerminalSettings", { clear = true }),
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.signcolumn = "no"
	end,
})

-- Popups for things Neovim only prints to the command line.
-- Only multi-line changes (more than 'report', default 2) are announced.

-- Yanks, deletes and changes
local skip_line_delta = false
vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("RegisterNotify", { clear = true }),
	callback = function()
		local event = vim.v.event
		local verbs = { y = "yanked", d = "deleted", c = "changed" }
		local verb = verbs[event.operator]
		local count = #event.regcontents
		if verb and count > vim.o.report then
			-- text is locked inside this event, so show the popup right after it
			vim.schedule(function()
				vim.notify(count .. " lines " .. verb)
			end)
		end
		-- the delete is already announced, so don't announce its line change again
		if event.operator == "d" then
			skip_line_delta = true
		end
	end,
})

-- Undo and redo: wrappers that label the change and report hitting either end of history
local pending_action

local function history_move(key, label, at_end)
	return function()
		if not vim.bo.modifiable then
			return
		end
		local tick = vim.b.changedtick
		pending_action = label
		vim.cmd("silent! normal! " .. vim.v.count1 .. vim.keycode(key))
		if vim.b.changedtick == tick then
			pending_action = nil
			vim.notify(at_end, vim.log.levels.WARN)
		end
	end
end

-- Line count changes from undo, redo, paste and similar
local line_counts = {}

local function remember_line_count(args)
	if vim.bo[args.buf].buftype == "" then
		line_counts[args.buf] = vim.api.nvim_buf_line_count(args.buf)
	end
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost", "InsertEnter", "InsertLeave", "BufWritePost" }, {
	group = vim.api.nvim_create_augroup("LineCountBaseline", { clear = true }),
	callback = function(args)
		skip_line_delta = false
		remember_line_count(args)
	end,
})

vim.api.nvim_create_autocmd("TextChanged", {
	group = vim.api.nvim_create_augroup("LineCountNotify", { clear = true }),
	callback = function(args)
		if vim.bo[args.buf].buftype ~= "" then
			return
		end
		local now = vim.api.nvim_buf_line_count(args.buf)
		local before = line_counts[args.buf] or now
		line_counts[args.buf] = now

		local action = pending_action
		pending_action = nil
		if skip_line_delta then
			skip_line_delta = false
			return
		end

		local delta = now - before
		if math.abs(delta) <= vim.o.report then
			return
		end
		local what = delta > 0 and "added" or "removed"
		local text = string.format("%d lines %s", math.abs(delta), what)
		local message = action and (action .. ": " .. text) or text
		vim.schedule(function()
			vim.notify(message)
		end)
	end,
})

-- Keymaps

local function map(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { desc = desc })
end
local function ex(command)
	return "<cmd>" .. command .. "<cr>"
end
local function dap_call(fn)
	return function()
		require("dap")[fn]()
	end
end

-- General
map("n", "<Esc>", ex("nohlsearch"), "Clear search highlight")
map("n", "<leader>e", ex("NvimTreeToggle"), "File tree")
map("n", "<leader>u", ex("UndotreeToggle"), "Undo tree")

-- Undo and redo (with popups)
map("n", "u", history_move("u", "Undo", "Already at oldest change"), "Undo")
map("n", "<C-r>", history_move("<C-r>", "Redo", "Already at newest change"), "Redo")

-- Windows: Ctrl+h/j/k/l to move, Space w for splits
map("n", "<C-h>", "<C-w>h", "Window left")
map("n", "<C-j>", "<C-w>j", "Window down")
map("n", "<C-k>", "<C-w>k", "Window up")
map("n", "<C-l>", "<C-w>l", "Window right")
map("n", "<leader>wv", ex("vsplit"), "Split right")
map("n", "<leader>ws", ex("split"), "Split below")
map("n", "<leader>wq", ex("close"), "Close window")
map("n", "<leader>wo", ex("only"), "Only this window")
map("n", "<leader>w=", "<C-w>=", "Equalize windows")

-- Buffers (tabs): Shift+h/l to step, Tab then a number to jump
map("n", "<S-l>", ex("BufferLineCycleNext"), "Next buffer")
map("n", "<S-h>", ex("BufferLineCyclePrev"), "Previous buffer")
for i = 1, 9 do
	map("n", "<Tab>" .. i, ex("BufferLineGoToBuffer " .. i), "Go to buffer " .. i)
end
map("n", "<Tab>0", ex("BufferLineGoToBuffer -1"), "Go to last buffer")
map("n", "<leader>bn", ex("enew"), "New empty buffer")
map("n", "<leader>bd", ex("bdelete"), "Close buffer")
map("n", "<leader>bo", ex("BufferLineCloseOthers"), "Close other buffers")
map("n", "<leader>bp", ex("BufferLinePick"), "Pick buffer")
map("n", "<leader>bP", ex("BufferLineTogglePin"), "Pin buffer")

-- Find (Telescope)
map("n", "<leader>ff", ex("Telescope find_files"), "Find files")
map("n", "<leader>fg", ex("Telescope live_grep"), "Grep text")
map("n", "<leader>fw", ex("Telescope grep_string"), "Grep word under cursor")
map("n", "<leader>fb", ex("Telescope buffers"), "Open buffers")
map("n", "<leader>fr", ex("Telescope oldfiles"), "Recent files")
map("n", "<leader>fh", ex("Telescope help_tags"), "Help")

-- Search and replace
map("n", "<leader>sr", ex("Spectre"), "Search and replace")

-- Diagnostics
map("n", "<leader>xx", ex("Trouble diagnostics toggle"), "Project diagnostics")
map("n", "<leader>xX", ex("Trouble diagnostics toggle filter.buf=0"), "Buffer diagnostics")

-- Terminal (Ctrl+\ also toggles it)
map("n", "<leader>tt", ex("ToggleTerm"), "Toggle terminal")
map("t", "<Esc><Esc>", [[<C-\><C-n>]], "Terminal: normal mode")

-- Code and LSP
map("n", "gd", vim.lsp.buf.definition, "Go to definition")
map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
map("n", "gr", vim.lsp.buf.references, "References")
map("n", "K", vim.lsp.buf.hover, "Hover docs")
map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
map("n", "<leader>cr", vim.lsp.buf.rename, "Rename symbol")
map("n", "<leader>ct", vim.lsp.buf.type_definition, "Type definition")
map("n", "<leader>cs", vim.lsp.buf.document_symbol, "Document symbols")
map("n", "<leader>cd", vim.diagnostic.open_float, "Line diagnostics")
map("n", "<leader>cf", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, "Format file")

-- Debugging
map("n", "<leader>db", dap_call("toggle_breakpoint"), "Toggle breakpoint")
map("n", "<leader>dB", function()
	require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, "Conditional breakpoint")
map("n", "<leader>dc", function()
	setup_dap_adapters()
	require("dap").continue()
end, "Start / continue")
map("n", "<leader>di", dap_call("step_into"), "Step into")
map("n", "<leader>do", dap_call("step_over"), "Step over")
map("n", "<leader>dO", dap_call("step_out"), "Step out")
map("n", "<leader>dr", function()
	require("dap").repl.toggle()
end, "Debug REPL")
map("n", "<leader>du", function()
	require("dapui").toggle()
end, "Debug UI")
map("n", "<leader>dt", dap_call("terminate"), "Terminate")

-- Git
map("n", "<leader>gd", ex("DiffviewOpen"), "Git diff")
map("n", "<leader>gh", ex("DiffviewFileHistory"), "Git history (project)")
map("n", "<leader>gH", ex("DiffviewFileHistory %"), "Git history (this file)")
map("n", "<leader>gc", ex("DiffviewClose"), "Close git diff")

-- Sessions
map("n", "<leader>qs", function()
	require("persistence").load()
end, "Restore project session")
map("n", "<leader>ql", function()
	require("persistence").load({ last = true })
end, "Restore last session")
map("n", "<leader>qS", function()
	require("persistence").select()
end, "Select session")
map("n", "<leader>qd", function()
	require("persistence").stop()
end, "Stop session saving")
