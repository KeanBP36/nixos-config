-- =========================================
-- Basic Neovim settings
-- =========================================

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

vim.opt.smartindent = true
vim.opt.wrap = false

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.termguicolors = true
vim.opt.cursorline = true

vim.opt.mouse = "a"

-- Use system clipboard
vim.opt.clipboard = "unnamedplus"


-- =========================================
-- Bootstrap lazy.nvim
-- =========================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
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
     -- =====================================
    -- Fuzzy finder
    -- =====================================

    {
        "nvim-telescope/telescope.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
    },

    -- =====================================
    -- File tree
    -- =====================================

    {
        "nvim-tree/nvim-tree.lua",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
    },

    -- =====================================
    -- Treesitter
    -- =====================================

    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
    },

    -- =====================================
    -- Statusline
    -- =====================================

    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
    },

    -- =====================================
    -- Buffer tabs
    -- =====================================

    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
    },

    -- =====================================
    -- Dashboard
    -- =====================================

    {
        "goolord/alpha-nvim",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
    },

    -- =====================================
    -- Which-key
    -- =====================================

    {
        "folke/which-key.nvim",
    },

    -- =====================================
    -- Git
    -- =====================================

    {
        "lewis6991/gitsigns.nvim",
    },

    -- =====================================
    -- Surround
    -- =====================================

    {
        "kylechui/nvim-surround",
        version = "*",
    },

    -- =====================================
    -- Comments
    -- =====================================

    {
        "numToStr/Comment.nvim",
    },

    -- =====================================
    -- TODO / FIXME
    -- =====================================

    {
        "folke/todo-comments.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
    },

    -- =====================================
    -- Indentation guides
    -- =====================================

    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
    },

    -- =====================================
    -- Animations
    -- =====================================

    {
        "echasnovski/mini.animate",
        version = false,
    },

    -- =====================================
    -- Highlight references
    -- =====================================

    {
        "RRethy/vim-illuminate",
    },

    -- =====================================
    -- Notifications
    -- =====================================

    {
        "rcarriga/nvim-notify",
    },

    -- =====================================
    -- UI
    -- =====================================

    {
        "folke/noice.nvim",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
    },

    -- =====================================
    -- Diagnostics
    -- =====================================

    {
        "folke/trouble.nvim",
    },

    -- =====================================
    -- LSP
    -- =====================================

        {
        "neovim/nvim-lspconfig",
    },
}, {
    lockfile = "/etc/nixos-config/home/keanbp/nvim/lazy-lock.json",
})
    
-- =========================================
-- Colors
-- =========================================

local colors = {
    bg       = "#1f1f1f",
    fg       = "#d4d4d4",
    red      = "#f44747",
    green    = "#608b4e",
    yellow   = "#dcdcaa",
    blue     = "#569cd6",
    purple   = "#c586c0",
    cyan     = "#4ec9b0",
    gray     = "#666666",
    white    = "#ffffff",
}


-- =========================================
-- Editor colors
-- =========================================

vim.cmd("highlight clear")
vim.cmd("set background=dark")

vim.api.nvim_set_hl(0, "Normal", {
    fg = colors.fg,
    bg = colors.bg,
})

vim.api.nvim_set_hl(0, "NormalFloat", {
    fg = colors.fg,
    bg = colors.bg,
})

vim.api.nvim_set_hl(0, "CursorLine", {
    bg = "#292929",
})

vim.api.nvim_set_hl(0, "CursorLineNr", {
    fg = colors.blue,
    bold = true,
})

vim.api.nvim_set_hl(0, "LineNr", {
    fg = colors.gray,
})

vim.api.nvim_set_hl(0, "Comment", {
    fg = colors.gray,
    italic = true,
})

vim.api.nvim_set_hl(0, "Constant", {
    fg = colors.cyan,
})

vim.api.nvim_set_hl(0, "String", {
    fg = colors.green,
})

vim.api.nvim_set_hl(0, "Character", {
    fg = colors.green,
})

vim.api.nvim_set_hl(0, "Number", {
    fg = colors.cyan,
})

vim.api.nvim_set_hl(0, "Boolean", {
    fg = colors.blue,
})

vim.api.nvim_set_hl(0, "Identifier", {
    fg = colors.fg,
})

vim.api.nvim_set_hl(0, "Function", {
    fg = colors.yellow,
})

vim.api.nvim_set_hl(0, "Statement", {
    fg = colors.purple,
})

vim.api.nvim_set_hl(0, "Keyword", {
    fg = colors.purple,
})

vim.api.nvim_set_hl(0, "Type", {
    fg = colors.blue,
})

vim.api.nvim_set_hl(0, "Operator", {
    fg = colors.fg,
})

vim.api.nvim_set_hl(0, "Delimiter", {
    fg = colors.fg,
})

vim.api.nvim_set_hl(0, "Special", {
    fg = colors.cyan,
})

vim.api.nvim_set_hl(0, "Error", {
    fg = colors.red,
})

vim.api.nvim_set_hl(0, "Todo", {
    fg = colors.yellow,
    bold = true,
})


-- =========================================
-- Telescope
-- =========================================

vim.api.nvim_set_hl(0, "TelescopeNormal", {
    fg = colors.fg,
    bg = colors.bg,
})

vim.api.nvim_set_hl(0, "TelescopeBorder", {
    fg = colors.gray,
    bg = colors.bg,
})

vim.api.nvim_set_hl(0, "TelescopeSelection", {
    fg = colors.white,
    bg = "#333333",
})

vim.api.nvim_set_hl(0, "TelescopeMatching", {
    fg = colors.blue,
    bold = true,
})


-- =========================================
-- Lualine
-- =========================================

require("lualine").setup({
    options = {
        theme = {
            normal = {
                a = {
                    fg = colors.bg,
                    bg = colors.blue,
                    gui = "bold",
                },
                b = {
                    fg = colors.fg,
                    bg = "#292929",
                },
                c = {
                    fg = colors.fg,
                    bg = colors.bg,
                },
            },

            insert = {
                a = {
                    fg = colors.bg,
                    bg = colors.green,
                    gui = "bold",
                },
            },

            visual = {
                a = {
                    fg = colors.bg,
                    bg = colors.purple,
                    gui = "bold",
                },
            },

            replace = {
                a = {
                    fg = colors.bg,
                    bg = colors.red,
                    gui = "bold",
                },
            },

            inactive = {
                a = {
                    fg = colors.gray,
                    bg = colors.bg,
                },
                b = {
                    fg = colors.gray,
                    bg = colors.bg,
                },
                c = {
                    fg = colors.gray,
                    bg = colors.bg,
                },
            },
        },

        globalstatus = true,
        component_separators = "",
        section_separators = "",
    },
})


-- =========================================
-- Nvim-tree
-- =========================================

require("nvim-tree").setup({
    view = {
        width = 30,
    },

    renderer = {
        group_empty = true,
    },

    filters = {
        dotfiles = false,
    },
})


-- =========================================
-- Treesitter
-- =========================================

vim.api.nvim_set_hl(0, "@variable", {
    fg = colors.fg,
})

vim.api.nvim_set_hl(0, "@function", {
    fg = colors.yellow,
})

vim.api.nvim_set_hl(0, "@keyword", {
    fg = colors.purple,
})

vim.api.nvim_set_hl(0, "@type", {
    fg = colors.blue,
})

vim.api.nvim_set_hl(0, "@string", {
    fg = colors.green,
})

vim.api.nvim_set_hl(0, "@constant", {
    fg = colors.cyan,
})

vim.api.nvim_set_hl(0, "@number", {
    fg = colors.cyan,
})

vim.api.nvim_set_hl(0, "@comment", {
    fg = colors.gray,
    italic = true,
})
