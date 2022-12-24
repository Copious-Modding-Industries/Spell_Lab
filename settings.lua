dofile("data/scripts/lib/mod_settings.lua") -- see this file for documentation on some of the features.
dofile("data/scripts/lib/utilities.lua")
local mod_id = "Spell_Lab"
mod_settings_version = 1

mod_settings =
{
    {
        id = "localized_search",
        ui_name = "Localized Search",
        ui_description = "Search for spells using localized names. If disabled, search will use spell IDs.",
        value_default = true,
        scope = MOD_SETTING_SCOPE_RUNTIME,
    },
    {
        id = "ignore_progress",
        ui_name = "Ignore Progress",
        ui_description = "Display all spells, regardless of current progress.",
        value_default = false,
        scope = MOD_SETTING_SCOPE_RUNTIME,
    },
}

function ModSettingsGuiCount()
    return mod_settings_gui_count(mod_id, mod_settings)
end

function ModSettingsGui( gui, in_main_menu )
	mod_settings_gui( mod_id, mod_settings, gui, in_main_menu )
end

function ModSettingsUpdate( init_scope )
    local old_version = mod_settings_get_version( mod_id ) -- This can be used to migrate some settings between mod versions.
    mod_settings_update( mod_id, mod_settings, init_scope )
end