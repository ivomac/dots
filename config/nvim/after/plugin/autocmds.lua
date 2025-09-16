-- Open folders in terminal explorer
vim.api.nvim_create_autocmd({ "VimEnter", "BufAdd" },
  {
    group = vim.api.nvim_create_augroup("EXPLORER", { clear = true }),
    pattern = "*",
    callback = function(ev)
      if vim.g.SessionLoad ~= 1 and vim.fn.isdirectory(ev.file) == 1 then
        require("floatterm").open({choice="Yazi"})
        vim.api.nvim_buf_delete(ev.buf, { force = true })
      end
    end
  }
)

-- Read templates onto new files
vim.api.nvim_create_autocmd({ "BufNewFile" }, {
  group = vim.api.nvim_create_augroup("TEMPLATES", { clear = true }),
  callback = function(ev)
    local bufname = vim.api.nvim_buf_get_name(ev.buf)
    local stats = vim.uv.fs_stat(bufname)

    if not stats then
      local name = vim.fn.fnamemodify(bufname, ":t")
      local ext = vim.fn.fnamemodify(bufname, ":e")
      local config = vim.fn.stdpath("config")
      for _, candidate in ipairs({ name, ext }) do
        local stpl = string.format("%s/templates/%s.stpl", config, candidate)
        local f = io.open(stpl, "r")
        if f then
          vim.snippet.expand(f:read("*a"))
          f:close()
          return
        end

        local tpl = string.format("%s/templates/%s.tpl", config, candidate)
        if vim.fn.filereadable(tpl) == 1 then
          vim.cmd("0r " .. tpl)
          return
        end
      end
    end
  end
})

-- No syntax on large files
-- Ask user if they are sure they want to open very large file
vim.api.nvim_create_autocmd({ "BufReadPre" },
  {
    group = vim.api.nvim_create_augroup("LARGE_FILES", { clear = true }),
    callback = function(ev)
      local stats = vim.uv.fs_stat(vim.api.nvim_buf_get_name(ev.buf))
      local input = "y"
      if stats then
        if stats.size > 4 * 1024 * 1024 then -- 4 MB
          -- get user input to decide whether to open the file
          input = vim.fn.input("File is larger than 4 MB. Open anyway? [y/N]: ")
          if input:lower() ~= "y" then
            vim.schedule(
              function() vim.api.nvim_buf_delete(ev.buf, { force = true }) end
            )
            return
          end
        end
        if stats.size > 1 * 1024 * 1024 then -- 1 MB
          vim.notify("Large file detected. Disabling syntax…")
          vim.schedule(
            function()
              vim.api.nvim_buf_call(ev.buf,
                function()
                  vim.bo[ev.buf].syntax = "none"
                  vim.opt_local.syntax = "off"
                  vim.opt_local.statuscolumn = ""
                  vim.opt_local.conceallevel = 0
                  vim.opt_local.foldmethod = "manual"
                end
              )
            end
          )
        end
      end
    end
  }
)

-- Return cursor to last position on BufRead
vim.api.nvim_create_autocmd("BufReadPost",
  {
    group = vim.api.nvim_create_augroup("RETURN_LAST_POS", { clear = true }),
    callback = function(ev)
      local row, col = unpack(vim.api.nvim_buf_get_mark(ev.buf, '"'))
      if row > 0 and row <= vim.api.nvim_buf_line_count(ev.buf) then
        vim.api.nvim_win_set_cursor(0, { row, col })
      end
    end
  }
)

-- Save with <Esc>
vim.api.nvim_create_autocmd({ "BufEnter" },
  {
    group = vim.api.nvim_create_augroup("WRITE_ESC", { clear = true }),
    callback = function()
      if vim.g.started_by_firenvim then
        -- save with <Esc> in firenvim
        vim.keymap.set({ "i", "v" }, "<Esc>", "<Esc>:silent write<CR>", { noremap = true, silent = true })
        vim.keymap.set({ "n" }, "<Esc>", "<Esc>:silent write<CR>:quit<CR>", { noremap = true, silent = true })
      elseif not vim.bo.readonly and not vim.b[0].was_readonly then
        -- save with <Esc> in normal mode (if not read-only)
        vim.keymap.set("n", "<Esc>",
          function()
            if vim.bo.modified and vim.fn.expand("%") ~= "" and vim.bo.buftype == "" then
              return vim.cmd("update")
            end

            if
                not vim.bo.modified
                and vim.fn.bufname('%') == ''
                and vim.fn.line('$') == 1
                and vim.fn.getline(1) == ""
                and #vim.fn.getbufinfo({ buflisted = 1 }) == 1
            then
              return vim.cmd('silent quit')
            end
          end,
          { noremap = true, silent = true }
        )
      else
        -- save with :SW in readonly
        vim.api.nvim_create_user_command('SW',
          function()
            vim.cmd("silent! write !sudo -A tee % > /dev/null")
            vim.cmd("edit!")
          end,
          { bang = true }
        )

        -- remove readonly
        vim.opt_local.readonly = false
        vim.opt_local.autoread = true
        vim.b[0].was_readonly = true
      end
    end,
  }
)

-- Highlight yank
vim.api.nvim_create_autocmd({ "TextYankPost" },
  {
    group = vim.api.nvim_create_augroup("HIGHLIGHT_YANK", { clear = true }),
    callback = function()
      vim.hl.on_yank({ highlight = "IncSearch", timeout = 120 })
    end,
  }
)

