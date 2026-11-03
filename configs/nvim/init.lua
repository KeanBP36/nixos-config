-- =========================================
-- Options
-- =========================================
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

local undodir = vim.fn.stdpath("state") .. "/undo"
vim.fn.mkdir(undodir, "p")
o.undofile = true
o.undodir = undodir

-- =========================================
-- Bootstrap lazy.nvim
-- =========================================
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

-- =========================================
-- DAP adapters (top-level so keymaps can always call it)
-- =========================================
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

-- =========================================
-- Plugins
-- =========================================
require("lazy").setup({
	-- Completion
	{
		"saghen/blink.cmp",
		version = "1.*",
		dependencies = { "rafamadriz/friendly-snippets" },
		opts = {
			keymap = { preset = "enter" },
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

	-- LSP (servers are installed through Nix)
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

	-- Linting (only runs linters that are on PATH)
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
					local cmd = linter and linter.cmd
					if type(cmd) == "function" then
						cmd = cmd()
					end
					return cmd and vim.fn.executable(cmd) == 1
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

	-- UI
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
	{ "akinsho/bufferline.nvim", version = "*", dependencies = { "nvim-tree/nvim-web-devicons" }, opts = {} },
	{ "folke/which-key.nvim", event = "VeryLazy", opts = {} },
	{ "folke/trouble.nvim", opts = {} },
	{ "lewis6991/gitsigns.nvim", opts = {} },
	{ "kylechui/nvim-surround", version = "*", event = "VeryLazy", opts = {} },
	{ "numToStr/Comment.nvim", opts = {} },
	{ "folke/todo-comments.nvim", dependencies = { "nvim-lua/plenary.nvim" }, opts = {} },
	{ "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },

	-- Notifications (used by noice)
	{ "rcarriga/nvim-notify", opts = {} },

	-- Replaces the command line, messages and popup menus
	{
		"folke/noice.nvim",
		dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
		opts = {},
	},

	-- Smooth cursor and window movement (disabled for now)
	-- { "echasnovski/mini.animate", version = false, opts = {} },

	-- Highlights other uses of the word under the cursor
	{ "RRethy/vim-illuminate" },

	-- Start screen shown when you open Neovim with no file
	{
		"goolord/alpha-nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("alpha").setup(require("alpha.themes.startify").config)
		end,
	},

	-- Debugging (nvim-dap)
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

	-- Git / history
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
}, {
	-- Lives in your Neovim config dir, which is writable.
	lockfile = vim.fn.stdpath("state") .. "/lazy-lock.json",
})

-- =========================================
-- Colors (re-applied after any colorscheme change)
-- =========================================
local c = {
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
	local function hl(group, spec)
		vim.api.nvim_set_hl(0, group, spec)
	end

	-- Editor
	hl("Normal", { fg = c.fg, bg = c.bg })
	hl("NormalFloat", { fg = c.fg, bg = c.bg })
	hl("CursorLine", { bg = "#292929" })
	hl("CursorLineNr", { fg = c.blue, bold = true })
	hl("LineNr", { fg = c.gray })

	-- Syntax (classic groups)
	local syntax = {
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
	}
	for group, spec in pairs(syntax) do
		hl(group, spec)
	end

	-- Treesitter groups
	local ts = {
		["@variable"] = { fg = c.fg },
		["@function"] = { fg = c.yellow },
		["@keyword"] = { fg = c.purple },
		["@type"] = { fg = c.blue },
		["@string"] = { fg = c.green },
		["@constant"] = { fg = c.cyan },
		["@number"] = { fg = c.cyan },
		["@comment"] = { fg = c.gray, italic = true },
	}
	for group, spec in pairs(ts) do
		hl(group, spec)
	end

	-- Diagnostics
	local diag = { Error = c.red, Warn = c.yellow, Info = c.blue, Hint = c.cyan }
	for name, color in pairs(diag) do
		hl("Diagnostic" .. name, { fg = color })
		hl("DiagnosticUnderline" .. name, { undercurl = true, sp = color })
	end

	-- Telescope
	hl("TelescopeNormal", { fg = c.fg, bg = c.bg })
	hl("TelescopeBorder", { fg = c.gray, bg = c.bg })
	hl("TelescopeSelection", { fg = c.white, bg = "#333333" })
	hl("TelescopeMatching", { fg = c.blue, bold = true })
end

vim.api.nvim_create_autocmd("ColorScheme", { callback = apply_colors })
vim.cmd("highlight clear")
vim.opt.background = "dark"
apply_colors()

-- =========================================
-- Diagnostics
-- =========================================
vim.diagnostic.config({
	virtual_text = true,
	signs = true,
	underline = true,
	severity_sort = true,
	update_in_insert = false,
	float = { border = "rounded", source = "if_many" },
})

-- =========================================
-- Keymaps
-- =========================================
local function map(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { desc = desc })
end
local function cmd(c)
	return "<cmd>" .. c .. "<cr>"
end
local function dap_call(fn)
	return function()
		require("dap")[fn]()
	end
end

-- Files and buffers
map("n", "<leader>e", cmd("NvimTreeToggle"), "File tree")
map("n", "<leader>ff", cmd("Telescope find_files"), "Find files")
map("n", "<leader>fg", cmd("Telescope live_grep"), "Grep")
map("n", "<leader>fb", cmd("Telescope buffers"), "Buffers")
map("n", "<leader>xx", cmd("Trouble diagnostics toggle"), "Diagnostics")
map("n", "<S-l>", cmd("BufferLineCycleNext"), "Next buffer")
map("n", "<S-h>", cmd("BufferLineCyclePrev"), "Previous buffer")

-- LSP
map("n", "gd", vim.lsp.buf.definition, "Go to definition")
map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
map("n", "gr", vim.lsp.buf.references, "References")
map("n", "K", vim.lsp.buf.hover, "Hover")
map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
map("n", "<leader>D", vim.lsp.buf.type_definition, "Type definition")
map("n", "<leader>ds", vim.lsp.buf.document_symbol, "Document symbols")

-- Formatting
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
end, "Continue")
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
map("n", "<leader>gd", cmd("DiffviewOpen"), "Git diff")
map("n", "<leader>gh", cmd("DiffviewFileHistory"), "Git file history")
map("n", "<leader>gH", cmd("DiffviewFileHistory %"), "Current file history")
map("n", "<leader>gD", cmd("DiffviewClose"), "Close git diff")

-- Undo tree
map("n", "<leader>u", cmd("UndotreeToggle"), "Undo tree")

-- Sessions
map("n", "<leader>qs", function()
	require("persistence").load()
end, "Restore project session")
map("n", "<leader>qS", function()
	require("persistence").select()
end, "Select session")
map("n", "<leader>ql", function()
	require("persistence").load({ last = true })
end, "Restore last session")
map("n", "<leader>qd", function()
	require("persistence").stop()
end, "Stop session saving")
