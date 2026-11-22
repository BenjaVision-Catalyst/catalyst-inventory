# Catalyst Inventory

The initial portable Smalltalk package is `BVC-Inventory-Core`. Its component
class serves as a load check for the initial distribution. Inventory behavior,
the gear simulator, and a possible Runtime service are future milestones.

GT loads the `CatalystInventory` Metacello baseline with group `Core` from
`src`. A Rowan deployment loads `rowan/specs/CatalystInventoryCore.ston`.
Verify either installation by resolving `BVCInventoryComponent` in the
installed image or stone.

The [Unreal companion plugin](https://github.com/BenjaVision-Catalyst/catalyst-inventory-ue-plugin)
owns the future ACF integration.
