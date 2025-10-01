#! /usr/bin/bash
if [ -f "$(which git)" ]; then
    echo "Git is already installed"
else
    echo "Installing git"
    sudo pacman -S --noconfirm git
fi

if [ -f "$(which yay)" ]; then
    echo "yay exists"
else
    echo "Installing yay"
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd ..
fi

applications=(firefox intellij-idea-ultimate-edition mupdf unzip nvim flameshot xclip i3blocks zsh libreoffice kitty)

for application in "${applications[@]}"; do
    if [ -f "$(which "$application")" ]; then
        echo "$application exists"
    else
        echo "Installing $application"
        yay -S --noconfirm "$application"
    fi
done

mkdir -p ~/.config/i3/
mkdir -p ~/.config/nvim
mkdir -p ~/.config/i3blocks

if [ ! -f ~/.config/i3/config ]; then
cat ~/.config/i3/config << 'EOF'
set $mod Mod4
font pango:monospace 8
exec --no-startup-id dex --autostart --environment i3
exec --no-startup-id xss-lock --transfer-sleep-lock -- i3lock --nofork
exec --no-startup-id nm-applet

set $refresh_i3status killall -SIGUSR1 i3status
bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10% && $refresh_i3status
bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10% && $refresh_i3status
bindsym XF86AudioMute exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && $refresh_i3status
bindsym XF86AudioMicMute exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle && $refresh_i3status

floating_modifier $mod
tiling_drag modifier titlebar
bindsym $mod+Return exec kitty
bindsym $mod+Shift+q kill

bindsym $mod+b exec firefox
bindsym $mod+Shift+i exec intellij-idea-ultimate-edition 
bindsym $mod+d exec --no-startup-id dmenu_run
bindsym Ctrl+Shift+S exec shutdown now
bindsym $mod+Shift+s exec flameshot gui

bindsym $mod+j focus left
bindsym $mod+k focus down
bindsym $mod+l focus up
bindsym $mod+semicolon focus right

bindsym $mod+Left focus left
bindsym $mod+Down focus down
bindsym $mod+Up focus up
bindsym $mod+Right focus right

bindsym $mod+Shift+j move left
bindsym $mod+Shift+k move down
bindsym $mod+Shift+l move up
bindsym $mod+Shift+semicolon move right

bindsym $mod+Shift+Left move left
bindsym $mod+Shift+Down move down
bindsym $mod+Shift+Up move up
bindsym $mod+Shift+Right move right

bindsym $mod+h split h

bindsym $mod+v split v

bindsym $mod+f fullscreen toggle

bindsym $mod+s layout stacking
bindsym $mod+w layout tabbed
bindsym $mod+e layout toggle split

bindsym $mod+Shift+space floating toggle

bindsym $mod+space focus mode_toggle

bindsym $mod+a focus parent


set $ws1 "1"
set $ws2 "2"
set $ws3 "3"
set $ws4 "4"
set $ws5 "5"
set $ws6 "6"
set $ws7 "7"
set $ws8 "8"
set $ws9 "9"
set $ws10 "10"

bindsym $mod+u workspace number $ws1
bindsym $mod+i workspace number $ws2
bindsym $mod+o workspace number $ws3
bindsym $mod+p workspace number $ws4
bindsym $mod+5 workspace number $ws5
bindsym $mod+6 workspace number $ws6
bindsym $mod+7 workspace number $ws7
bindsym $mod+8 workspace number $ws8
bindsym $mod+9 workspace number $ws9
bindsym $mod+0 workspace number $ws10

bindsym $mod+Shift+1 move container to workspace number $ws1
bindsym $mod+Shift+2 move container to workspace number $ws2
bindsym $mod+Shift+3 move container to workspace number $ws3
bindsym $mod+Shift+4 move container to workspace number $ws4
bindsym $mod+Shift+5 move container to workspace number $ws5
bindsym $mod+Shift+6 move container to workspace number $ws6
bindsym $mod+Shift+7 move container to workspace number $ws7
bindsym $mod+Shift+8 move container to workspace number $ws8
bindsym $mod+Shift+9 move container to workspace number $ws9
bindsym $mod+Shift+0 move container to workspace number $ws10

bindsym $mod+Shift+c reload

bindsym $mod+Shift+r restart

bindsym $mod+Shift+e exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'"

mode "resize" {
        bindsym j resize shrink width 10 px or 10 ppt
        bindsym k resize grow height 10 px or 10 ppt
        bindsym l resize shrink height 10 px or 10 ppt
        bindsym semicolon resize grow width 10 px or 10 ppt

        bindsym Left resize shrink width 10 px or 10 ppt
        bindsym Down resize grow height 10 px or 10 ppt
        bindsym Up resize shrink height 10 px or 10 ppt
        bindsym Right resize grow width 10 px or 10 ppt

        bindsym Return mode "default"
        bindsym Escape mode "default"
        bindsym $mod+r mode "default"
}

bindsym $mod+r mode "resize"

# class                 border  backgr. text    indicator child_border
client.focused          #FFFFFF #FFFFFF #000000 #FFFFFF   #FFFFFF
client.unfocused        #000000 #000000 #FFFFFF #000000   #000000
client.focused_inactive #000000 #000000 #FFFFFF #000000   #000000
client.urgent           #FF0000 #FF0000 #FFFFFF #FF0000   #FF0000

bar {
    status_command i3blocks
    font pango:DejaVu Sans Mono 11
}
EOF
fi

if [ ! -f ~/.config/i3blocks/config ]; then
cat > ~/.config/i3blocks/confit << 'EOF'

[battery]
command=echo "$(cat /sys/class/power_supply/BAT1/capacity)%"
interval=30

[cpu]
command= mpstat | grep all | awk '{print "CPU : "$5"%"}'
interval=3

[memory]
command=free -h | grep Mem | awk '{print "Memory : " $3 "/" $2}'
interval=3

[datetime]
command=date +"%d-%m-%y %H:%M"
interval=60

[wifi]
command=iwgetid -r
interval=10
EOF
fi

cat > codecopy.sh << 'EOF'

#!/bin/bash

if [ $# -lt 3 ]; then
    echo "Usage: $0 <project_directory> <output_file> <ext1> [ext2] [ext3] ..."
    exit 1
fi

project_path="$1"
output_file="$2"

if [ ! -d "$project_path" ]; then
    echo "Error: Directory '$project_path' does not exist!"
    exit 1
fi

if [[ "$output_file" != *.txt ]]; then
    output_file="${output_file}.txt"
fi

find_cmd="find \"$project_path\" -type f \\("
for ((i=3; i<=$#; i++)); do
    ext="${!i}"
    if [[ "$ext" != .* ]]; then
        ext=".$ext"
    fi
    
    if [ $i -eq 3 ]; then
        find_cmd="$find_cmd -name \"*$ext\""
    else
        find_cmd="$find_cmd -o -name \"*$ext\""
    fi
done
find_cmd="$find_cmd \\)"

find_cmd="$find_cmd ! -path \"*/.git/*\" ! -path \"*/build/*\" ! -path \"*/node_modules/*\" ! -path \"*/__pycache__/*\" ! -path \"*/.idea/*\""

> "$output_file"

eval "$find_cmd" | while read -r file; do
    rel_path=${file#$project_path/}
    echo >> "$output_file"
    echo "FILE: $rel_path" >> "$output_file"
    echo >> "$output_file"
    cat "$file" >> "$output_file" 2>/dev/null
    echo >> "$output_file"
done

echo "Done. Output saved to: $output_file"
EOF
if [ -d ~/.ssh ] && [ -z "$(ls -A ~/.ssh/)" ]; then
echo "Enter your email for ssh generation for github authentication"
read -r email
ssh-keygen -t ed25519 -C $email
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
echo "The github SSH Key is "
cat ~/.ssh/id_ed25519.pub
fi

cat > ~/.config/nvim/init.lua << 'EOF'
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50
vim.keymap.set('i', '<C-i>', '<Esc>', { noremap = true, silent = true })

require("lazy").setup({
  spec = {
    {
      "ms-jpq/coq_nvim",
      branch = "coq",
      dependencies = {
        { "ms-jpq/coq.artifacts", branch = "artifacts" },
        { "ms-jpq/coq.thirdparty", branch = "3p" }
      },
      init = function()
        vim.g.coq_settings = {
          auto_start = 'shut-up',
          keymap = { recommended = true },
          clients = {
            lsp = {
              enabled = true,
              resolve_timeout = 0.06,
            },
            snippets = { enabled = true },
          },
          display = {
            preview = {
              border = "rounded",
            },
            pum = {
              fast_close = false,
            },
          },
        }
      end,
    },

    {
      "neovim/nvim-lspconfig",
      dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "ms-jpq/coq_nvim",
      },
      config = function()
        require("mason").setup()
        require("mason-lspconfig").setup({
          ensure_installed = { "kotlin_language_server", "clangd" },
        })

        -- IMPORTANT: Must load COQ before setting up LSP servers
        local coq = require("coq")

        -- Kotlin LSP setup
        require("lspconfig").kotlin_language_server.setup(coq.lsp_ensure_capabilities({}))

        -- Clangd LSP setup with enhanced capabilities
        require("lspconfig").clangd.setup(coq.lsp_ensure_capabilities({
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
          },
          filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
          root_dir = require("lspconfig").util.root_pattern(
            '.clangd',
            '.clang-tidy',
            '.clang-format',
            'compile_commands.json',
            'compile_flags.txt',
            'configure.ac',
            '.git'
          ),
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
        }))

        vim.api.nvim_create_autocmd('LspAttach', {
          group = vim.api.nvim_create_augroup('UserLspConfig', {}),
          callback = function(ev)
            local opts = { buffer = ev.buf }
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)

            vim.keymap.set('n', '<leader>rn', function()
              return ":IncRename " .. vim.fn.expand("<cword>")
            end, { expr = true, buffer = ev.buf })

            vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
            vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
            vim.keymap.set('n', '<leader>f', function()
              vim.lsp.buf.format { async = true }
            end, opts)
            
            -- Additional keymaps for diagnostics
            vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
            vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
            vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts)
          end,
        })

        -- Enhanced diagnostic configuration
        vim.diagnostic.config({
          virtual_text = {
            prefix = '●',
            source = "if_many",
          },
          signs = true,
          underline = true,
          update_in_insert = false,
          severity_sort = true,
          float = {
            border = 'rounded',
            source = 'always',
            header = '',
            prefix = '',
          },
        })

        -- Diagnostic signs
        local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
        for type, icon in pairs(signs) do
          local hl = "DiagnosticSign" .. type
          vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
        end
      end,
    },

    {
      "smjonas/inc-rename.nvim",
      config = function()
        require("inc_rename").setup()
      end,
    },

    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
        require("nvim-treesitter.configs").setup({
          ensure_installed = { "c", "cpp", "kotlin", "lua", "vim", "vimdoc", "query" },
          highlight = { enable = true },
          indent = { enable = true },
        })
      end,
    },

    {
      "nvim-tree/nvim-tree.lua",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        require("nvim-tree").setup({
          view = { width = 30 },
          renderer = { group_empty = true },
          filters = { dotfiles = true },
        })
        vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { silent = true })
      end,
    },

    {
      "nvim-telescope/telescope.nvim",
      tag = "0.1.5",
      dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      },
      config = function()
        require("telescope").setup({
          extensions = {
            fzf = {
              fuzzy = true,
              override_generic_sorter = true,
              override_file_sorter = true,
              case_mode = "smart_case",
            }
          }
        })
        require("telescope").load_extension("fzf")
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
        vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
        vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
        vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
      end,
    },

    {
      "lewis6991/gitsigns.nvim",
      config = function()
        require("gitsigns").setup({
          signs = {
            add = { text = '+' },
            change = { text = '~' },
            delete = { text = '_' },
            topdelete = { text = '‾' },
            changedelete = { text = '~' },
          },
        })
      end,
    },

    {
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        require("lualine").setup({
          options = { theme = "auto" },
        })
      end,
    },

    {
      "folke/tokyonight.nvim",
      lazy = false,
      priority = 1000,
      config = function()
        vim.cmd([[colorscheme tokyonight]])
      end,
    },

    {
      "windwp/nvim-autopairs",
      config = function()
        require("nvim-autopairs").setup()
      end,
    },

    {
      "numToStr/Comment.nvim",
      config = function()
        require("Comment").setup()
      end,
    },

    {
      "kylechui/nvim-surround",
      config = function()
        require("nvim-surround").setup()
      end,
    },

    {
      "mfussenegger/nvim-dap",
      dependencies = { "rcarriga/nvim-dap-ui", "nvim-neotest/nvim-nio" },
      config = function()
        local dap = require("dap")
        local dapui = require("dapui")
        dapui.setup()
        dap.listeners.after.event_initialized["dapui_config"] = function()
          dapui.open()
        end
        dap.listeners.before.event_terminated["dapui_config"] = function()
          dapui.close()
        end
        dap.listeners.before.event_exited["dapui_config"] = function()
          dapui.close()
        end
      end,
    },

    {
      "akinsho/toggleterm.nvim",
      version = "*",
      config = function()
        require("toggleterm").setup({
          open_mapping = [[<c-\>]],
          direction = "float",
        })
      end,
    },
  },

  install = { colorscheme = { "tokyonight" } },
  checker = { enabled = true },
  git = { url_format = "https://github.com/%s.git" },
  concurrency = 1,
})
EOF

if [ ! -f "$(which zsh)" ]; then
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
cat > .zshrc << 'EOF'
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting zsh-autocomplete archlinux colorize)
source $ZSH/oh-my-zsh.sh
EOF
else 
    echo "ZSH exists"
fi
