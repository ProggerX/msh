local astal = require("astal")
local Widget = require("astal.gtk3.widget")
local Anchor = require("astal.gtk3").Astal.WindowAnchor
local Hyprland = astal.require("AstalHyprland")
local Wp = astal.require("AstalWp")
local Battery = astal.require("AstalBattery")
-- local Tray = astal.require("AstalTray")
local Variable = astal.Variable
local GLib = astal.require("GLib")

local map = require("util").map
local bind = astal.bind

local function workspaces()
	local hypr = Hyprland.get_default()

	return Widget.Box({
		class_name = "Workspaces",
		spacing = 5,
		bind(hypr, "workspaces"):as(function(wss)
			table.sort(wss, function(a, b) return a.id < b.id end)

			return map(wss, function(ws)
				if not (ws.id >= -99 and ws.id <= -2) then
					return Widget.Button({
						class_name = bind(hypr, "focused-workspace"):as(
							function(fw) return fw == ws and "focused" or "" end
						),
						on_clicked = function() ws:focus() end,
						label = bind(ws, "id"):as(
							function(v)
								return type(v) == "number"
										and string.format("%.0f", v)
									or v
							end
						),
					})
				end
				return 0
			end)
		end),
	})
end

local function datetime(format)
	local time = Variable(""):poll(
		1000,
		function() return GLib.DateTime.new_now_local():format(format) end
	)

	return Widget.Button({
		class_name = "DateTime",
		on_destroy = function() time:drop() end,
		label = time(),
	})
end

local function wireplumber()
	local speaker = Wp.get_default().audio.default_speaker

	return Widget.Box({
		class_name = "AudioSlider",
		css = "min-width: 140px;",
		Widget.Button({
			Widget.Icon({
				icon = bind(speaker, "volume-icon")
			}),
			on_click = function() speaker.set_mute(speaker, not speaker.get_mute(speaker)) end
		}),
		Widget.Slider({
			hexpand = true,
			on_dragged = function(self) speaker.volume = self.value end,
			value = bind(speaker, "volume"),
		}),
	})
end

local function battery()
	local bat = Battery.get_default()

	return Widget.Button({Widget.Box({
		class_name = "Battery",
		visible = bind(bat, "is-present"),
		Widget.Icon({
			icon = bind(bat, "battery-icon-name"),
		}),
		Widget.Label({
			label = bind(bat, "percentage"):as(
				function(p) return tostring(math.floor(p * 100)) .. " %" end
			),
		}),
	})})
end

--[[ local function systray()
	local tray = Tray.get_default()

	return Widget.Box({
		class_name = "SysTray",
		spacing = 3,
		bind(tray, "items"):as(function(items)
			return map(items, function(item)
				return Widget.MenuButton({
					tooltip_markup = bind(item, "tooltip_markup"),
					use_popover = false,
					menu_model = bind(item, "menu-model"),
					action_group = bind(item, "action-group"):as(
						function(ag) return { "dbusmenu", ag } end
					),
					Widget.Icon({
						gicon = bind(item, "gicon"),
					}),
				})
			end)
		end),
	})
end
]]

local function get_current_playing()
    local handle = io.popen("mpc | grep -E '.+ +- +.+'")
	if handle == nil then error("ABOBA") end
    local output = handle:read("*a")
    handle:close()
    if output:sub(1,-2) == "" then return "" else return " " .. output:sub(1,-2) end
end

local function get_icon()
    local handle = io.popen("mpc | grep -E '\\[playing\\]'")
	if handle == nil then error("ABOBA") end
    local output = handle:read("*a")
    handle:close()
	if output ~= "" then return " " else return "" end
end

local function toggle_pause()
    io.popen("mpc toggle")
end

local function music()
	local f = Variable(""):poll(
		1000,
		function() return get_icon() .. get_current_playing() end
	)
	return Widget.Button({
		class_name = "Music",
		label = f(),
		on_click = toggle_pause
	})
end

return function()
    return Widget.Window({
		height = 35,
		class_name = "Bar Window",
        anchor = Anchor.TOP + Anchor.LEFT + Anchor.RIGHT,
        exclusivity = "EXCLUSIVE",
		Widget.CenterBox({
			expand = true,
			Widget.Box({
				margin_left = 5,
				workspaces()
			}),
			Widget.Box({
				music()
			}),
			Widget.Box({
				halign = 2,
				margin_right = 5,
				spacing = 15,
				wireplumber(),
				battery(),
				datetime("%H:%M :: %A, %e.%m.%y")
			}),
		})
    })
end
