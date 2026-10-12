-- DAP Keymaps
-- All debug keybindings under <leader>d

local M = {}

local function goto_stopped()
	local dap = require("dap")
	local session = dap.session()
	if session then
		local frame = session.current_frame
		if frame and frame.source and frame.source.path then
			vim.cmd("edit " .. vim.fn.fnameescape(frame.source.path))
			vim.api.nvim_win_set_cursor(0, { frame.line, frame.column - 1 })
			vim.cmd("normal! zz")
		end
	end
end

function M.setup(dap)
	-- Stepping
	vim.keymap.set("n", "<leader>dn", dap.step_over, { desc = "Step Over (Next)" })
	vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "Step Into" })
	vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "Step Out" })
	vim.keymap.set("n", "<leader>dC", dap.continue, { desc = "Continue/Start" })
	vim.keymap.set("n", "<leader>dc", dap.run_to_cursor, { desc = "Run to Cursor" })

	-- Control
	vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
	vim.keymap.set("n", "<leader>dt", dap.terminate, { desc = "Terminate" })
	vim.keymap.set("n", "<leader>dg", goto_stopped, { desc = "Goto Stopped Location" })
	vim.keymap.set("n", "<leader>dP", function()
		dap.pause()
		vim.defer_fn(goto_stopped, 100)
	end, { desc = "Pause & Goto Stopped" })
	vim.keymap.set("n", "<leader>d[", dap.up, { desc = "Up Stack" })
	vim.keymap.set("n", "<leader>d]", dap.down, { desc = "Down Stack" })

	-- Inspect
	-- Centered, focused floats: q closes, closes when focus leaves the window
	local function float_opts(opts)
		return vim.tbl_deep_extend("keep", opts or {}, { enter = true, position = "center" })
	end
	vim.keymap.set("n", "<leader>du", function()
		require("dapui").toggle()
	end, { desc = "Toggle DAP UI" })
	vim.keymap.set("n", "<leader>ds", function()
		require("dapui").float_element(
			"scopes",
			float_opts({
				width = math.floor(vim.o.columns * 0.5),
				height = math.floor(vim.o.lines * 0.4),
			})
		)
	end, { desc = "Scopes Popup" })
	vim.keymap.set("n", "<leader>dh", function()
		-- eval() grabs the expression under cursor and populates the hover
		-- element before opening the float (float_element alone would be empty)
		require("dapui").eval(nil, float_opts()) -- fits content
	end, { desc = "Hover Popup" })

	-- Launch from .vscode/launch.json
	vim.keymap.set("n", "<leader>dpf", function()
		local launch_json = vim.fn.getcwd() .. "/.vscode/launch.json"
		if vim.fn.filereadable(launch_json) ~= 1 then
			vim.notify("No .vscode/launch.json found in " .. vim.fn.getcwd(), vim.log.levels.WARN)
			return
		end
		local vscode = require("dap.ext.vscode")
		dap.configurations.python = vim.tbl_filter(function(c)
			return not c._from_launch_json
		end, dap.configurations.python or {})
		vscode.load_launchjs(launch_json, { debugpy = { "python" } })
		for _, c in ipairs(dap.configurations.python or {}) do
			if not c._from_launch_json then
				c._from_launch_json = true
			end
		end
		dap.continue()
	end, { desc = "Debug from launch.json" })
end

return M
