-- Shadow entities that draw power from the electric network on behalf of the player.
-- One per battery type so they show up individually in power stats.

local shadow_base = {
  type = "electric-energy-interface",
  flags = {
    "not-on-map",
    "not-blueprintable",
    "not-deconstructable",
    "placeable-off-grid",
    "not-repairable",
    "not-selectable-in-game",
  },
  max_health = 1,
  collision_box = {{ -0.01, -0.01 }, { 0.01, 0.01 }},
  collision_mask = { layers = {} },
  selection_box = {{ -0.01, -0.01 }, { 0.01, 0.01 }},
  energy_source = {
    type = "electric",
    usage_priority = "primary-input",
    buffer_capacity = "20MJ",
  },
  energy_production = "0W",
  energy_usage = "0W",
  picture = {
    filename = "__core__/graphics/empty.png",
    width = 1,
    height = 1,
  },
}

-- Create a shadow entity for each known battery equipment type
local battery_types = {
  ["battery-equipment"] = "__base__/graphics/icons/battery-equipment.png",
  ["battery-mk2-equipment"] = "__base__/graphics/icons/battery-mk2-equipment.png",
}

for battery_name, icon_path in pairs(battery_types) do
  local shadow = table.deepcopy(shadow_base)
  shadow.name = "power-charger-" .. battery_name
  shadow.icon = icon_path
  data:extend({ shadow })
end

-- Generic fallback for modded battery types
local fallback = table.deepcopy(shadow_base)
fallback.name = "power-charger-generic"
fallback.icon = "__base__/graphics/icons/battery-equipment.png"
data:extend({ fallback })
