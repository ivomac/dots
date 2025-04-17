-- Use j and k to move visually up and down
vim.keymap.set("n", "j", "gj", { noremap = true })
vim.keymap.set("n", "k", "gk", { noremap = true })

-- Center the screen on the cursor position after jumping
vim.keymap.set("n", "n", "nzz", { noremap = true })
vim.keymap.set("n", "N", "Nzz", { noremap = true })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true })

-- Keep the cursor in the same position when joining lines
vim.keymap.set("n", "J", "mzJ`z", { noremap = true })

-- Jump backwards on tags (<C-]> is jump forward by default)
vim.keymap.set("n", "<C-[>", "<C-T>", { noremap = true })

-- do not add jumps to the jump list with paragraph motions
for _, char in ipairs({ "{", "}", "(", ")" }) do
  vim.keymap.set("n", char,
    function()
      vim.cmd("keepjumps norm! " .. vim.v.count1 .. char)
    end,
    { noremap = true, silent = true }
  )
end
