# Workbook behavior audit

The Division 2 workbook is the balance source for the GT catalog. The
Specializations and Skill List tabs provide behavior text and numeric tracks.
Use outside evidence to clarify a missing or ambiguous rule, and record the
source beside the rule.

| Workbook evidence | Smalltalk coverage | Open source questions |
| --- | --- | --- |
| Specializations G16:H16, K16:L16, G36:H36, K35:L35, G55:H55, K55:L55 | Grenade profiles resolve statuses against eligible targets and known areas. Fragmentation reports damage and bleed. Cluster reports secondary detonations. | The workbook supplies no damage magnitudes, status durations, cluster count, or numeric radius for these entries. The dated Riot Foam radius below fills one gap. |
| Specializations G12:H12, K12:L12, G32:H32, K31:L31, G51:H51, K51:L51 | Tactician, Mender, Artificer, Banshee, Artillery and Striker have targeting and effect profiles. Known effect parameters come from the variant's effective tier stats, including selected upgrades. Striker applies the 10-metre ally range from Skill List D279 when given an ally distance. | Striker's tier-zero bonus is 5% per enemy. Skill List E277:K277 leaves the conversion from Buff Strength to damage unspecified. The workbook records a Buff Angle of 45 in D278 and leaves its geometric interpretation open. |
| Specializations G13:H14, K13:L14, G33:H34 | Liquid Cooling adds 10% to Artificer Duration. Carbon Fiber Frame records Scan Range as the supported target. Magnetic Disc records the workbook’s Health target. The catalog preserves all three original numeric annotations. | Carbon Fiber Frame has conflicting range units. Magnetic Disc has conflicting descriptions of the Health change. Both applied bonuses remain unspecified. |
| Skill List L49, L65, L69, L80, L257, L261, L266, L271, L277 | All nine named overcharge entries evaluate only during overcharge. Immunizing Serum reports 10 seconds of immunity on trap contact. Weakness Exploit grants 15% amplification against pulsed targets to the agent and allies. Shield Wall applies invulnerability to the shield. | Stacking with other Overcharge sources remains unspecified. |
| Gear Named + Exotics F101:G101 | BTSU Datagloves grant 15% Hive cooldown haste per Gadget tier. On Hive detonation, Transference Overclock refreshes the wearer’s Gadget cooldowns and grants 15 seconds of Overcharge. At tier six, allies receive the same effects and each recipient has a 120-second lockout for this talent. | The Haste calculation for the Overcharge tier and its interaction with other sources remain unspecified. |
| Gear Named + Exotics F81:G81 | Combat Medic supplies +80% manual revive speed, 50% shorter Weakened duration, and +45% Hive efficiency. Both revive participants receive 50% damage resistance during the revive and for 5 seconds after a successful Hive revive or 10 seconds after a successful manual revive. Successful revives grant +1 Gadget tier for 5 seconds below tier 6 or 15 seconds of Overcharge at tier 6. | Success while already Overcharged and stacking with other sources remain unspecified. |
| Gear Talents D44:F44 and Gear Named + Exotics F23:G23 | Energize and Perfect Energize grant +1 Gadget tier for 15 seconds on armor-kit use below tier 6 and grant Overcharge at tier 6. The cooldown is 60 seconds for Energize and 30 seconds for Perfect Energize. Axel uses the same Perfect Energize rule. | The Overcharge duration, behavior while already Overcharged, and cooldown interactions between sources remain unspecified. |
| Gear Named + Exotics F79:G79 | Acosta’s Go-Bag refunds the thrown grenade and grants +1 Gadget tier for 15 seconds below tier 6 or 15 seconds of Overcharge at tier 6. Activations have a 60-second cooldown. The rule also exposes the five passive capacity and attribute bonuses. | Behavior when already Overcharged and stacking with other sources remain unspecified. |
| Gearsets E31:G31 | Measured Assembly unlocks Huddle at four pieces. Each ally in Hive or Smart Cover range contributes +1 Gadget tier. Four qualifying seconds at tier 6 grant 15 seconds of Overcharge, with a 40-second cooldown or 25 with Hivemind. Huddle intercepts incoming mortars and enemy Gadgets in range. The interception cooldown is 10 seconds or 1 with Smart Cooperation. | The catalog records the reported 20% faster interception cooldown per nearby ally. Its stacking formula, cooldown floor, and interactions with other Overcharge sources remain unspecified. |
| Skill List E28:K28, E38:K38, K61, E79:K79, K117, K125, K136, K143, K151 and Attribute Info E49,G49 | Nine cooldown and refill tracks now convert documented Skill Haste percentages to durations using base seconds divided by one plus haste. Skill Efficiency contributes equally to the six documented stats. For a raw cooldown, its actual haste is added to ordinary Skill Haste before dividing the base by one plus their sum. Only the reported Efficiency-derived haste doubles. | Per-Gadget cooldown floors and interactions with separate cooldown effects remain unspecified. |
| Skill List M15:M277 and Attribute Info B69:C71 | All 43 gadget entries calculate a 1% contribution per expertise grade. Forty-two link to a stat track. Ordinary damage contributions are additive. Achilles exposes a multiplier of 1 plus its Grade contribution for a hit on a marked zone. The catalog also evaluates Grade upgrade eligibility using item-type Proficiency and account Expertise. | Achilles has no standalone numeric damage track. Its underlying damage formula, mark thresholds, and interactions with other amplifiers remain unspecified. Non-damage Gadget stacking remains unspecified. |
| Skill List M151 and D156:K156 | Artificer Hive Tech Efficiency adds 1% of the base Buff Amount per Grade. Its 10% base yields 0.1 percentage point per Grade, added to tier-scaled Buff Amount. | Stacking with external buffs and formulas for other Hive tracks remain unspecified. |
| Skill List M277 and C283:K283 | Striker Shield’s 1% Regeneration per Grade is mapped to Active Regeneration. The catalog resolves the tier-only rate from a base of 39,817 and the 10% through 60% tier increases in D283:K283. Overcharge uses the same 60% increase as tier 6. The Grade contribution is exposed independently. | The sources do not establish how the Expertise contribution combines with Gadget tiers or mods. |
| Attribute Info B69:C69 and B71:C71 | Weapon and armor Expertise each contribute 1% per item Grade of the weapon’s base damage or the gear piece’s base armor. The weapon contribution is additive with ordinary weapon-damage bonuses. | Calculation and presentation of a full loadout total are separate from these per-item contributions. |
| Attribute Info E2:F9 and Weapons P2:R8 | Ordinary launch weapons and linked named and exotic weapons with class rules resolve their class attribute and innate headshot reference separately. Generation accepts supplied secondary rolls with a documented standard cap. TUY8S3.2 resolves the Rifle entries to 34% for High-End and Exotic, 51% for Prototype, and 80% innate Headshot Damage. The catalog preserves the original workbook entries. | The marksman rifle Prototype cap, roll minima and distributions remain unspecified. Existing spawn calls can omit secondary rolls. |
| Weapons Named + Exotics E59, E64, E76, E77, E97 and Weapons G8 and O8 | Backup Boomstick generates as a shotgun with a 17% shotgun damage core and the sidearm slot. Generation retains The Mop's 10% armor on kill, The White Death and Oh Carol's 137% headshot damage, and TDI Kard Custom's active-weapon skill tier. First Sight generation exposes 85% innate headshot damage and a 2.8-second empty reload as numeric built-in stats. | The Named + Exotics E4 reload-speed penalty is preserved as source text. Its calculation and interactions with other reload modifiers remain unspecified. Other intrinsic adjustments remain in the source rows. |
| Weapons M140, M142 and Weapons Named + Exotics E49 | Slingshot generates with a fixed total optimal range of 60 metres. Both Slingshot workbook entries support that total. | The named entry reports +45, while the standard Tactical UMP-45 lists 16 metres. The relationship between the two remains unspecified. |
| Weapons C192:O192 and Weapons Named + Exotics E146:G146 | The Sheriff keeps the workbook’s base stats and exposes Autentico’s built-in +35% Weapon Damage and +100% Accuracy. Its falloff policy explicitly specifies no damage drop-off. | The sources give no independent maximum hit distance or pellet spread formula. |
| Weapons E156 and E159 and Weapons Named + Exotics E52 | Rock n' Roll generates with Perfectly Extra as its fixed talent. Its 30-round catalog capacity already includes the 50% increase from the standard ACS-12's 20 rounds. | Magazine bonus stacking and weapon-swap ammo behavior remain unspecified. |
| Weapon Talents B54:D54 and Weapons Named + Exotics E42, E90 | Swap Chain generates with fixed Perfect Unwavering. Standard and Perfect Unwavering grant +300% and +400% handling respectively for five seconds after a swap to the weapon. Kills refresh the active buff. Swapping away starts a five-second lockout shared by Unwavering weapons. | The workbook entries supply no separate PvP magnitude or individual handling-stat formulas. |
| Weapons Named + Exotics F112:G112 and Attribute Info E10:E22 | Capacitor uses a Damage to Armor secondary core, capped at 12%, and excludes Damage to Armor from its basic minor choices. Exotics with a documented basic minor rule validate optional supplied ID/value pairs independently of cores and factory attachments. The Prototype conversion rule excludes Exotic items such as Capacitor. | Item-specific conversion eligibility within supported qualities, automatic minor selection, and roll distributions remain unspecified. |

Ubisoft's Episode 1 patch notes give the Riot Foam grenade a 3-metre radius.
The grenade definition records this dated source. [Episode 1 Patch Notes](https://www.ubisoft.com/en-gb/game/the-division/the-division-2/news-updates/3pepSvWluJRxzkWZeEWv56/episode-1-patch-notes)

Ubisoft's Technician notes explain that Artificer can repair friendly gadgets,
including held gadgets, and limits targets to the owner's gadgets while carried.
The workbook's Skill Repair and Skill Refresh tracks supply the measured
parameters. [Specialization #5: Technician](https://www.ubisoft.com/en-gb/game/the-division/the-division-2/news-updates/72QDo5hg6DSrOESF2fPJzU/specialization-5-technician)

Ubisoft's Expertise preview distinguishes item Grade from account Expertise
Level. It gave a provisional rate of 1% per Grade for weapon base damage
and gear base armor. Live player observations of weapon upgrades and armor
upgrades corroborate those rates and the distinction between base and total.
The catalog uses the workbook's additive operations.
[Weapon upgrade observation](https://www.reddit.com/r/thedivision_2/comments/1ru3x50/expertise_wtf/)
[Armor upgrade measurements](https://www.reddit.com/r/thedivision/comments/urjz2f/a_quick_guide_to_the_expertise_system_for_those/)
[Intelligence Annex on Expertise](https://www.ubisoft.com/en-us/game/the-division/the-division-2/news-updates/3Eqa62fOd4sDI1hqjSVdI2)

Title Update 15 confirms the Proficiency prerequisite. The Expertise annex
specifies Proficiency Rank 10 and limits an item's Grade to the account's
Expertise Level. The Pact sets the account cap at 30. The catalog evaluates
eligibility from supplied levels. Upgrade costs and progression point awards
remain unspecified.
[Title Update 15](https://www.ubisoft.com/en-gb/game/the-division/the-division-2/news-updates/21eVYKAAC5FS0WzeNSOpAE/title-update-15-patch-notes)
[The Pact](https://www.ubisoft.com/en-gb/game/the-division/the-division-2/news-updates/3DFEM2OnnbfRsDrQWXsbbO)

Ubisoft's Episode 1 notes define Skill Haste as a speed increase. A 100%
haste bonus halves a cooldown. The workbook distinguishes the displayed
Skill Efficiency haste from the value that actually changes cooldowns.
A player build calculation includes Memento's Efficiency-derived haste in the
same sum as ordinary haste. The catalog applies that sum before any separate
cooldown effects. [Player build calculation](https://www.reddit.com/r/thedivision/comments/onaytg/trying_to_increase_skill_haste_as_much_as_i_can/)
[Episode 1 Patch Notes](https://www.ubisoft.com/en-ca/game/the-division/the-division-2/news-updates/3pepSvWluJRxzkWZeEWv56/episode-1-patch-notes)

A published Artificer loadout corroborates the workbook’s +10% Duration
annotation for Liquid Cooling. [The Immortal Tech Tank](https://thedivisiondispatch.com/2026/08/01/%F0%9F%93%84-the-immortal-tech-tank/)

A player’s Carbon Fiber Frame tooltip reports +20 metres of Scan Range, while
the workbook’s numeric annotation gives +20%. The Magnetic Disc workbook prose
describes decreasing Mender Health, while the numeric annotation gives +15%.
Ubisoft’s 2019 notes list both upgrades under Skill Haste, documenting an older
version. [Carbon Fiber Frame tooltip report](https://www.reddit.com/r/thedivision/comments/gewh6w/remove_redundant_skill_mods/)
[Episode 1 Patch Notes](https://www.ubisoft.com/en-us/game/the-division/the-division-2/news-updates/3pepSvWluJRxzkWZeEWv56/episode-1-patch-notes)

Ubisoft confirms Striker Shield recipients are the owner and allies in range
behind the shield. The workbook supplies the 10-metre range. The caller supplies
rear-area eligibility and the number of enemies in front.
[Episode 3 State of the Game recap](https://news.ubisoft.com/en-us/article/5R7ryZdY9vXnJzr63Y75Ca/the-division-2-state-of-the-game-recap-coney-island-cleaners-and-a-new-specialization-in-episode-3)

Ubisoft's TUY8S3.2 gear breakdown (page 1) identifies the Weapons tab's 17%
Critical Hit Damage and 60% Headshot Damage as the previous Rifle values.
It confirms the Attribute Info tab's 34% and 51% Critical Hit Damage values
and the updated 80% base Headshot Damage. GT uses 34% in standard generation
and exposes the 51% Prototype ceiling in the catalog. The lower-quality
ceilings and the migration of existing rolls are outside this change.
[TUY8S3.2 Gear Updates](https://ubi.li/SlCDg)

Rise Up limits Prototype conversion to eligible High-End, Named, and Gear Set
items. An item must be Level 40 and at maximum Grade, and conversion costs one
Prototype Core. The catalog records the Grade 30 requirement corroborated by
Spearfall's test notes. For a supported quality, individual eligibility can
remain unknown. This rule covers conversion, while Prototype drops are a
separate acquisition route.
[Rise Up](https://www.ubisoft.com/en-us/game/the-division/the-division-2/news-updates/15OjYSjEhS2rUfiDINkRxD)
[Spearfall PTS Patch Notes](https://www.ubisoft.com/en-us/game/the-division/the-division-2/news-updates/1wrUJ1HzY6BF8zzO4AMhJ3/spearfall-pts-patch-notes)

The Combat Medic rule uses the workbook's revive and Overcharge durations.
Ubisoft's Crossroads update identifies the 80% speed increase as a manual
revive bonus. [Crossroads, Other Changes](https://www.ubisoft.com/en-us/game/the-division/the-division-2/news-updates/HP67k5N5kneQmSCVlVMmi/the-division-2-crossroads#other-changes)

Ubisoft's Axel entry corroborates Perfect Energize's armor-kit trigger and
tier-six Overcharge without specifying an Overcharge duration.
[Burden of Truth](https://www.ubisoft.com/en-us/game/the-division/the-division-2/news-updates/5V9sBiXBdAwdb9Migm4zZW/year-6-season-3-burden-of-truth)

Ubisoft's Crossroads notes corroborate the four-piece activation and the
Overcharge and interception timings for Measured Assembly.
[Crossroads](https://www.ubisoft.com/en-us/game/the-division/the-division-2/news-updates/HP67k5N5kneQmSCVlVMmi/the-division-2-crossroads)

A published gameplay walkthrough corroborates Acosta's 15-second Overcharge
at 04:12 and the 60-second cooldown.
[Acosta's Go-Bag gameplay walkthrough](https://www.dailymotion.com/video/xbkblva?start=252)

Published gameplay lists Backup Boomstick in the sidearm slot. GT maps that
placement to LeftHandWeapon and uses the workbook's shotgun class and core.
[Player loadout and gameplay](https://www.youtube.com/watch?v=tlMfbh83RTE)

Ubisoft's Mutiny notes confirm the percent unit for The Sheriff's +35 Weapon
Damage entry and identify all three Autentico properties as built into its
base stats. GT uses the workbook's listed damage directly before item rolls.
[Mutiny](https://www.ubisoft.com/en-us/game/the-division/the-division-2/news-updates/5fLsSWyLeFsYWiBxlByY4K/the-division-2-mutiny)

The Achilles rule uses the workbook's 1% per Grade and amplifier designation.
Ubisoft identifies damage as applying to Achilles-created zones, and player
range testing corroborates the separate Expertise multiplier on marked hits.
[TUY8S3.1](https://www.ubisoft.com/en-us/game/the-division/the-division-2/news-updates/3XY3PhLzRfbBPZ8cedURYO)
[Player range test](https://www.reddit.com/r/thedivision/comments/1bvr4yo)

Two player measurements corroborate the Artificer mapping. One reports a
20.5% Buff Amount at tier 1 and Grade 5, and the other measures a 0.2
percentage-point gain over two Grades. Both are consistent with adding
Expertise as a fraction of the workbook's 10% base.
[Tier 1 measurement](https://www.reddit.com/r/thedivision/comments/vl6kgj/expertise_skill_upgrades_updated/)
[Two-Grade comparison](https://www.reddit.com/r/the_division_2/comments/1ba6yhr/artificer_hive_expertise_levels_pointless/)

The workbook names Striker’s Expertise bonus Regeneration in M277 and lists
Active Regeneration in row 283. A player report identifies Active Regeneration
as affected on Striker. The catalog uses that mapping and keeps the modifier
operation unspecified.
[Player report](https://www.reddit.com/r/thedivision/comments/1i09y9e/does_expertise_upgrade_of_skill_cores_make_sense/)
