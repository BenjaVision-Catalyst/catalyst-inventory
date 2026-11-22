# Gear simulation milestone 1

`BVC-Inventory-Core` defines general inventory items and adds gear-specific
slots, modifiers and outfit constraints through `CIGearDefinition` and
`CIGearOutfit`. `BVC-Inventory-GearSimulation` evaluates catalogues and
scenarios. `BVC-Inventory-GearSimulation-Tests` owns the gear-v1 fixture and
its SUnit checks.

In GT, load the Metacello group `GearSimulationTests` from a checkout of this
repository. Evaluate `CIGearSimulationTest suite run` and
`CIGearSimulationFixture new run`. Each result includes its scenario ID,
item IDs, applied and inactive modifiers, and raw and effective stats.
Use `CIGearSimulator new comparisonsFor: row in: rows` for differences
against the empty outfit and the constituent one-piece outfits in that scenario.

## Fixture and rules

The four pieces use icon references from `UI/Gear/GearIcons`. The Mask icon
represents goggles in this fixture. Helmet and goggles compatibility is
provisional. Head, eyes and chest each allow zero or one piece. The two
vests compete for the chest slot.

| Piece | Slot | Additive modifiers while equipped |
| --- | --- | --- |
| Helmet | Head | +10 armour, +20 percentage points critical chance |
| Goggles | Eyes | +20 percentage points critical chance, +2 seconds control against raiders |
| Field vest | Chest | +25 armour, +15 damage per hit against raiders |
| Aid vest | Chest | +15 armour, +20 healing per encounter |

Shaki uses a training rifle in two 10-second encounters. Raider and drone
cases differ only by target class. Each has four landed hits at 100 base
damage, an independent critical roll per hit at 10% base chance and 2×
critical damage, an 80-point incoming packet, 1 second base control and
10 points base healing. Control and healing apply once per encounter.

Eligible additions stack before caps. Critical chance is stored as a
fraction and capped at 40%. Control is capped at the encounter length.
Stats have a zero floor. Armour subtracts from the incoming packet; damage
taken also has a zero floor. The expected damage and variance are analytic.

## Complete results

The slot product gives 2 × 2 × 3 = 12 outfits, including the empty outfit.
Each row represents two cases, with target-specific damage, variance and
control listed in raider/drone order. Damage taken and healing are identical
for both targets.

| Outfit | Expected damage R / D | Damage variance R / D | Damage taken | Control seconds R / D | Healing |
| --- | ---: | ---: | ---: | ---: | ---: |
| Empty | 440 / 440 | 3600 / 3600 | 80 | 1 / 1 | 10 |
| Helmet | 520 / 520 | 8400 / 8400 | 70 | 1 / 1 | 10 |
| Goggles | 520 / 520 | 8400 / 8400 | 80 | 3 / 1 | 10 |
| Goggles + helmet | 560 / 560 | 9600 / 9600 | 70 | 3 / 1 | 10 |
| Field vest | 506 / 440 | 4761 / 3600 | 55 | 1 / 1 | 10 |
| Field vest + helmet | 598 / 520 | 11109 / 8400 | 45 | 1 / 1 | 10 |
| Field vest + goggles | 598 / 520 | 11109 / 8400 | 55 | 3 / 1 | 10 |
| Field vest + goggles + helmet | 644 / 560 | 12696 / 9600 | 45 | 3 / 1 | 10 |
| Aid vest | 440 / 440 | 3600 / 3600 | 65 | 1 / 1 | 30 |
| Aid vest + helmet | 520 / 520 | 8400 / 8400 | 55 | 1 / 1 | 30 |
| Aid vest + goggles | 520 / 520 | 8400 / 8400 | 65 | 3 / 1 | 30 |
| Aid vest + goggles + helmet | 560 / 560 | 9600 / 9600 | 55 | 3 / 1 | 30 |

## Rankings and contribution checks

The damage goal requires 440 expected damage and ranks by damage / 440.
Field vest + goggles + helmet leads against raiders at 644, which is 204
above baseline and 138 above the field vest alone. Relative to the helmet
or goggles alone, it gains 124. The vest adds 25 armour and 15 damage per hit
against raiders, the helmet adds 10 armour, and the goggles add 2 seconds of
control against raiders. Both head pieces add 20 percentage points critical
chance. The two raider bonuses each contribute zero against drones.

The mixed score weights control / 3 and healing / 30 equally and requires
at least 3 seconds of control and 30 healing before scoring. Aid vest +
goggles ties with the same outfit plus helmet at 2 against raiders. No
drone outfit meets both minimums. Pass alternate goal tuples to
`rank:scenario:goals:` to change the ranking.

To reproduce the cap effect, compare goggles alone with goggles + helmet
against a drone. Adding the helmet raises raw critical chance from 30% to
50%, but the effective chance only reaches 40%. It adds 40 expected damage
instead of the 80 the uncapped calculation would give. The helmet still
adds 10 armour.
