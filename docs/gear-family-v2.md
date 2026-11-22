# Gear family milestone

Gear definitions in `BVC-Inventory-Core` can reference a family. A family
has a manufacturer and explicitly authored tiers. Ordinary inventory items
continue to use the base item definition. The simulator counts equipped
pieces by family ID and records threshold eligibility, applications, and
the raw contribution of each modifier. Eligible tiers stack before stat
caps.

Load `GearSimulationTests` in GT. Run `BVCGearFamilyTest suite run` and
`BVCGearSimulationTest suite run`. Evaluate `BVCGearFamilyFixture new run`
for the case results. The regression checks all five metrics in each of the
24 original cases. The new fixture runs 24 legal outfits against three
ordered event streams, for 72 unique cases. Per scenario, the counts at
zero through four matching pieces are 2, 7, 9, 5, and 1. See the
[full run](gear-family-v2-results.csv).

## Relay Works Response family

The helmet, goggles, boots, and aid vest count toward Response. The field
vest occupies the same chest slot as the aid vest and has no Response
membership. Helmet and goggles compatibility remains provisional.
The boots add five armour. Other item values and the raider encounter
inputs carry forward from gear-v1.

- Two pieces add 8 healing points to the next heal following an interrupt.
- Three pieces add 1 second to the encounter control metric while equipped.
- Four pieces add another 6 healing points to that same next heal.

Each triggered tier can be consumed once per encounter. An interrupt arms
it, the next heal consumes it, and repeated interrupts cannot bank charges.
The fixture holds baseline healing and control inputs constant. The event
stream controls family eligibility and application, and does not simulate
the base effects of the two heal events or the interrupts themselves.

| Matching pieces | Family healing, zero / one / two interrupts | Family control |
| ---: | ---: | ---: |
| 0 | 0 / 0 / 0 | 0 s |
| 1 | 0 / 0 / 0 | 0 s |
| 2 | 0 / 8 / 8 | 0 s |
| 3 | 0 / 8 / 8 | 1 s |
| 4 | 0 / 14 / 14 | 1 s |

The full Response outfit deals 560 expected damage, takes 50 damage,
provides 4 seconds of control, and heals 30 / 44 / 44. Swap its aid vest
for the field vest and the result is 644 expected damage, 40 damage taken,
4 seconds of control, and 10 / 18 / 18 healing. The latter wins damage
in all three scenarios. Full Response leads the original mixed control
and healing score with either triggered stream. In the zero-trigger
stream it ties the best three-piece Response outfits with 4 seconds of
control and 30 healing.

## Proposed manufacturer roster

The roster uses original names and effects. These are design proposals.
Relay Works Response is the implemented simulation fixture.

| Weapon company | Focus | Characteristic weapons |
| --- | --- | --- |
| Vektor Forge | Close-range mobility | Compact SMGs and short shotguns |
| Cairn Ballistics | Precision | Bolt-action and semi-auto marksman rifles |
| Breakwater Ordnance | Sustained pressure | Belt-fed weapons and heavy battle rifles |
| Aster Signal | Tactical utility | Compact carbines and low-recoil sidearms for ability-heavy builds |

| Gear company and family | Playstyle | Two pieces | Three pieces | Four pieces |
| --- | --- | --- | --- | --- |
| Crosswind Systems, Traverse | Run and gun | Faster weapon ready after a sprint | Faster reload while moving | A close-range hit after a sprint grants a short repositioning window |
| Meridian Range, Stillpoint | Sniper | Steadier aim | Faster recovery between aimed shots | A precision hit after settling grants a brief follow-up accuracy window |
| Bastion Fabrication, Watchline | Overwatch | Faster handling from cover | More suppression per sustained burst | Sustained fire on a lane marks a target for an ally's next hit |
| Sable Instruments, Containment | Crowd control | Faster control-tool recharge | Longer control on the primary target | Interrupting one enemy slows nearby enemies once per encounter |
| Relay Works, Response | Crowd control and support | Extra healing after an interrupt | Longer control | Stronger first follow-up heal |

The Division 2 reference is useful for comparing role identity and piece
thresholds. ThatGame uses authored effects and its own catalogue.
[Reference bonus finder](https://github.com/mariokoehler/division-gear-db)
