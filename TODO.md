# TODO

## Done

* MCP support in pi: servers for gh, atuin, carapace, npx refs, fetch, context7
* pi packages installed in bootstrap (`pi-mcp-adapter`, `@maxpaulus/pi-cline`) + cline as default harness
* catppuccin pi themes: tint tool-box block backgrounds per flavor

## Open

* install virtual disks
  * mise packages
  * Taminaru
* gh smoother
* secrets management
* env
* error in fyler

> E5108: Lua: vim/_core/shared:634: after the second argument: expected table, got nil
stack traceback:
	[C]: in function 'error'
	vim/_core/shared:1315: in function 'validate'
	vim/_core/shared:634: in function 'tbl_merge_force'
	...u/.local/share/nvim/lazy/fyler.nvim/lua/fyler/config.lua:248: in function 'view'
	...are/nvim/lazy/fyler.nvim/lua/fyler/views/finder/init.lua:73: in function 'open'
	...are/nvim/lazy/fyler.nvim/lua/fyler/views/finder/init.lua:370: in function 'open'
	...are/nvim/lazy/fyler.nvim/lua/fyler/views/finder/init.lua:394: in function 'toggle'
	...taminaru/.local/share/nvim/lazy/fyler.nvim/lua/fyler.lua:87: in function 'toggle'
	...ity/lua/astrocommunity/file-explorer/fyler-nvim/init.lua:17: in function <...ity/lua/astrocommunity/file-explorer/fyler-nvim/init.lua:17>
