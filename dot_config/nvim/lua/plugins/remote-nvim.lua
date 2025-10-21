return {
  "amitds1997/remote-nvim.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    require("remote-nvim").setup({
      client_callback = function(port, workspace_config)
        local session_name = "remote-" .. workspace_config.host
        local cmd = string.format(
          "tmux new-session -d -s %s 'nvim --server localhost:%s --remote-ui'",
          session_name,
          port
        )
        vim.fn.jobstart(cmd, {
          detach = true,
          on_exit = function(job_id, exit_code, event_type)
            print(string.format("Client %d exited with code %d (Event: %s)", job_id, exit_code, event_type))
          end,
        })
      end,
    })
  end,
}

