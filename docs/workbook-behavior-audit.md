# Workbook behavior audit

The Division 2 workbook is the balance source for the GT catalog. The
Specializations and Skill List tabs provide behavior text and numeric tracks.
Use outside evidence to clarify a missing or ambiguous rule, and record the
source beside the rule.

| Workbook evidence | Smalltalk coverage | Open source questions |
| --- | --- | --- |
| Specializations G16:H16, K16:L16, G36:H36, K35:L35, G55:H55, K55:L55 | Grenade profiles resolve statuses against eligible targets and known areas. Fragmentation reports damage and bleed. Cluster reports secondary detonations. | The workbook supplies no damage magnitudes, status durations, cluster count, or numeric radius for these entries. The dated Riot Foam radius below fills one gap. |
| Specializations G12:H12, K12:L12, G32:H32, K31:L31, G51:H51, K51:L51 | Tactician, Mender, Artificer, Banshee, Artillery and Striker have targeting and effect profiles. Known effect parameters come from the variant's effective tier stats, including selected upgrades. Geometry remains an input to the rules. | Striker's tier-zero 5% per enemy is usable. Skill List E277:K277 uses an unexplained Buff Strength scale, so its higher-tier bonus remains unresolved. |
| Specializations G13:H14, K13:L14, G33:H34 | Gadget upgrade conflicts remain visible in the catalog. | Carbon Fiber Frame, Magnetic Disc, and Liquid Cooling need evidence that reconciles their prose and numeric annotations. |
| Skill List L49, L65, L69, L80, L257, L261, L266, L271, L277 | All nine named overcharge entries evaluate only during overcharge. Immunizing Serum reports 10 seconds of immunity on trap contact. Weakness Exploit grants 15% amplification against pulsed targets to the agent and allies. Shield Wall applies invulnerability to the shield. | Cross-source effect stacking remains unspecified. |
| Skill List M15:M277 and Attribute Info B69:C71 | All 43 gadget entries calculate a 1% contribution per expertise grade. Forty link to a stat track. Damage uses the documented additive operation, with Achilles tagged as an amplifier. | Achilles has no numeric damage track. Artificer's Tech Efficiency and Striker's Regeneration lack a unique track mapping. Non-damage stacking, a global cap, and weapon and armor per-grade rates remain unspecified. |
| Attribute Info E2:F9 and Weapons P2:R8 | Ordinary launch weapons resolve their documented class attribute and innate headshot reference separately. Generation accepts and retains a supplied secondary roll when its standard cap is documented. | Rifle's standard Critical Hit Damage disagrees across tabs. Rifle and marksman rifle prototype caps are ambiguous. Roll minima, distributions, and variant-specific named or exotic overrides require separate evidence. Existing spawn calls can omit the secondary roll. |

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
