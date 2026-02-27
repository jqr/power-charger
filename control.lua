-- Power Charger: charges armor batteries from the electric network

local SEARCH_RADIUS = 18    -- tiles, covers largest pole supply area (substation)
local CHARGE_INTERVAL = 30  -- ticks between charge checks (~2x per second)
local ARC_INTERVAL = 5      -- ticks between arc redraws
local PLAYER_CHEST_Y = -1.2

-- Approximate visual height offsets for pole types (negative = up)
local POLE_HEIGHT = {
  ["small-electric-pole"]  = -2.0,
  ["medium-electric-pole"] = -2.8,
  ["big-electric-pole"]    = -3.0,
  ["substation"]           = -2.5,
}
local DEFAULT_POLE_HEIGHT = -2.5

local function init_storage()
  storage.shadows = storage.shadows or {}       -- [player_index][battery_name] = entity
  storage.player_surfaces = storage.player_surfaces or {} -- [player_index] = surface_index
end

local function destroy_shadows(player_index)
  local shadows = storage.shadows[player_index]
  if shadows then
    for _, entity in pairs(shadows) do
      if entity.valid then entity.destroy() end
    end
  end
  storage.shadows[player_index] = nil
  storage.player_surfaces[player_index] = nil
end

local function is_within_supply_area(player_pos, pole)
  local ok, supply = pcall(pole.prototype.get_supply_area_distance)
  if not ok or not supply then return false end
  local pole_pos = pole.position
  local dx = math.abs(player_pos.x - pole_pos.x)
  local dy = math.abs(player_pos.y - pole_pos.y)
  return dx <= supply and dy <= supply
end

local function find_powered_pole(player)
  local poles = player.surface.find_entities_filtered{
    position = player.position,
    radius = SEARCH_RADIUS,
    type = "electric-pole",
  }
  for _, pole in pairs(poles) do
    if is_within_supply_area(player.position, pole) then
      return pole
    end
  end
  return nil
end

local function get_battery_grid(player)
  if not player.character then return nil end
  local armor_inv = player.get_inventory(defines.inventory.character_armor)
  if not armor_inv or armor_inv.is_empty() then return nil end
  local armor = armor_inv[1]
  if not armor or not armor.valid_for_read then return nil end
  return armor.grid
end

-- Group batteries by equipment name, return deficit per type
local function get_battery_deficits(grid)
  local deficits = {} -- [equipment_name] = { space = total_space, batteries = { eq, ... } }
  for _, eq in pairs(grid.equipment) do
    if eq.type == "battery-equipment" then
      local space = eq.max_energy - eq.energy
      if space > 0 then
        local name = eq.name
        if not deficits[name] then
          deficits[name] = { space = 0, batteries = {} }
        end
        deficits[name].space = deficits[name].space + space
        table.insert(deficits[name].batteries, eq)
      end
    end
  end
  return deficits
end

local function get_pole_height(pole)
  return POLE_HEIGHT[pole.name] or DEFAULT_POLE_HEIGHT
end

local function draw_charge_arc(player, pole)
  local pole_pos = pole.position
  local player_pos = player.position
  local dx = player_pos.x - pole_pos.x
  local dy = player_pos.y - pole_pos.y

  local pole_top_y = get_pole_height(pole)
  local pole_ref = {pole_pos.x, pole_pos.y + pole_top_y}

  for arc = 1, 4 do
    local segments = 4 + math.random(3)
    local prev = pole_ref
    for seg = 1, segments - 1 do
      local t = seg / segments
      local jitter = (1 - math.abs(t - 0.5) * 2) * 1.5
      local ox = (math.random() - 0.5) * jitter
      local oy = (math.random() - 0.5) * jitter
      -- Interpolate height offset from pole top to player chest
      local height_offset = pole_top_y * (1 - t) + PLAYER_CHEST_Y * t
      local offset_x = -dx * (1 - t) + ox
      local offset_y = -dy * (1 - t) + height_offset + oy
      local next_ref = {entity = player.character, offset = {offset_x, offset_y}}

      rendering.draw_line{
        color = {r = 0.4, g = 0.6, b = 1, a = 0.6 + math.random() * 0.4},
        width = 2 + math.random() * 2,
        from = prev,
        to = next_ref,
        surface = player.surface,
        time_to_live = ARC_INTERVAL,
      }
      prev = next_ref
    end
    rendering.draw_line{
      color = {r = 0.5, g = 0.7, b = 1, a = 0.8},
      width = 2 + math.random() * 2,
      from = prev,
      to = {entity = player.character, offset = {0, PLAYER_CHEST_Y}},
      surface = player.surface,
      time_to_live = ARC_INTERVAL,
    }
  end

  rendering.draw_light{
    sprite = "utility/light_medium",
    target = {entity = player.character, offset = {0, PLAYER_CHEST_Y}},
    surface = player.surface,
    color = {r = 0.2, g = 0.4, b = 1},
    intensity = 0.5,
    scale = 4,
    time_to_live = ARC_INTERVAL,
  }
end

local function ensure_shadow(player, battery_name)
  local player_index = player.index
  storage.shadows[player_index] = storage.shadows[player_index] or {}
  local entity = storage.shadows[player_index][battery_name]
  if entity and entity.valid then
    entity.teleport(player.position)
    return entity
  end
  local shadow_name = "power-charger-" .. battery_name
  -- Fall back to generic if no dedicated shadow entity exists for this battery type
  if not prototypes.entity[shadow_name] then
    shadow_name = "power-charger-generic"
  end
  entity = player.surface.create_entity{
    name = shadow_name,
    position = player.position,
    force = player.force,
  }
  if entity then
    entity.destructible = false
    storage.shadows[player_index][battery_name] = entity
  end
  return entity
end

local function remove_shadow(player_index, battery_name)
  local shadows = storage.shadows[player_index]
  if not shadows then return end
  local entity = shadows[battery_name]
  if entity and entity.valid then
    entity.destroy()
  end
  shadows[battery_name] = nil
end

-- Check if player changed surface (e.g. went to another planet)
local function check_surface_change(player)
  local current = player.surface.index
  local prev = storage.player_surfaces[player.index]
  storage.player_surfaces[player.index] = current
  if prev and prev ~= current then
    -- Surface changed — destroy old shadows (they're on the wrong surface)
    destroy_shadows(player.index)
    -- Re-init the surface tracker since destroy_shadows clears it
    storage.player_surfaces[player.index] = current
    return true
  end
  return false
end

-- Visual-only: redraw arcs every ARC_INTERVAL ticks
local function on_arc_tick(event)
  for _, player in pairs(game.connected_players) do
    if not player.character then goto continue end
    -- Only draw arcs if we have active shadows (i.e. currently charging)
    local shadows = storage.shadows[player.index]
    if not shadows or not next(shadows) then goto continue end

    local pole = find_powered_pole(player)
    if pole then
      draw_charge_arc(player, pole)
    end

    ::continue::
  end
end

-- Charging logic: runs at the configured interval
local function on_charge_tick(event)
  for _, player in pairs(game.connected_players) do
    check_surface_change(player)

    local grid = get_battery_grid(player)
    if not grid or grid.battery_capacity <= 0 then
      destroy_shadows(player.index)
      goto continue
    end

    if grid.available_in_batteries >= grid.battery_capacity then
      destroy_shadows(player.index)
      goto continue
    end

    local pole = find_powered_pole(player)
    if not pole then
      destroy_shadows(player.index)
      goto continue
    end

    local deficits = get_battery_deficits(grid)

    local existing = storage.shadows[player.index]
    if existing then
      for bname, _ in pairs(existing) do
        if not deficits[bname] then
          remove_shadow(player.index, bname)
        end
      end
    end

    for battery_name, info in pairs(deficits) do
      local shadow = ensure_shadow(player, battery_name)
      if shadow then
        shadow.electric_buffer_size = info.space

        local received = shadow.energy
        if received > 0 then
          local remaining = received
          for _, eq in pairs(info.batteries) do
            local space = eq.max_energy - eq.energy
            local give = math.min(space, remaining)
            if give > 0 then
              eq.energy = eq.energy + give
              remaining = remaining - give
            end
            if remaining <= 0 then break end
          end
        end
        shadow.energy = 0
      end
    end

    ::continue::
  end
end

-- Lifecycle events

script.on_init(function()
  init_storage()
end)

script.on_nth_tick(ARC_INTERVAL, on_arc_tick)
script.on_nth_tick(CHARGE_INTERVAL, on_charge_tick)

script.on_configuration_changed(function()
  init_storage()
  for idx, shadows in pairs(storage.shadows) do
    for bname, entity in pairs(shadows) do
      if not entity.valid then
        shadows[bname] = nil
      end
    end
    if not next(shadows) then
      storage.shadows[idx] = nil
    end
  end
end)

script.on_event(defines.events.on_pre_player_removed, function(event)
  destroy_shadows(event.player_index)
end)

script.on_event(defines.events.on_player_changed_surface, function(event)
  destroy_shadows(event.player_index)
end)
