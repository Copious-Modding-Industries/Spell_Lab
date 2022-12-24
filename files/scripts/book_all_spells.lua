-- Only if inventory is open
if GameIsInventoryOpen() then

    -- Gui Setup
    Gui = Gui or GuiCreate()
    GuiStartFrame(Gui)
    GuiIdPushString(Gui, "Spell_Lab_Spawner")

    -- Gui Data
    local x, y = 20, 50
    local columns = 24
    local padding = 20
    local id = 1
    local function NewId()
        id = id + 1
        return id
    end

    local function GuiConfig(opts, z)
        if opts ~= nil then
            for _, opt in ipairs(opts) do
                GuiOptionsAddForNextWidget(Gui, opt)
            end
        end
        if z ~= nil then
            GuiZSetForNextWidget(Gui, z)
        end
    end

    -- Actions Setup
    dofile_once( "data/scripts/gun/gun.lua" );
    if ActionsSorted == nil then
        ActionsSorted = actions
    end

    do -- Alphabetical sort
        GuiConfig({6}, 4.7)
        local lmb, rmb = GuiImageButton(Gui, NewId(), 520, 50, "", "data/ui_gfx/gun_actions/alpha.png") 
        if lmb then
            GamePlaySound("data/audio/Desktop/ui.bank", "ui/button_click", GameGetCameraPos())
            local function compare(a,b)
                return a.name < b.name
            end
            table.sort(ActionsSorted, compare)
        elseif rmb then
            GamePlaySound("data/audio/Desktop/ui.bank", "ui/button_click", GameGetCameraPos())
            local function compare(a,b)
                return a.name > b.name
            end
            table.sort(ActionsSorted, compare)
        end
        GuiTooltip(Gui, "Sort: Localized Alphabetical", "LMB: A-Z\nRMB: Z-A")
    end

    do -- Internal order sort
        GuiConfig({6}, 4.7)
        local lmb = GuiImageButton(Gui, NewId(), 520, 70, "", "data/ui_gfx/gun_actions/recharge.png")
        if lmb then
            GamePlaySound("data/audio/Desktop/ui.bank", "ui/button_click", GameGetCameraPos())
            ActionsSorted = actions
        end
        GuiTooltip(Gui, "Sort: Internal Order", "LMB: Internal\nRMB: n/a\nCURRENTLY NON-FUNCTIONAL")
    end

    do -- Alphabetical sort
        GuiConfig({6}, 4.7)
        local lmb, rmb = GuiImageButton(Gui, NewId(), 520, 90, "", "data/ui_gfx/gun_actions/teleport_projectile.png")
        if lmb then
            GamePlaySound("data/audio/Desktop/ui.bank", "ui/button_click", GameGetCameraPos())
            local function compare(a,b)
                if a.type ~= b.type then
                    return a.type > b.type
                else
                    return a.name < b.name
                end
            end
            table.sort(ActionsSorted, compare)
        elseif rmb then
            GamePlaySound("data/audio/Desktop/ui.bank", "ui/button_click", GameGetCameraPos())
            local function compare(a,b)
                if a.type ~= b.type then
                    return a.type < b.type
                else
                    return a.name < b.name
                end
            end
            table.sort(ActionsSorted, compare)
        end
        GuiTooltip(Gui, "Sort: Type", "LMB: Ascending\nRMB: Descending")
    end

    -- Spell Borders
    local border_by_type = {
        "data/ui_gfx/inventory/item_bg_projectile.png",
        "data/ui_gfx/inventory/item_bg_static_projectile.png",
        "data/ui_gfx/inventory/item_bg_modifier.png",
        "data/ui_gfx/inventory/item_bg_draw_many.png",
        "data/ui_gfx/inventory/item_bg_material.png",
        "data/ui_gfx/inventory/item_bg_other.png",
        "data/ui_gfx/inventory/item_bg_utility.png",
        "data/ui_gfx/inventory/item_bg_passive.png",
    }

    -- Scroll Container
    GuiZSetForNextWidget(Gui, 5.1)
    GuiBeginScrollContainer(Gui, NewId(), 20, 49, padding * columns, 275, false, 0, 0)
        -- Display Spells
        dofile_once( "data/scripts/gun/gun.lua" );
        local count = 0
        for index, action in ipairs(ActionsSorted) do
            local localized = ModSettingGet("Spell_Lab.localized_search")
            local searched = (localized and GameTextGetTranslatedOrNot(action.name) or action.id):upper():match((ModSettingGetNextValue("Spell_Lab.spellquery") or ""):upper())
            local progress = HasFlagPersistent("action_" .. (action.id):lower()) or ModSettingGet("Spell_Lab.ignore_progress")
            if searched and progress then

                -- Calculate Next Spell
                x = math.floor(count % columns)
                y = math.floor(count / columns)

                -- Slot Background
                GuiConfig({6}, 4.9)
                GuiImage(Gui, NewId(), x * padding, y * padding, "data/ui_gfx/inventory/full_inventory_box.png", 1, 1, 1)

                -- Spell Border
                GuiConfig({6}, 4.8)
                GuiImage(Gui, NewId(), x * padding, y * padding, border_by_type[action.type + 1], 1, 1, 1)

                -- Spell Sprite/Button
                GuiConfig({6, 22}, 4.7)
                local lmb, rmb = GuiImageButton(Gui, NewId(), x * padding + 2, y * padding + 2, "", action.sprite)
                GuiTooltip(Gui, action.name, action.description)

                -- Spawn Click Functionality
                if lmb then
                    GamePlaySound("data/audio/Desktop/ui.bank", "ui/button_click", GameGetCameraPos())
                    local ex, ey = EntityGetTransform(GetUpdatedEntityID())
                    CreateItemActionEntity(action.id, ex, ey)
                end

                -- Give Click Functionality
                if rmb then
                    GamePlaySound("data/audio/Desktop/ui.bank", "ui/button_click", GameGetCameraPos())
                    local spawner = GetUpdatedEntityID()
                    local ex, ey = EntityGetTransform(spawner)
                    local player = EntityGetRootEntity(spawner)
                    local full_inventory = nil;
                    local player_child_entities = EntityGetAllChildren( player );
                    if player_child_entities ~= nil then
                        for i,child_entity in ipairs( player_child_entities ) do
                            if EntityGetName( child_entity ) == "inventory_full" then
                                full_inventory = child_entity;
                                break;
                            end
                        end
                    end

                    -- set inventory contents
                    if full_inventory ~= nil then
                        if #(EntityGetAllChildren(full_inventory) or {}) < 16 then
                            local action_card = CreateItemActionEntity(action.id, ex, ey)
                            GamePickUpInventoryItem(player, action_card)
                            GamePrint( GameTextGetTranslatedOrNot(action.name) .. " added to your inventory" );
                        else
                            GamePrint("Not enough inventory space to spawn " .. GameTextGetTranslatedOrNot(action.name))
                        end
                    end
                end

                count = count + 1
            end
        end
    GuiEndScrollContainer(Gui)
    GuiZSetForNextWidget(Gui, 5)
    GuiImage(Gui, NewId(), 0, 0, dofile_once("mods/Spell_Lab/gnosis_sprite_override.lua"), 1, 1, 1)

    GuiColorSetForNextWidget(Gui, 1.0, 1.0, 1.0, 0.5)
    GuiText(Gui, 285, 330, "Search: ")
    local query = tostring(ModSettingGetNextValue("Spell_Lab.spellquery") or "")
    local query_new = GuiTextInput(Gui, NewId(), 300, 330, query, 200, 100, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 ")
    if query ~= query_new then
        ModSettingSetNextValue("Spell_Lab.spellquery", query_new, false)
    end

    GuiImageNinePiece(Gui, NewId(), 520, 165, 75, 155, 1)

    GuiIdPop(Gui)
end
