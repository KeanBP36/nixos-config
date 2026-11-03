-- =========================================
-- Options
-- =========================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local o = vim.opt
o.number = true
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.smartindent = true
o.wrap = false
o.ignorecase = true
o.smartcase = true
o.termguicolors = true
o.cursorline = true
o.mouse = "a"
o.clipboard = "unnamedplus"
o.signcolumn = "yes"
o.updatetime = 250

-- =========================================
-- Bootstrap lazy.nvim
-- =========================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

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
			keymap = { preset = "enter" }, -- Enter accepts, Ctrl-n/p or arrows to move
			appearance = { nerd_font_variant = "mono" },
			completion = {
				documentation = { auto_show = true, auto_show_delay_ms = 200 },
				ghost_text = { enabled = true },
				menu = { border = "rounded" },
			},
			signature = { enabled = true },
			sources = { default = { "lsp", "path", "snippets", "buffer" } },
			-- Lua matcher: the prebuilt Rust binary often won't run on NixOS
			fuzzy = { implementation = "lua" },
		},
	},

	-- LSP
	{
		"neovim/nvim-lspconfig",
		dependencies = { "saghen/blink.cmp" },
		config = function()
			vim.lsp.config("*", {
				capabilities = require("blink.cmp").get_lsp_capabilities(),
			})
			-- Only enable servers you've installed via Nix (see extraPackages below)
			vim.lsp.enable({
				"lua_ls",
				"nixd",
				"pyright",
				"clangd",
				"rust_analyzer",
				"ts_ls",
				"bashls",
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
				sh = { "shfmt" },
				bash = { "shfmt" },
			},
			format_on_save = { timeout_ms = 2000, lsp_format = "fallback" },
		},
	},

	-- Linting
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

			-- Skip linters that aren't installed instead of erroring
			local function available(names)
				return vim.tbl_filter(function(name)
					local l = lint.linters[name]
					local cmd = l and l.cmd
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
						lint.try_lint(available(names))
					end
				end,
			})
		end,
	},

	-- Treesitter (main branch API)
	{
		"nvim-treesitter/nvim-treesitter",
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
			local function mode(color)
				return { a = { fg = bg, bg = color, gui = "bold" } }
			end
			require("lualine").setup({
				options = {
					globalstatus = true,
					component_separators = "",
					section_separators = "",
					theme = {
						normal = vim.tbl_extend("force", mode("#569cd6"), {
							b = { fg = fg, bg = "#292929" },
							c = { fg = fg, bg = bg },
						}),
						insert = mode("#608b4e"),
						visual = mode("#c586c0"),
						replace = mode("#f44747"),
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
		opts = {},
	},
	{
		"goolord/alpha-nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("alpha").setup(require("alpha.themes.startify").config)
		end,
	},
	{ "folke/which-key.nvim", event = "VeryLazy", opts = {} },
	{ "lewis6991/gitsigns.nvim", opts = {} },
	{ "kylechui/nvim-surround", version = "*", event = "VeryLazy", opts = {} },
	{ "numToStr/Comment.nvim", opts = {} },
	{ "folke/todo-comments.nvim", dependencies = { "nvim-lua/plenary.nvim" }, opts = {} },
	{ "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
	{ "echasnovski/mini.animate", version = false, opts = {} },
	{ "RRethy/vim-illuminate" },
	{ "rcarriga/nvim-notify", opts = {} },
	{
		"folke/noice.nvim",
		dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
		opts = {},
	},
	{ "folke/trouble.nvim", opts = {} },
}, {
	lockfile = "/etc/nixos-config/configs/nvim/lazy-lock.json",
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
	local hl = function(group, spec)
		vim.api.nvim_set_hl(0, group, spec)
	end

	-- Editor
	hl("Normal", { fg = c.fg, bg = c.bg })
	hl("NormalFloat", { fg = c.fg, bg = c.bg })
	hl("CursorLine", { bg = "#292929" })
	hl("CursorLineNr", { fg = c.blue, bold = true })
	hl("LineNr", { fg = c.gray })

	-- Syntax (classic + treesitter share colors)
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
local map = vim.keymap.set
map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "File tree" })
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
map("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics" })
map("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>f", function()
	require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format file" })
