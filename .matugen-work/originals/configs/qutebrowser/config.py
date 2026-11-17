# =========================
# Nvim / VS Code Dark Theme
# =========================

# Load only this declarative config
config.load_autoconfig(False)

# Completion
c.colors.completion.fg = "#d4d4d4"
c.colors.completion.category.fg = "#569cd6"
c.colors.completion.category.bg = "#252525"
c.colors.completion.item.selected.fg = "#ffffff"
c.colors.completion.item.selected.bg = "#3a3a3a"
c.colors.completion.match.fg = "#dcdcaa"

# Statusbar
c.colors.statusbar.normal.fg = "#d4d4d4"
c.colors.statusbar.normal.bg = "#1f1f1f"

c.colors.statusbar.insert.fg = "#1f1f1f"
c.colors.statusbar.insert.bg = "#4ec9b0"

c.colors.statusbar.command.fg = "#d4d4d4"
c.colors.statusbar.command.bg = "#1f1f1f"

c.colors.statusbar.url.fg = "#569cd6"
c.colors.statusbar.url.success.http.fg = "#4ec9b0"
c.colors.statusbar.url.success.https.fg = "#4ec9b0"
c.colors.statusbar.url.error.fg = "#f44747"

# Tabs
c.colors.tabs.bar.bg = "#1f1f1f"

c.colors.tabs.even.fg = "#888888"
c.colors.tabs.even.bg = "#252525"

c.colors.tabs.odd.fg = "#888888"
c.colors.tabs.odd.bg = "#252525"

c.colors.tabs.selected.even.fg = "#d4d4d4"
c.colors.tabs.selected.even.bg = "#3a3a3a"

c.colors.tabs.selected.odd.fg = "#d4d4d4"
c.colors.tabs.selected.odd.bg = "#3a3a3a"

# Webpage
c.colors.webpage.bg = "#1f1f1f"

# =========================
# Dark Mode
# =========================

# Prefer websites' native dark themes
c.colors.webpage.preferred_color_scheme = "dark"

# Force dark mode on websites without a dark theme
c.colors.webpage.darkmode.enabled = True
c.colors.webpage.darkmode.policy.page = "always"
c.colors.webpage.darkmode.policy.images = "smart"
c.colors.webpage.darkmode.algorithm = "lightness-cielab"

c.content.prefers_reduced_motion = True
