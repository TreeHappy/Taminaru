return {
  {
    "3rd/image.nvim",
    -- nvim runs inside a podman container while the terminal (Ghostty) is on
    -- the host, so image.nvim must not use the kitty "file" transmit medium
    -- (the terminal can't read container paths). Setting SSH_TTY makes the
    -- kitty backend fall back to inline "direct" transmission.
    init = function()
      vim.env.SSH_TTY = "1"
    end,
  },
}
