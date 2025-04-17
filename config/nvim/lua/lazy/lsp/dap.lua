return {

  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dap.adapters["local-lua"] = {
        type = "executable",
        command = "local-lua-dbg",
        enrich_config = function(config, on_config)
          if not config["extensionPath"] then
            local c = vim.deepcopy(config)
            c.extensionPath = "/usr/lib/node_modules/local-lua-debugger-vscode/"
            on_config(c)
          else
            on_config(config)
          end
        end,
      }

      -- Example config: https://github.com/mfussenegger/nvim-dap/wiki/C-C---Rust-(via--codelldb)
      dap.adapters.lldb = {
        type = 'executable',
        command = '/usr/bin/lldb-dap',
        name = 'lldb'
      }

      dap.configurations.cpp = {
        {
          name = 'Launch',
          type = 'lldb',
          request = 'launch',
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
        },
      }
      -- dap.configurations.c = dap.configurations.cpp

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      vim.keymap.set("n", "<leader>dv", function() dapui.eval(nil, { enter = true }) end,
        { desc = "Inspect value" })

      vim.keymap.set("n", "<leader>dt", dap.toggle_breakpoint,
        { noremap = true, silent = true, desc = "Breakpoint" })
      vim.keymap.set("n", "<leader>dr", dap.run_to_cursor,
        { noremap = true, silent = true, desc = "Run to cursor" })
      vim.keymap.set("n", "<leader>dd", dap.repl.open, { noremap = true, silent = true, desc = "Debugger" })

      vim.keymap.set("n", "<M-c>", dap.continue, { noremap = true, silent = true, desc = "Continue" })
      vim.keymap.set("n", "<M-a>", dap.step_back, { noremap = true, silent = true, desc = "Step back" })
      vim.keymap.set("n", "<M-s>", dap.step_into, { noremap = true, silent = true, desc = "Step into" })
      vim.keymap.set("n", "<M-d>", dap.step_out, { noremap = true, silent = true, desc = "Step out" })
      vim.keymap.set("n", "<M-f>", dap.step_over, { noremap = true, silent = true, desc = "Step over" })
    end,
  },

  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
  },

  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
  },

  {
    "mfussenegger/nvim-dap-python",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    ft = { "python" },
    config = function()
      local dap = require("dap-python")
      dap.setup("python3") -- "uv"
      dap.test_runner = 'pytest'

      vim.keymap.set("n", "<leader>dfm", dap.test_method, { noremap = true, silent = true, desc = "Test Method" })
      vim.keymap.set("n", "<leader>dfc", dap.test_class, { noremap = true, silent = true, desc = "Test Class" })
      vim.keymap.set("x", "<leader>df", dap.debug_selection,
        { noremap = true, silent = true, desc = "Debug Selection" })
    end,
  },

  {
    "leoluz/nvim-dap-go",
    ft = { "go" },
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      local dap = require("dap-go")
      dap.setup()
      vim.keymap.set("n", "<leader>dft", dap.debug_test, { noremap = true, silent = true, desc = "Test" })
    end,
  },

  -- {
  -- 	"nvim-neotest/neotest",
  -- 	dependencies = {
  -- 		"nvim-neotest/nvim-nio",
  -- 		"nvim-lua/plenary.nvim",
  -- 		"nvim-treesitter/nvim-treesitter",
  -- 		"nvim-neotest/neotest-python",
  -- 		"alfaix/neotest-gtest",
  -- 	},
  -- 	config = function()
  -- 		local neo = require("neotest")
  -- 		neo.setup({
  -- 			discovery = {
  -- 				-- Drastically improve performance in ginormous projects by
  -- 				-- only AST-parsing the currently opened buffer.
  -- 				enabled = false,
  -- 				-- Number of workers to parse files concurrently.
  -- 				-- A value of 0 automatically assigns number based on CPU.
  -- 				-- Set to 1 if experiencing lag.
  -- 				concurrent = 1,
  -- 			},
  -- 			running = {
  -- 				-- Run tests concurrently when an adapter provides multiple commands to run.
  -- 				concurrent = true,
  -- 			},
  -- 			summary = {
  -- 				-- Enable/disable animation of icons.
  -- 				animated = false,
  -- 			},
  -- 			-- adapters = {
  -- 			-- 	require("neotest-python")({
  -- 			-- 		dap = { justMyCode = false },
  -- 			-- 		args = { "--log-level", "DEBUG" },
  -- 			-- 		runner = "pytest",
  -- 			-- 	}),
  -- 			-- 	require("neotest-gtest").setup({})
  -- 			-- }
  -- 		})
  --
  -- 		vim.keymap.set("n", "<leader>nt", neo.run.run, { noremap = true, silent = true, desc = "Run" })
  -- 		vim.keymap.set("n", "<leader>nt", neo.run.stop, { noremap = true, silent = true, desc = "Stop" })
  -- 		vim.keymap.set("n", "<leader>no", neo.output.open, { noremap = true, silent = true, desc = "View output" })
  -- 		vim.keymap.set("n", "<leader>nO", function() neo.output.open({ enter = true, }) end,
  -- 			{ noremap = true, silent = true, desc = "Open enter" }
  -- 		)
  -- 		vim.keymap.set("n", "<leader>ns", neo.summary.toggle { noremap = true, silent = true, desc = "Summary" })
  -- 		vim.keymap.set("n", "<leader>nf", function() neo.run.run(vim.fn.expand("%:p")) end,
  -- 			{ noremap = true, silent = true, desc = "Run file" }
  -- 		)
  -- 		vim.keymap.set("n", "[n", function() neo.jump.prev({ status = "failed" }) end,
  -- 			{ noremap = true, silent = true, desc = "Prev failed" })
  -- 		vim.keymap.set("n", "]n", function() neo.jump.next({ status = "failed" }) end,
  -- 			{ noremap = true, silent = true, desc = "Next failed" })
  -- 	end
  -- },

}
