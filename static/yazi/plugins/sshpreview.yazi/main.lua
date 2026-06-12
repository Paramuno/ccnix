local M = {}

local function in_ssh()
	return os.getenv("SSH_CONNECTION") or os.getenv("SSH_CLIENT") or os.getenv("SSH_TTY")
end

local function delegate(job)
	if job.mime == "application/pdf" then
		return require("pdf")
	end
	return require("image")
end

local function chafa_render(job, path)
	local child, err = Command("chafa")
		:env("TERM", "xterm-256color")
		:arg({
			"-f",
			"symbols",
			"-c",
			"full",
			"--symbols",
			"block+border+space+stipple+half+inverted+sextant",
			"--bg",
			"black",
			"--polite",
			"on",
			"--probe",
			"off",
			"--clear=no",
			"-s",
			tostring(job.area.w) .. "x" .. tostring(job.area.h),
			tostring(path),
		})
		:stdin(Command.NULL)
		:stdout(Command.PIPED)
		:stderr(Command.NULL)
		:spawn()

	if not child then
		ya.err("chafa spawn failed: " .. tostring(err))
		return
	end

	local limit = job.area.h
	local i, lines = 0, ""

	repeat
		local next, event = child:read_line()
		if event == 1 then
			return ya.err(tostring(event))
		elseif event ~= 0 then
			break
		end
		i = i + 1
		if i > job.skip then
			lines = lines .. next
		end
	until i >= job.skip + limit

	child:start_kill()

	if job.skip > 0 and i < job.skip + limit then
		ya.manager_emit("peek", { tostring(math.max(0, i - limit)), only_if = job.file.url, upper_bound = true })
	else
		ya.preview_widget(job, ui.Text.parse(lines):area(job.area))
	end
end

function M:peek(job)
	if not in_ssh() then
		return delegate(job):peek(job)
	end

	if job.mime == "application/pdf" then
		local cache = ya.file_cache(job)
		if not cache then
			return
		end

		if not fs.cha(cache) then
			require("pdf"):preload(job)
			return
		end

		return chafa_render(job, cache)
	end

	return chafa_render(job, job.file.url)
end

function M:seek(job)
	if not in_ssh() then
		return delegate(job):seek(job)
	end

	local h = cx.active.current.hovered
	if h and h.url == job.file.url then
		local step = math.floor(job.units * job.area.h / 10)
		ya.manager_emit("peek", {
			tostring(math.max(0, cx.active.preview.skip + step)),
			only_if = job.file.url,
		})
	end
end

return M
