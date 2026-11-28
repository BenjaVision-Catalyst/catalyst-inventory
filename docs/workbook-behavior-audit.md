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
| Skill List L49, L65, L69, L80, L257, L261, L266, L271, L277 | All nine named overcharge entries evaluate only during overcharge. Immunizing Serum reports 10 seconds of immunity on trap contact. Weakness Exploit grants 15% amplification against pulsed targets to the agent and allies. Shield Wall applies invulnerability to the shield. | Cross-source effect stacking remains unspecified. |
| Skill List E28:K28, E38:K38, K61, E79:K79, K117, K125, K136, K143, K151 and Attribute Info E49,G49 | Nine cooldown and refill tracks now convert documented Skill Haste percentages to durations using base seconds divided by one plus haste. Skill Efficiency contributes equally to the six documented stats. Only the reported haste value doubles. | The calculation expresses the raw haste conversion. Per-gadget floors and stacking with other cooldown effects are unspecified. |
| Skill List M15:M277 and Attribute Info B69:C71 | All 43 gadget entries calculate a 1% contribution per expertise grade. Forty link to a stat track. Damage uses the documented additive operation, with Achilles tagged as an amplifier. The catalog also evaluates Grade upgrade eligibility using item-type Proficiency and account Expertise. | Achilles has no numeric damage track. Artificer's Tech Efficiency and Striker's Regeneration lack a unique track mapping. Non-damage stacking and weapon and armor per-grade rates remain unspecified. |
| Attribute Info E2:F9 and Weapons P2:R8 | Ordinary launch weapons and linked named and exotic weapons with class rules resolve their class attribute and innate headshot reference separately. Generation accepts supplied secondary rolls with a documented standard cap. TUY8S3.2 resolves the Rifle entries to 34% for High-End and Exotic, 51% for Prototype, and 80% innate Headshot Damage. The catalog preserves the original workbook entries. | The marksman rifle Prototype cap, roll minima and distributions remain unspecified. Existing spawn calls can omit secondary rolls. |
| Weapons Named + Exotics E59, E64, E76, E77, E97 and Weapons O8 | Generation retains Backup Boomstick's 17% shotgun damage core, The Mop's 10% armor on kill, The White Death and Oh Carol's 137% headshot damage, and TDI Kard Custom's active-weapon skill tier. First Sight uses the reported 85% innate headshot value as a separate built-in stat. | The First Sight reload modifier is unresolved. Backup Boomstick's equipment slot is unspecified. Other intrinsic adjustments remain in the source rows. |
| Weapons Named + Exotics F112:G112 and Attribute Info E10:E22 | Capacitor uses a Damage to Armor secondary core, capped at 12%, and excludes Damage to Armor from its basic minor choices. Exotics with a documented basic minor rule validate optional supplied ID/value pairs independently of cores and factory attachments. | The workbook supplies no weapon-specific prototype cap for Capacitor and no automatic minor-selection or roll distribution. |

Ubisoft's Episode 1 patch notes give the Riot Foam grenade a 3-metre radius.
The grenade definition records this dated source. [Episode 1 Patch Notes](https://www.ubisoft.com/en-gb/game/the-division/the-division-2/news-updates/3pepSvWluJRxzkWZeEWv56/episode-1-patch-notes)

Ubisoft's Technician notes explain that Artificer can repair friendly gadgets,
including held gadgets, and limits targets to the owner's gadgets while carried.
The workbook's Skill Repair and Skill Refresh tracks supply the measured
parameters. [Specialization #5: Technician](https://www.ubisoft.com/en-gb/game/the-division/the-division-2/news-updates/72QDo5hg6DSrOESF2fPJzU/specialization-5-technician)

Ubisoft's Expertise preview distinguishes item Grade from account Expertise
Level. Its weapon and armor rates were labeled provisional, so GT keeps the
workbook's additive operation rules and leaves those per-grade rates open.
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
