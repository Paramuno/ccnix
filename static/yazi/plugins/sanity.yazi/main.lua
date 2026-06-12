-- local M = {}
-- function M:peek(job)
-- 	ya.err("SANITY peek mime=" .. tostring(job.mime))
-- 	ya.preview_widget(job, ui.Text("PLUGIN LOADED " .. tostring(job.mime)):area(job.area))
-- end
-- function M:seek() end
-- return M

local M = {}

local function in_ssh()
	return os.getenv("SSH_CONNECTION") or os.getenv("SSH_CLIENT") or os.getenv("SSH_TTY")
end

function M:peek(job)
	-- ALWAYS show a banner, regardless of SSH state
	local lines = {
		"=== smart-preview ===",
		"mime: " .. tostring(job.mime),
		"ssh: " .. tostring(in_ssh()),
		"area: " .. job.area.w .. "x" .. job.area.h,
		"file: " .. tostring(job.file.url),
	}

	local path = job.file.url
	if job.mime == "application/pdf" then
		local cache = ya.file_cache(job)
		if cache and not fs.cha(cache) then
			require("pdf"):preload(job)
		end
		path = cache
		table.insert(lines, "pdf cache: " .. tostring(path))
	end

	local child, err = Command("chafa")
		:args({
			"-f",
			"symbols",
			"--polite=on",
			"--passthrough=none",
			"--animate=off",
			"--view-size",
			string.format("%dx%d", job.area.w, job.area.h),
			"--scale",
			"max",
			tostring(path),
		})
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:spawn()

	if not child then
		table.insert(lines, "SPAWN FAILED: " .. tostring(err))
		return ya.preview_widget(job, ui.Text(table.concat(lines, "\n")):area(job.area))
	end

	local out = child:read_to_string()
	table.insert(lines, "stdout bytes: " .. #out)
	table.insert(lines, "first 60 chars: " .. string.sub(out, 1, 60))

	ya.preview_widget(job, ui.Text(table.concat(lines, "\n")):area(job.area))
end

function M:seek() end
function M:preload(job)
	if job.mime == "application/pdf" then
		return require("pdf"):preload(job)
	end
end

return M
