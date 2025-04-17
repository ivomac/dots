vim.keymap.set("n", "Y", "y$")

vim.keymap.set("i", "<S-Insert>", '<C-O>"*P')

local suffix = "egi<Left><Left><Left><Left>"

vim.keymap.set("n", "<leader>ar", ":'{,'}s:\\V\\<<c-r><c-w>\\>::" .. suffix, { desc = "Replace word in par" })
vim.keymap.set("n", "<leader>aR", ":%s:\\V\\<<c-r><c-w>\\>::" .. suffix, { desc = "Replace word in file" })

vim.keymap.set("x", "<leader>ar", "y:'{,'}s:\\V<c-r>\"::" .. suffix, { desc = "Replace sel. in par" })
vim.keymap.set("x", "<leader>aR", "y:%s:\\V<c-r>\"::" .. suffix, { desc = "Replace sel. in file" })

vim.keymap.set("n", "<leader>aw", ":%s:\\s\\+$::<CR>", { desc = "Remove trailing ␣" })
vim.keymap.set("x", "<leader>aw", ":s:\\s\\+$::<CR>", { desc = "Remove trailing ␣" })

vim.keymap.set("n", '<leader>a"', 'mz:%v:": s:\':":egi<CR>`zzz', { desc = "Quote to DQuote" })
vim.keymap.set("n", "<leader>a'", "mz:%v:': s:\":':egi<CR>`zzz", { desc = "DQuote to Quote" })

vim.keymap.set("n", "<leader>a<Tab>", ":setlocal noexpandtab<CR>:retab!<CR>", { desc = "Spaces to Tabs" })
vim.keymap.set("n", "<leader>a ", ":setlocal expandtab<CR>:retab!<CR>", { desc = "Tabs to Spaces" })

vim.keymap.set("n", "<leader>m", function() vim.cmd("make") end, { desc = "Make" })
