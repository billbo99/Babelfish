local Lib = require('lib')
local Gui = require('gui')
local Smarts = {}

Smarts.field_seperator = "█"
Smarts.row_seperator = "¶"

Smarts.on_translations_complete_event = script.generate_event_name()

local function make_queue()
    local queue = {}

    local types = {}
    if settings.global["babelfish-translate-entity"].value then table.insert(types, 'entity') end
    if settings.global["babelfish-translate-fluid"].value then table.insert(types, 'fluid') end
    if settings.global["babelfish-translate-item"].value then table.insert(types, 'item') end
    if settings.global["babelfish-translate-recipe"].value then table.insert(types, 'recipe') end
    if settings.global["babelfish-translate-technology"].value then table.insert(types, 'technology') end
    if settings.global["babelfish-translate-tile"].value then table.insert(types, 'tile') end
    if settings.global["babelfish-translate-virtual_signal"].value then table.insert(types, 'virtual_signal') end

    for _, typ in pairs(types) do
        for _, prototype in pairs(game[typ .. "_prototypes"]) do
            local key = typ .. "@" .. prototype.name
            queue[key] = { type = typ, prototype = prototype }
        end
    end
    global.max_translations = table_size(queue)
    return queue
end

local function get_job(player_name)
    for i, j in pairs(global.queue) do
        if not j.translator then
            j.translator = player_name
            return i, j
        end
    end
    return nil, nil
end

---@param player LuaPlayer
local function give_translation_work(player)
    if global.translators[player.name].busy then return end
    if global.translators[player.name].language ~= settings.global["babelfish-language"].value then
        global.translators[player.name].busy = true
        return
    end

    local total = table_size(global.queue)
    local pct = (global.max_translations - total) / global.max_translations
    Gui.show_progress(player, pct)

    local i = 1
    local action = { "", "Babelfish" }
    local jobs = {}
    while i < settings.global["babelfish-batch-size"].value do
        i = i + 1
        local index, job
        index, job = get_job(player.name)
        if index and job then
            table.insert(action, Smarts.row_seperator .. index .. Smarts.field_seperator)
            table.insert(action, job.prototype.localised_name)
            job.translation = "**unknown**"
            table.insert(jobs, { index = index, job = job })
        end
    end
    table.insert(action, Smarts.row_seperator)
    if table_size(action) > 3 then
        local rv = player.request_translation(action)
        if rv then
            global.translators[player.name].busy = true
            global.translators[player.name].tick = game.tick
            global.translators[player.name].jobs = jobs
        end
        return
    end

    global.translating = false
    if player.gui.left["Babelfish_progress"] then player.gui.left["Babelfish_progress"].destroy() end
    player.print("Babelfish .. Translations Complete")
    script.raise_event(Smarts.on_translations_complete_event, {})
end

---@param evt EventData.on_string_translated
function Smarts.on_string_translated(evt)
    if not evt.translated then return end
    local player = game.get_player(evt.player_index)
    if not player then return end

    if Lib.starts_with(evt.result, "Babelfish_player_language") then
        local parts = Lib.splitString(evt.result, "([^" .. Smarts.field_seperator .. "]+)")
        global.translators[player.name].language = parts[2]
        if global.translators[player.name].language == settings.global["babelfish-language"].value then
            player.print("Babelfish: Your language matches the map's default so we will request translation from you")
        end
        give_translation_work(player)
    elseif player and Lib.starts_with(evt.result, "Babelfish") then
        local rows = Lib.splitString(evt.result, "(.-)" .. Smarts.row_seperator)
        for _, row in pairs(rows) do
            if (not Lib.starts_with(row, "Babelfish")) then
                local parts = Lib.splitString(row, "([^" .. Smarts.field_seperator .. "]+)")
                local typ = Lib.splitString(parts[1], "([^@]+)")[1]
                local index = parts[1]
                local translation = parts[2]
                local name = global.queue[index].prototype.name
                if typ and name and index then
                    global.translations[typ] = global.translations[typ] or {}
                    global.translations[typ][name] = translation
                    global.queue[index] = nil
                    global.translators[player.name].busy = false
                end
            end
        end
        give_translation_work(player)
    end
end

function Smarts.reset_translations()
    global.translating = true
    global.translations = {}
    global.queue = make_queue()
    global.jobs = {}
    for _, player in pairs(game.connected_players) do
        global.translators[player.name] = { entity = player, busy = false }
        player.request_translation({ "", "Babelfish_player_language", Smarts.field_seperator, { "locale-identifier" } })
    end
end

function Smarts.init_globals()
    global.max_translations = 0
    global.translators = {}
    global.translations = global.translations or {}
    global.queue = global.queue or make_queue()
    global.jobs = global.jobs or {}
    global.translating = global.translating or true
end

function Smarts.on_init()
    Smarts.init_globals()
end

function Smarts.on_load()
end

function Smarts.on_configuration_changed(evt)
    Smarts.init_globals()
    if table_size(global.translations) == 0 then Smarts.reset_translations() end
end

---@param evt on_player_created|on_player_joined_game
function Smarts.on_player_connected(evt)
    local player = game.get_player(evt.player_index)
    if player and player.connected then
        global.translators[player.name] = { entity = player, busy = false, tick = game.tick }
        player.request_translation({ "", "Babelfish_player_language", Smarts.field_seperator, { "locale-identifier" } })
    end
end

---@param evt on_player_left_game
function Smarts.on_player_left(evt)
    local player = game.get_player(evt.player_index)
    if player then
        if global.translators[player.name] then
            for _, job in pairs(global.translators[player.name].jobs) do
                if job.index and global.queue[job.index] then
                    global.queue[job.index].translation = nil
                end
            end
        end
        global.translators[player.name] = nil
    end
end

---@param evt EventData.on_runtime_mod_setting_changed
function Smarts.on_runtime_mod_setting_changed(evt)
    if evt.setting_type == "runtime-global" and Lib.starts_with(evt.setting, "babelfish-translate") then
        Smarts.reset_translations()
    end
    if evt.setting_type == "runtime-global" and evt.setting == "babelfish-language" then
        local flag = false
        local lang = "en"
        for _, player_data in pairs(global.translators) do
            lang = player_data.language
            if player_data and player_data.language and settings.global["babelfish-language"].value == player_data.language then
                flag = true
            end
        end
        if not flag then
            game.print("No one on the server is using the language .. " .. settings.global["babelfish-language"].value)
            settings.global["babelfish-language"] = { value = lang }
        else
            Smarts.reset_translations()
        end
    end
end

---@param evt EventData.on_tick
function Smarts.on_nth_tick(evt)
    if not global.translating then return end

    local tick = evt.tick
    for _, player in pairs(game.connected_players) do
        local flag = false
        if global.translators[player.name] then
            local translator_tick = global.translators[player.name].tick or 0
            if translator_tick + 120 < tick then
                flag = true
            end
        else
            flag = true
        end
        if flag then
            global.translators[player.name] = { entity = player, busy = false, tick = game.tick }
            player.request_translation({ "", "Babelfish_player_language", Smarts.field_seperator, { "locale-identifier" } })
        end
    end
end

return Smarts
