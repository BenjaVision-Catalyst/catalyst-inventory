# Catalyst Inventory

`BVC-Inventory-Core` owns portable inventory item definitions. A gear
definition is an item that can occupy a character equipment slot. Ordinary
items need only identity and display metadata. The core also owns the gear
modifier and outfit rules.

GT loads the `CatalystInventory` Metacello baseline with group `Core` from
`src`. A Rowan deployment loads `rowan/specs/CatalystInventoryCore.ston`.
Verify either installation by resolving `CIInventoryComponent` in the
installed image or stone.

The opt-in GT groups `GearSimulation` and `GearSimulationTests` load the
simulator and its fixture respectively. See the [gear milestone](docs/gear-v1.md)
for the rules, reproduction commands, rankings and all 24 results.

The [Unreal companion plugin](https://github.com/BenjaVision-Catalyst/catalyst-inventory-ue-plugin)
owns the future ACF integration.

The authenticated Inventory qualification gateway supports Create for Gear
Sets and Outfits. Operation 104 accepts one byte, 0 for Gear Sets or 1 for
Outfits, and derives the owner from the verified session. The Inventory service
assigns the next available name, captures the owner's equipped slots, and
returns the updated Magritte profile. Saved sets use the Runtime service's
in-memory store for the lifetime of that service.

Equip uses operation 105 with the saved-set UUID as a UTF-8 payload. The
service resolves the set within the authenticated player's Gear Sets and
Outfits, skips slots already correct, and preserves slots whose saved item is
missing or can no longer equip there. It also preserves an item currently in
one of those slots when the set requests it elsewhere. An in-memory Inventory
producer can provide `availableEquipmentSlotIdentifiers:` on an item row
when its eligible slots change. Older rows use the server-captured slot as
evidence that the item fits. The response refreshes the equipped items in
the profile.

Overwrite uses operation 106 with the same saved-set UUID payload as Equip.
The service captures the authenticated player's currently equipped slots for
the set's kind and replaces its snapshot in place. It keeps the set's ID,
name, and order and returns the updated profile.

The [family milestone](docs/gear-family-v2.md) adds cumulative two-, three-,
and four-piece thresholds and a proposed launch roster of manufacturers.

The [playstyle comparison](docs/gear-playstyles-v3.md) evaluates standalone,
mixed and dedicated-set outfits for five roles.
