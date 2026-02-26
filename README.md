# Power Charger

A Factorio 2.0 mod that charges your armor batteries from the electric network when you're standing near power poles. No need to wait for solar/fusion/etc if you're within your base!

Requires no new buildings, equipment, or research, your existing power grid just works.

## How it works

Stand within the supply area of any electric pole and your armor batteries will charge as fast as your power network can deliver. Walk away and it stops. That's it.

- Zero setup — no new items, buildings, or technologies to research
- Works with all pole types: small, medium, big, and substations
- Charges as fast as your network can deliver
- Power draw shows up in your electric network statistics, broken out by battery type (e.g. "Personal Battery MK2 (charging)")
- Blue lightning arcs from the pole to your character while charging
- Multiplayer compatible — each player charges independently

## Install

### From the mod portal

Search for "Power Charger" in-game or on [mods.factorio.com](https://mods.factorio.com).

### From source (for development)

Clone this repo, then run the install script:

```bash
# macOS / Linux
./install-local.sh

# Windows (PowerShell)
.\install-local.ps1
```

This symlinks the repo into your Factorio mods directory.

## Settings

| Setting | Default | Description |
|---|---|---|
| Update interval | 30 ticks | How often the mod checks and charges batteries. Lower = smoother, higher = less CPU. |

## Publishing a new release

1. Update `version` in `info.json`
2. Add an entry to `changelog.txt`
3. Run `./package.sh` to create the zip
4. Upload at [mods.factorio.com](https://mods.factorio.com) or via the [mod publish API](https://wiki.factorio.com/Mod_publish_API)

## License

MIT
