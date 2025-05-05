-- Required libraries
local wibox = require("wibox")
local gears = require("gears")
local awful = require("awful")

-- Battery widget
local battery_widget = wibox.widget({
	widget = wibox.widget.textbox,
	align = "center",
	valign = "center",
	font = "monospace 10",
})

-- Function to update battery text using `aicp`
local function update_battery()
	awful.spawn.easy_async_with_shell("aicp", function(stdout)
		battery_widget.text = stdout:gsub("^%s+", ""):gsub("%s+$", "") -- trim whitespace
	end)
end

-- Timer to refresh every 30 seconds
gears.timer({
	timeout = 30,
	autostart = true,
	call_now = true,
	callback = update_battery,
})

return battery_widget
