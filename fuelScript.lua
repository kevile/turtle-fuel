-- set up vars
local itemTable -- item details are returned as table w/ key:val (name, damage, count)
local itemTableMemory -- hold item's ID before attempting to consume it as fuel
local slot = 0 -- current inventory slot

-- fn to check if fuel is full
function areWeFull()
    if turtle.getFuelLevel() == turtle.getFuelLimit() then
        return true
    else
        return false
    end
end

-- fn to save prints and replay them at end of program
local printout = "\n\n----- Refueling Log-----\n"
function logPrint(_message)
    print(_message)
    printout = printout .. '\n' .. _message
end

logPrint('Starting full refuel program...')

logPrint('This turtle\'s capacity is ' .. turtle.getFuelLimit())
logPrint('The current/starting fuel level is ' .. turtle.getFuelLevel())



-- initial check - does turtle need fuel
if areWeFull() then
    logPrint('Turtle is already full.')
    return
end

-- main refuel process
for slot=1,16 do -- for each inv slot 1-16
    logPrint('Selecting slot ' .. slot)
    turtle.select(slot)

    itemTable = turtle.getItemDetail()
    itemTableMemory = itemTable
    if itemTable then --skip process if slot empty
        logPrint('Attempting to consume 1 unit of ' .. itemTable.name .. ':' .. itemTable.damage .. ' from slot #' .. slot .. '. Qty. ' .. itemTable.count .. ' in this slot.')
        if turtle.refuel(1) then -- try to drink 1 unit of fuel - returns true if works, false if not fuel or empty slot. no ability to test without consuming in this api http://computercraft.info/wiki/Turtle_(API)
            logPrint('success - it was fuel')
            if areWeFull() then -- check fuel level again
                logPrint('Turtle is filled up.')
                textutils.pagedPrint(printout) -- replay log to screen
                return
            end
            -- still not full
            logPrint('Fuel level is now ' .. turtle.getFuelLevel())
            itemTable = turtle.getItemDetail() -- update reading on current slot
            if itemTable then --check again if empty
                logPrint('Item(s) still remaining in this slot')
                if itemTable.name == itemTableMemory.name then -- if there's more of the SAME item (like a stack of fuel items - stop if different like an emptied lava bucket)
                    logPrint('Still the same type of fuel - continuing to fill')
                    while turtle.getItemCount() > 0 do
                        turtle.refuel(1)
                        logPrint('Fueling - ' .. turtle.getFuelLevel() .. "/" .. turtle.getFuelLimit())
                        areWeFull()
                    end
                end
            else --slot was empty after using fuel and rechecking
                logPrint('Used last piece of fuel in this slot')
            end
        else
            -- wasnt fuel or slot empty - move on
            logPrint('Slot ' .. slot .. 'had a non-fuel item.')
        end
    else --slot was empty
        logPrint('Slot was empty.')
    end
    -- done checking this slot
end

logPrint('Reached end of inventory and tank is still not full.')
logPrint('Final fuel value is ' .. turtle.getFuelLevel() .. '/' .. turtle.getFuelLimit())
textutils.pagedPrint(printout) -- replay log to screen
