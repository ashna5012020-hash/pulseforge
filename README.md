# PulseForge

A small top-down survivor-like prototype built in Godot 4.7 — auto-attacking combat, escalating enemy waves, mid-run upgrades, and a persistent meta-progression loop (earn Cores each run, spend them on permanent upgrades between runs).

**⚠️ This is an early prototype, not a polished game.** It was built to demonstrate a core gameplay loop and a day-1 retention hook, not final art, balance, or content. Placeholder shapes/colors are used throughout instead of custom art or animation.

## Play it in your browser

👉 **[https://ashna5012020-hash.github.io/pulseforge/](https://ashna5012020-hash.github.io/pulseforge/)**

No install required — runs directly in the browser (Chrome/Edge/Brave recommended).

## Controls

- **WASD** or **Arrow Keys** — move
- Combat is fully automatic (nearest-enemy targeting)

## What's implemented

- Core loop: move, auto-shoot nearest enemy, survive escalating enemy waves, level up mid-run via random upgrade choices
- Enemy variety: Normal, Fast, Tank, Boss types with distinct stats/behavior
- Orbiting blade weapon (unlockable)
- XP orbs, screen shake, hit-flash feedback
- Meta-progression: Cores earned per run, spent on permanent upgrades (Max HP, Damage, Speed, Fire Rate, unlocking Blades) via a shop screen shown before each run
- Persistent save data (`user://save.json`) so progress carries across sessions

## What's NOT implemented / known limitations

- No custom art — all visuals are placeholder blocks/shapes with color-coded modulation
- No sound/music
- Limited enemy/weapon variety compared to genre leaders (Vampire Survivors, Survivor.io)
- No difficulty tuning pass — balance is rough
- No mobile/touch input support (keyboard only)
- Weapon pickups spawn but the system is minimal (4 pickup types, no rarity/variety)

## Tech

- Engine: Godot 4.7.1
- Language: GDScript
- Exported to HTML5/WebAssembly, hosted via GitHub Pages

## Project structure

```
scenes/     - .tscn scene files (Main, Player, Enemy, Orb, Projectile, UI, MetaMenu)
scripts/    - .gd scripts for all gameplay systems
web_build/  - exported HTML5/WASM build (playable via GitHub Pages)
```
