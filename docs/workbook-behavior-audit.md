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
| Skill List L15:M284 | Overcharge and expertise source text is available on variants. | Audit which entries have evaluators and resolve their triggers and stacking before adding behavior. |
| Attribute Info and Weapons Q2:R8 | The catalog has attribute definitions and caps. Item generation validates values against the item's layout where one exists. | Audit how generation consumes class-specific attributes and how the workbook distinguishes attributes, fixed named overrides, and innate headshot damage. |

Ubisoft's Episode 1 patch notes give the Riot Foam grenade a 3-metre radius.
The grenade definition records this dated source. [Episode 1 Patch Notes](https://www.ubisoft.com/en-gb/game/the-division/the-division-2/news-updates/3pepSvWluJRxzkWZeEWv56/episode-1-patch-notes)

Ubisoft's Technician notes explain that Artificer can repair friendly gadgets,
including held gadgets, and limits targets to the owner's gadgets while carried.
The workbook's Skill Repair and Skill Refresh tracks supply the measured
parameters. [Specialization #5: Technician](https://www.ubisoft.com/en-gb/game/the-division/the-division-2/news-updates/72QDo5hg6DSrOESF2fPJzU/specialization-5-technician)
