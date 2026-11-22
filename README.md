# Catalyst Inventory

`BVC-Inventory-Core` owns portable inventory item definitions. A gear
definition is an item that can occupy a character equipment slot. Ordinary
items need only identity and display metadata. The core also owns the gear
modifier and outfit rules.

GT loads the `CatalystInventory` Metacello baseline with group `Core` from
`src`. A Rowan deployment loads `rowan/specs/CatalystInventoryCore.ston`.
Verify either installation by resolving `BVCInventoryComponent` in the
installed image or stone.

The opt-in GT groups `GearSimulation` and `GearSimulationTests` load the
simulator and its fixture respectively. See the [gear milestone](docs/gear-v1.md)
for the rules, reproduction commands, rankings and all 24 results.

The [Unreal companion plugin](https://github.com/BenjaVision-Catalyst/catalyst-inventory-ue-plugin)
owns the future ACF integration.

The [family milestone](docs/gear-family-v2.md) adds cumulative two-, three-,
and four-piece thresholds and a proposed launch roster of manufacturers.

The [playstyle comparison](docs/gear-playstyles-v3.md) evaluates standalone,
mixed and dedicated-set outfits for five roles.
