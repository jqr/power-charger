#!/usr/bin/env bash
set -e

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"

# Package and install
"$SRC_DIR/package.sh"
"$SRC_DIR/install-local.sh"

echo ""
echo "=== Restart Factorio, then paste these console commands ==="
echo ""
echo "--- Setup: equip armor + all battery types, place poles + power ---"
echo '/c local p = game.player; local armor_inv = p.get_inventory(defines.inventory.character_armor); armor_inv.insert{name="power-armor-mk2", count=1}; local grid = armor_inv[1].grid; grid.put{name="battery-equipment"}; grid.put{name="battery-equipment"}; grid.put{name="battery-mk2-equipment"}; grid.put{name="battery-mk2-equipment"}; if prototypes.equipment["battery-mk3-equipment"] then grid.put{name="battery-mk3-equipment"}; grid.put{name="battery-mk3-equipment"} end; local s = p.surface; local o = p.position; local function place(name, x, y) s.create_entity{name=name, position={o.x+x, o.y+y}, force=p.force} end; place("substation", 5, 5); for row = 0, 2 do for col = 0, 2 do local x = -1 + col*3; local y = 2 + row*3; if not (x == 5 and y == 5) then place("solar-panel", x, y) end end end; for i = 0, 2 do place("accumulator", 8, 2 + i*3) end; place("small-electric-pole", -4, 0); place("medium-electric-pole", 0, -3); place("big-electric-pole", 14, 0); place("substation", 14, 8); game.print("Armor equipped with batteries. Power grid placed nearby.")'
echo ""
echo "--- Drain batteries to 0 ---"
echo '/c local grid = game.player.get_inventory(defines.inventory.character_armor)[1].grid; for _, eq in pairs(grid.equipment) do if eq.type == "battery-equipment" then eq.energy = 0 end end; game.print("Batteries drained to 0")'
echo ""
echo "--- Check charging status ---"
echo '/c local grid = game.player.get_inventory(defines.inventory.character_armor)[1].grid; for _, eq in pairs(grid.equipment) do if eq.type == "battery-equipment" then game.print(eq.name .. ": " .. string.format("%.1f", eq.energy / 1000000) .. " / " .. string.format("%.1f", eq.max_energy / 1000000) .. " MJ") end end; game.print("Total: " .. string.format("%.1f", grid.available_in_batteries / 1000000) .. " / " .. string.format("%.1f", grid.battery_capacity / 1000000) .. " MJ")'
