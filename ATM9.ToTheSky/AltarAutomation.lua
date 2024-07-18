-- Load the JSON library
os.loadAPI("json")

-- Function to read the configuration file
local function readConfig(filename)
    local file = fs.open(filename, "r")
    if not file then
        error("Could not open configuration file")
    end
    local content = file.readAll()
    file.close()
    return json.decode(content)
end

-- Get the configuration file name from the command-line arguments
local args = { ... }
if #args < 1 then
    error("Usage: transfer_items <config_file>")
end
local configFile = args[1]

-- Load the configuration
local config = readConfig(configFile)
local inputChestName = config.inputChest
local outputAltarName = config.outputAltar
local requiredItems = config.requiredItems

-- Function to initialize peripherals
local function initializePeripheral(name)
    if peripheral.isPresent(name) then
        return peripheral.wrap(name)
    else
        error("Peripheral not found: " .. name)
    end
end

-- Initialize the peripherals
local inputChest = initializePeripheral(inputChestName)
local outputAltar = initializePeripheral(outputAltarName)

-- Function to check for required items in the input chest
local function checkForRequiredItems()
    local itemsFound = {}
    local items = inputChest.list()

    for _, requiredItem in ipairs(requiredItems) do
        itemsFound[requiredItem] = false
    end

    for slot, item in pairs(items) do
        if itemsFound[item.name] == false then
            itemsFound[item.name] = { slot = slot, count = item.count }
        end
    end

    for _, requiredItem in ipairs(requiredItems) do
        if itemsFound[requiredItem] == false then
            print("Missing item: " .. requiredItem)
            return nil
        end
    end

    return itemsFound
end

-- Function to transfer items from the input chest to the output altar
local function transferItems(itemsFound)
    for _, requiredItem in ipairs(requiredItems) do
        local itemInfo = itemsFound[requiredItem]
        if itemInfo and itemInfo.count > 0 then
            inputChest.pushItems(peripheral.getName(outputAltar), itemInfo.slot, 1)
            print("Transferred one " .. requiredItem .. " to the altar")
        end
    end
end

-- Main function
local function main()
    local itemsFound = checkForRequiredItems()
    if not itemsFound then
        print("Aborting: Not all required items are present in the chest.")
        return
    end
    transferItems(itemsFound)
    print("All required items have been transferred to the altar.")
end

-- Run the main function
main()
