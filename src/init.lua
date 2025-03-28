local App = require("astal.gtk3.app")
local bar = require("bar.bar")
local astal = require("astal")
local src = require("util").src

local scss = src("style.scss")
local css = "/tmp/style.css"
astal.exec("sass " .. scss .. " " .. css)

App:start({
	instance_name = "msh",
	css = css,
    main = function()
		bar()
    end
})
