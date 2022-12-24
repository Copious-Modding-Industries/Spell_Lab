local path = "data/scripts/gun/gun_collect_metadata.lua"
local contents = ModTextFileGetContent(path)
contents = contents:gsub([[-- send the action info to the game]], [[for index, value in ipairs(c) do
print(("[Spell Lab] [Reflection] %s - %s"):format(tostring(index), tostring(value)))
end]])
ModTextFileSetContent(path, contents)