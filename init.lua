
function OnModPostInit() end
function OnPlayerSpawned( player_entity ) end
function OnPlayerDied( player_entity ) end
function OnWorldInitialized() end
function OnWorldPreUpdate() end
function OnWorldPostUpdate() end
function OnBiomeConfigLoaded() end
function OnMagicNumbersAndWorldSeedInitialized() end
function OnPausedChanged( is_paused, is_inventory_pause ) end
function OnModSettingsChanged() end
function OnPausePreUpdate() end

function OnModPreInit()

    do -- Patch reflection to save data for later
        local path = "data/scripts/gun/gun_collect_metadata.lua"
        local contents = ModTextFileGetContent(path)
        contents = contents:gsub([[-- send the action info to the game]], [[for index, value in ipairs(c) do
        print(("[Spell Lab] [Reflection] %s - %s"):format(tostring(index), tostring(value)))
        end]])
        ModTextFileSetContent(path, contents)
    end
end

function OnModInit()

    -- Function to add a component to an entity file
    function ModEntityFileAddComponent(file_path, comp)
        local file_contents = ModTextFileGetContent(file_path)
        local contents = file_contents:gsub("</Entity>$", function() return comp .. "</Entity>" end)
        ModTextFileSetContent(file_path, contents)
    end

    do  -- Add spell spawning functionality to Map of Gnosis item
        local path = "data/entities/items/books/book_all_spells.xml"
        ModTextFileGetContent("data/entities/items/books/book_all_spells.xml")
        ModEntityFileAddComponent(path, '<LuaComponent _tags="enabled_in_hand" execute_every_n_frame="1" script_source_file="mods/spell_lab/files/scripts/book_all_spells.lua" ></LuaComponent>')
        print("[Spell_Lab]: Added script to " .. path)
    end
end
