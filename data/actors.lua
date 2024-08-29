local actors = {}

local interacted_objects_blacklist = {}

local function is_shrine(skin_name)
    return skin_name:match("Shrine")
end

local function should_interact_with_shrine(shrine_position, player_position)
    local distance_threshold = 2.5
    return shrine_position:dist_to(player_position) < distance_threshold
end

-- New function to handle pathfinding to shrines
local function move_to_shrine(shrine_position, player_position)
    local move_threshold = 40 -- Default move threshold, can be adjusted
    local distance = shrine_position:dist_to(player_position)
    
    if distance > move_threshold then
        pathfinder.request_move(shrine_position)
        return false -- Not close enough to interact yet
    end
    
    return true -- Close enough to interact
end

function actors.update()
    local local_player = get_local_player()
    if not local_player then
        return
    end

    local player_pos = local_player:get_position()
    local objects = actors_manager.get_ally_actors()

    if #interacted_objects_blacklist > 200 then
        interacted_objects_blacklist = {}
    end

    for _, obj in ipairs(objects) do
        if obj then
            local obj_id = obj:get_id()
            if not interacted_objects_blacklist[obj_id] then
                local position = obj:get_position()
                local skin_name = obj:get_skin_name()

                if skin_name and is_shrine(skin_name) and not obj:can_not_interact() then
                    if move_to_shrine(position, player_pos) then
                        if should_interact_with_shrine(position, player_pos) then
                            interact_object(obj)
                            interacted_objects_blacklist[obj_id] = true
                            console.print("Interacted with Shrine: " .. skin_name)
                        end
                    else
                        console.print("Moving towards Shrine: " .. skin_name)
                    end
                end
            end
        end
    end
end

return actors