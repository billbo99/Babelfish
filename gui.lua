local mod_gui = require("mod-gui")

local Gui = {}

function Gui.show_progress(player, pct)
    if player.gui.left["Babelfish_progress"] then player.gui.left["Babelfish_progress"].destroy() end

    local gui_main = player.gui.left.add({ type = "frame", name = "Babelfish_progress", direction = "vertical" })
    gui_main.style.minimal_height = 10
    gui_main.style.minimal_width = 10
    gui_main.add({ type = "label", caption = string.format("Babelfish Progress .. %3.0f%%", pct * 100), style = "heading_1_label" })
    gui_main.add({ type = "progressbar", value = pct })
end

return Gui
