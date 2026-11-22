# Standalone gear and playstyle comparisons

`BVCGearPlaystyleCatalogue` defines 24 standalone pieces and four pieces
for each of five specialist sets. Standalone pieces are the majority of the
44-piece catalogue. They have individual stats and no set membership. Names,
values, slot assignments and icon reuse are provisional.

Load `GearSimulationTests` in GT. Evaluate `BVCGearPlaystyleComparison new run`
for the role winners, counts, scores and ties. The three suites are
`BVCGearSimulationTest`, `BVCGearFamilyTest` and `BVCGearPlaystyleTest`.

## Coverage and scoring

For each role, use all 24 standalone pieces and that role's four set pieces.
Each head, eyes, chest and feet slot has six standalone choices, one set
choice and an empty choice. The exact product is 4,096 outfits per role,
or 20,480 outfit–scenario cases. Per role this gives 2,401 standalone
outfits, 1,694 mixed outfits with one to three matching set pieces, and one
full set. The standalone group includes the empty baseline. All five groups
of scenarios use the same slot rules, including provisional head and eyes
compatibility. Cross-set combinations are outside this comparison.

Every scenario uses Shaki with a training rifle against a raider. Base inputs
are four landed 100-point shots, 10% critical chance at 2× critical damage,
an 80-point incoming packet, 1 control second, 10 healing points and a
10-second encounter. Critical chance is capped at 40%. Mobility, precision
and suppression start at 1 and are dimensionless tuning indices. They
represent repositioning, aiming and lane-pressure potential. Expected
damage is calculated from the fixed landed hits independently of these
indices. Their effects on movement, accuracy and AI require gameplay
validation.

The trigger stream has one pair per role: sprint/close hit, settle/aimed
hit, take cover/sustain a burst, interrupt/deploy a slow, or interrupt/heal.
Every category within a role sees the same pair. The trigger stream is
authored input and represents one successful opportunity. The family
milestone continues to test zero, one and two opportunities.

| Role | Minimums | Score |
| --- | --- | --- |
| Run and gun | Mobility 4 and damage 440 | Mobility / 6 + damage / 500 |
| Sniper | Precision 4 and damage 440 | Precision / 6 + damage / 500 |
| Overwatch | Suppression 4 and damage 440 | Suppression / 6 + damage / 500 |
| Crowd control | Control 3 s and damage 440 | Control / 5 + damage / 500 |
| Support | Control 3 s and healing 30 | Control / 3 + healing / 30 |

The highest qualifying score is reported in each category. When scores tie,
item ID order selects a representative and the result records the tie count.
Damage taken and variance are available as secondary trade-off measures.

## Results

| Role | Standalone winner | Mixed winner | Full set |
| --- | --- | --- | --- |
| Run and gun | Mobility 11, damage 480, takes 68 | Mobility 10, damage 504, takes 70 | Traverse. Mobility 9, damage 462, takes 57 |
| Sniper | Precision 11, damage 457.6, takes 58 | Precision 10, damage 457.6, takes 59 | Stillpoint. Precision 8, damage 518.4, takes 53 |
| Overwatch | Suppression 9, damage 440, takes 31 | Suppression 9, damage 457.6, takes 35 | Watchline. Suppression 9, damage 457.6, takes 42 |
| Crowd control | Control 4 s, damage 488, takes 70 | Control 6 s, damage 480, takes 48 | Containment. Control 7 s, damage 480, takes 48 |
| Support | Control 4 s, healing 33, damage 440, takes 67 | Control 4 s, healing 44, damage 520, takes 54 | Response. Control 4 s, healing 44, damage 560, takes 50 |

The mobile standalone outfit wins its role and trades armour for mobility.
Stillpoint holds the damage and defence advantage in the sniper comparison,
while standalone pieces lead the precision-weighted score. The Watchline
hybrid ties the full set on its role metrics and takes seven fewer damage
points. Containment gives a clear fourth-piece control payoff. A First Aid
Hood replaces the Response helmet and supplies the same healing as the
four-piece bonus. Full Response retains the damage and armour advantage.

[Winner IDs, qualified counts, scores, ties and all reported metrics](gear-playstyles-v3-results.csv)
