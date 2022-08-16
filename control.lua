local Smarts = require("smarts")

script.on_init(Smarts.on_init)
script.on_load(Smarts.on_load)
script.on_nth_tick(120, Smarts.on_nth_tick)
script.on_configuration_changed(Smarts.on_configuration_changed)

script.on_event(defines.events.on_string_translated, Smarts.on_string_translated)
script.on_event(defines.events.on_player_created, Smarts.on_player_connected)
script.on_event(defines.events.on_player_joined_game, Smarts.on_player_connected)
script.on_event(defines.events.on_player_left_game, Smarts.on_player_left)
script.on_event(defines.events.on_runtime_mod_setting_changed, Smarts.on_runtime_mod_setting_changed)

remote.add_interface(
    "Babelfish", {
    get_on_translations_complete_event = function() return Smarts.on_translations_complete_event end,
    get_translations = function()
        return global.translations
    end,
})
