# =========================
# Nvim / VS Code Dark Theme
# =========================

# Load only this declarative config
config.load_autoconfig(False)

# Completion
c.colors.completion.fg = "#4c444c"
c.colors.completion.category.fg = "#ea42b4"
c.colors.completion.category.bg = "#110d11"
c.colors.completion.item.selected.fg = "#eae0e7"
c.colors.completion.item.selected.bg = "#1f1a1f"
c.colors.completion.match.fg = "#eeb198"

# Statusbar
c.colors.statusbar.normal.fg = "#4c444c"
c.colors.statusbar.normal.bg = "#110d11"

c.colors.statusbar.insert.fg = "#110d11"
c.colors.statusbar.insert.bg = "#df6a38"

c.colors.statusbar.command.fg = "#4c444c"
c.colors.statusbar.command.bg = "#110d11"

c.colors.statusbar.url.fg = "#ea42b4"
c.colors.statusbar.url.success.http.fg = "#df6a38"
c.colors.statusbar.url.success.https.fg = "#df6a38"
c.colors.statusbar.url.error.fg = "#eb5065"

# Tabs
c.colors.tabs.bar.bg = "#110d11"

c.colors.tabs.even.fg = "#2e282e"
c.colors.tabs.even.bg = "#110d11"

c.colors.tabs.odd.fg = "#2e282e"
c.colors.tabs.odd.bg = "#110d11"

c.colors.tabs.selected.even.fg = "#4c444c"
c.colors.tabs.selected.even.bg = "#1f1a1f"

c.colors.tabs.selected.odd.fg = "#4c444c"
c.colors.tabs.selected.odd.bg = "#1f1a1f"

# Webpage
c.colors.webpage.bg = "#110d11"

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
