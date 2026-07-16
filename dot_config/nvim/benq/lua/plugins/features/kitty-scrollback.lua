  return {
    'mikesmithgh/kitty-scrollback.nvim',
    enabled = true,
    version = '^6.0.0',
    lazy = true,
    cmd = { 'KittyScrollbackGenerateKittens', 'KittyScrollbackCheckHealth', 'KittyScrollbackGenerateCommandLineEditing' },
    event = { 'User KittyScrollbackLaunch' },
    opts = {}
  }
