data:extend({
    {
        type = "string-setting",
        name = "babelfish-language",
        setting_type = "runtime-global",
        allow_blank = false,
        default_value = "en"
    },
    {
        type = "int-setting",
        name = "babelfish-batch-size",
        setting_type = "runtime-global",
        minimum_value = "1",
        maximum_value = "10",
        default_value = "10"
    },
    {
        type = "bool-setting",
        name = "babelfish-translate-entity",
        setting_type = "runtime-global",
        default_value = false
    },
    {
        type = "bool-setting",
        name = "babelfish-translate-fluid",
        setting_type = "runtime-global",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "babelfish-translate-item",
        setting_type = "runtime-global",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "babelfish-translate-recipe",
        setting_type = "runtime-global",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "babelfish-translate-technology",
        setting_type = "runtime-global",
        default_value = false
    },
    {
        type = "bool-setting",
        name = "babelfish-translate-tile",
        setting_type = "runtime-global",
        default_value = true
    },
    {
        type = "bool-setting",
        name = "babelfish-translate-virtual_signal",
        setting_type = "runtime-global",
        default_value = true
    },
})
