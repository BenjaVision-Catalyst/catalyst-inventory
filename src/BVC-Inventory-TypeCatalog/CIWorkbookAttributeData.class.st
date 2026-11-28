Class {
	#name : 'CIWorkbookAttributeData',
	#superclass : 'Object',
	#category : 'BVC-Inventory-TypeCatalog',
	#package : 'BVC-Inventory-TypeCatalog'
}

{ #category : 'workbook data' }
CIWorkbookAttributeData class >> attributeCaps [
	^ #(#('weapon.damage' 'All weapons: / Weapon damage' weaponCore 'Core / Attribute' #(#(standardMaximum documented '15%' 0.15 fraction 'Attribute Info!E2') #(prototypeMaximum documented '0.225' 0.225 fraction 'Attribute Info!F2')) #()) #('weapon.class.assaultRifle' 'Assault Rifle: / Health Damage' weaponClassCore 'Fixed / Secondary / Core / Attributes' #(#(standardMaximum documented '21%' 0.21 fraction 'Attribute Info!E3') #(prototypeMaximum documented '0.315' 0.315 fraction 'Attribute Info!F3')) #()) #('weapon.class.lmg' 'LMG: / DMG to target out of cover' weaponClassCore 'Fixed / Secondary / Core / Attributes' #(#(standardMaximum documented '12%' 0.12 fraction 'Attribute Info!E4') #(prototypeMaximum documented '0.17' 0.17 fraction 'Attribute Info!F4')) #()) #('weapon.class.smg' 'SMG: / Critical Hit Chance' weaponClassCore 'Fixed / Secondary / Core / Attributes' #(#(standardMaximum documented '21%' 0.21 fraction 'Attribute Info!E5') #(prototypeMaximum documented '0.315' 0.315 fraction 'Attribute Info!F5')) #()) #('weapon.class.shotgun' 'Shotgun: / Damage to Armor' weaponClassCore 'Fixed / Secondary / Core / Attributes' #(#(standardMaximum documented '12%' 0.12 fraction 'Attribute Info!E6') #(prototypeMaximum documented '0.17' 0.17 fraction 'Attribute Info!F6')) #()) #('weapon.class.rifle' 'Rifle: / Critical Hit Damage' weaponClassCore 'Fixed / Secondary / Core / Attributes' #(#(standardMaximum documented '34' 0.34 fraction 'Attribute Info!E7; TUY8S3.2 Gear Updates, p. 1') #(prototypeMaximum documented '51%%' 0.51 fraction 'Attribute Info!F7; TUY8S3.2 Gear Updates, p. 1') #(weaponsTabMaximum documented '17%' 0.17 fraction 'Weapons!Q6')) #('Weapons!Q6 preserves the previous 17% maximum. TUY8S3.2 applies the 34% cap to High-End and Exotic rifles and the 51% cap to Prototype rifles.')) #('weapon.class.mmr' 'MMR: / Headshot Damage' weaponClassCore 'Fixed / Secondary / Core / Attributes' #(#(standardMaximum documented '111%' 1.11 fraction 'Attribute Info!E8') #(prototypeMaximum ambiguous '166.0' nil nil 'Attribute Info!F8')) #()) #('weapon.class.pistol' 'Pistol: / NA' weaponClassCore 'Fixed / Secondary / Core / Attributes' #(#(standardMaximum inapplicable 'N/A' nil nil 'Attribute Info!E9') #(prototypeMaximum inapplicable 'N/A' nil nil 'Attribute Info!F9')) #()) #('weapon.minor.damageToArmor' 'Damage to Armor' weaponMinor 'Minor / Attributes' #(#(standardMaximum documented '6%' 0.06 fraction 'Attribute Info!E10') #(prototypeMaximum documented '0.09' 0.09 fraction 'Attribute Info!F10')) #()) #('weapon.minor.criticalHitChance' 'Critical Hit Chance' weaponMinor 'Minor / Attributes' #(#(standardMaximum documented '9.5%' 0.095 fraction 'Attribute Info!E11') #(prototypeMaximum documented '0.145' 0.145 fraction 'Attribute Info!F11')) #()) #('weapon.minor.healthDamage' 'Health Damage' weaponMinor 'Minor / Attributes' #(#(standardMaximum documented '9.5%' 0.095 fraction 'Attribute Info!E12') #(prototypeMaximum documented '0.145' 0.145 fraction 'Attribute Info!F12')) #('Attribute Info!G12: (actually 10% in calc)')) #('weapon.minor.damageToTargetOutOfCover' 'DMG to target out of cover' weaponMinor 'Minor / Attributes' #(#(standardMaximum documented '10%' 0.1 fraction 'Attribute Info!E13') #(prototypeMaximum documented '0.15' 0.15 fraction 'Attribute Info!F13')) #()) #('weapon.minor.headshotDamage' 'Headshot Damage' weaponMinor 'Minor / Attributes' #(#(standardMaximum documented '10%' 0.1 fraction 'Attribute Info!E14') #(prototypeMaximum documented '0.15' 0.15 fraction 'Attribute Info!F14')) #()) #('weapon.minor.criticalHitDamage' 'Critical Hit Damage' weaponMinor 'Minor / Attributes' #(#(standardMaximum documented '10%' 0.1 fraction 'Attribute Info!E15') #(prototypeMaximum documented '0.15' 0.15 fraction 'Attribute Info!F15')) #()) #('weapon.minor.reloadSpeed' 'Reload Speed' weaponMinor 'Minor / Attributes' #(#(standardMaximum documented '12%' 0.12 fraction 'Attribute Info!E16') #(prototypeMaximum documented '0.18' 0.18 fraction 'Attribute Info!F16')) #()) #('weapon.minor.stability' 'Stability' weaponMinor 'Minor / Attributes' #(#(standardMaximum documented '12%' 0.12 fraction 'Attribute Info!E17') #(prototypeMaximum documented '0.18' 0.18 fraction 'Attribute Info!F17')) #()) #('weapon.minor.accuracy' 'Accuracy' weaponMinor 'Minor / Attributes' #(#(standardMaximum documented '12%' 0.12 fraction 'Attribute Info!E18') #(prototypeMaximum documented '0.18' 0.18 fraction 'Attribute Info!F18')) #()) #('weapon.minor.optimalRange' 'Optimal Range' weaponMinor 'Minor / Attributes' #(#(standardMaximum documented '24%' 0.24 fraction 'Attribute Info!E19') #(prototypeMaximum unspecified nil nil nil 'Attribute Info!F19')) #()) #('weapon.minor.magazineSize' 'Magazine Size' weaponMinor 'Minor / Attributes' #(#(standardMaximum documented '12.5%' 0.125 fraction 'Attribute Info!E20') #(prototypeMaximum documented '0.19' 0.19 fraction 'Attribute Info!F20')) #()) #('weapon.minor.rateOfFire' 'Rate of Fire' weaponMinor 'Minor / Attributes' #(#(standardMaximum documented '5%' 0.05 fraction 'Attribute Info!E21') #(prototypeMaximum documented '0.075' 0.075 fraction 'Attribute Info!F21')) #()) #('weapon.minor.swapSpeed' 'Swap Speed' weaponMinor 'Minor / Attributes' #(#(standardMaximum documented '15%' 0.15 fraction 'Attribute Info!E22') #(prototypeMaximum documented '0.225' 0.225 fraction 'Attribute Info!F22')) #()) #('gear.core.armor' 'Armor' gearCore 'Core / Attributes' #(#(standardMaximum documented '170,000' 170000 flat 'Attribute Info!E23') #(prototypeMaximum documented '255,001' 255001 flat 'Attribute Info!F23')) #()) #('gear.core.weaponDamage' 'Weapon Damage' gearCore 'Core / Attributes' #(#(standardMaximum documented '15%' 0.15 fraction 'Attribute Info!E24') #(prototypeMaximum documented '0.225' 0.225 fraction 'Attribute Info!F24')) #()) #('gear.core.skillTier' 'Skill Tier' gearCore 'Core / Attributes' #(#(standardMaximum documented '1' 1 skillTier 'Attribute Info!E25') #(prototypeMaximum documented '1.5' 1.5 skillTier 'Attribute Info!F25')) #()) #('gear.minor.weaponHandling' 'Weapon Handling' gearMinor 'Offensive / Minor / Attributes' #(#(standardMaximum documented '8%' 0.08 fraction 'Attribute Info!E26') #(prototypeMaximum documented '0.12' 0.12 fraction 'Attribute Info!F26')) #()) #('gear.minor.criticalHitChance' 'Critical Hit Chance' gearMinor 'Offensive / Minor / Attributes' #(#(standardMaximum documented '6%' 0.06 fraction 'Attribute Info!E27') #(prototypeMaximum documented '0.09' 0.09 fraction 'Attribute Info!F27')) #()) #('gear.minor.criticalHitDamage' 'Critical Hit Damage' gearMinor 'Offensive / Minor / Attributes' #(#(standardMaximum documented '12%' 0.12 fraction 'Attribute Info!E28') #(prototypeMaximum documented '0.18' 0.18 fraction 'Attribute Info!F28')) #()) #('gear.minor.headshotDamage' 'Headshot Damage' gearMinor 'Offensive / Minor / Attributes' #(#(standardMaximum documented '10%' 0.1 fraction 'Attribute Info!E29') #(prototypeMaximum documented '0.15' 0.15 fraction 'Attribute Info!F29')) #()) #('gear.minor.armorRegeneration' 'Armor Regeneration' gearMinor 'Defensive / Minor / Attributes' #(#(standardMaximum documented '4925/s' 4925 perSecond 'Attribute Info!E30') #(prototypeMaximum ambiguous '73.88' nil nil 'Attribute Info!F30')) #()) #('gear.minor.hazardProtection' 'Hazard Protection' gearMinor 'Defensive / Minor / Attributes' #(#(standardMaximum documented '10%' 0.1 fraction 'Attribute Info!E31') #(prototypeMaximum documented '0.15' 0.15 fraction 'Attribute Info!F31')) #()) #('gear.minor.health' 'Health' gearMinor 'Defensive / Minor / Attributes' #(#(standardMaximum documented '18,935' 18935 flat 'Attribute Info!E32') #(prototypeMaximum ambiguous '284.03' nil nil 'Attribute Info!F32')) #()) #('gear.minor.explosiveResistance' 'Explosive Resistance' gearMinor 'Defensive / Minor / Attributes' #(#(standardMaximum documented '10%' 0.1 fraction 'Attribute Info!E33') #(prototypeMaximum documented '0.15' 0.15 fraction 'Attribute Info!F33')) #()) #('gear.minor.skillHaste' 'Skill Haste' gearMinor 'Skill / Minor / Attributes' #(#(standardMaximum documented '12%' 0.12 fraction 'Attribute Info!E34') #(prototypeMaximum documented '0.17' 0.17 fraction 'Attribute Info!F34')) #()) #('gear.minor.skillDamage' 'Skill Damage' gearMinor 'Skill / Minor / Attributes' #(#(standardMaximum documented '10%' 0.1 fraction 'Attribute Info!E35') #(prototypeMaximum documented '0.15' 0.15 fraction 'Attribute Info!F35')) #()) #('gear.minor.repairSkills' 'Repair Skills' gearMinor 'Skill / Minor / Attributes' #(#(standardMaximum documented '20%' 0.2 fraction 'Attribute Info!E36') #(prototypeMaximum documented '0.3' 0.3 fraction 'Attribute Info!F36')) #()) #('gear.minor.statusEffects' 'Status Effects' gearMinor 'Skill / Minor / Attributes' #(#(standardMaximum documented '10%' 0.1 fraction 'Attribute Info!E37') #(prototypeMaximum documented '0.15' 0.15 fraction 'Attribute Info!F37')) #()) #('gearMod.criticalHitChance' 'Critlcal Hit Chance' gearMod 'Offensive' #(#(standardMaximum documented '6%' 0.06 fraction 'Attribute Info!E38') #(prototypeMaximum unspecified nil nil nil 'Attribute Info!F38')) #()) #('gearMod.criticalHitDamage' 'Critical Hit Damage' gearMod 'Offensive' #(#(standardMaximum documented '12%' 0.12 fraction 'Attribute Info!E39') #(prototypeMaximum unspecified nil nil nil 'Attribute Info!F39')) #()) #('gearMod.headshotDamage' 'Headshot Damage' gearMod 'Offensive' #(#(standardMaximum documented '10%' 0.1 fraction 'Attribute Info!E40') #(prototypeMaximum unspecified nil nil nil 'Attribute Info!F40')) #()) #('gearMod.protectionFromElites' 'Protection from Elites' gearMod 'Defensive' #(#(standardMaximum documented '0.13' 0.13 fraction 'Attribute Info!E41') #(prototypeMaximum unspecified nil nil nil 'Attribute Info!F41')) #()) #('gearMod.armorOnKill' 'Armour on Kill' gearMod 'Defensive' #(#(standardMaximum documented '18935.0' 18935 flat 'Attribute Info!E42') #(prototypeMaximum unspecified nil nil nil 'Attribute Info!F42')) #()) #('gearMod.statusEffectResistance' 'Status Effect Resistance' gearMod 'Defensive' #(#(standardMaximum documented '0.1' 0.1 fraction 'Attribute Info!E43') #(prototypeMaximum unspecified nil nil nil 'Attribute Info!F43')) #('Attribute Info!G43: Types: Fire, Bleed, Shock & Disrupt, Blind & Deaf, Disorient & Ensare')) #('gearMod.pulseResistance' 'Pulse Resistance' gearMod 'Defensive' #(#(standardMaximum documented '0.1' 0.1 fraction 'Attribute Info!E44') #(prototypeMaximum unspecified nil nil nil 'Attribute Info!F44')) #()) #('gearMod.incomingRepairs' 'Incoming Repairs' gearMod 'Defensive' #(#(standardMaximum documented '0.2' 0.2 fraction 'Attribute Info!E45') #(prototypeMaximum unspecified nil nil nil 'Attribute Info!F45')) #()) #('gearMod.skillHaste' 'Skill Haste' gearMod 'Skill' #(#(standardMaximum documented '12%' 0.12 fraction 'Attribute Info!E46') #(prototypeMaximum unspecified nil nil nil 'Attribute Info!F46')) #()) #('gearMod.skillDuration' 'Skill Duration' gearMod 'Skill' #(#(standardMaximum documented '10%' 0.1 fraction 'Attribute Info!E47') #(prototypeMaximum unspecified nil nil nil 'Attribute Info!F47')) #()) #('gearMod.repairSkills' 'Repair Skiills' gearMod 'Skill' #(#(standardMaximum documented '20%' 0.2 fraction 'Attribute Info!E48') #(prototypeMaximum unspecified nil nil nil 'Attribute Info!F48')) #()))
]

{ #category : 'registration' }
CIWorkbookAttributeData class >> linkWeaponClassGenerationRulesIn: catalog [
	| rules eligibleIds |
	rules := Dictionary new.
	#(#(assaultRifle 'assaultRifle' 'healthDamage' 'Health damage' 0.55 'Weapons!P2:R2') #(lmg 'lmg' 'damageToTargetsOutOfCover' 'Damage to targets out of cover' 0.65 'Weapons!P3:R3') #(smg 'smg' 'criticalHitChance' 'Critical hit chance' 0.50 'Weapons!P4:R4') #(shotgun 'shotgun' 'damageToArmor' 'Damage to armor' 0.45 'Weapons!P5:R5') #(rifle 'rifle' 'criticalHitDamage' 'Critical hit damage' 0.80 'TUY8S3.2 Gear Updates, p. 1; Weapons!P6:R6 preserves the previous 60%') #(marksmanRifle 'mmr' 'headshotDamage' 'Headshot damage' 0 'Weapons!P7:R7') #(pistol 'pistol' nil nil 1.0 'Weapons!P8:R8'))
		do: [ :row | 
			rules
				at: row first
				put: (CIWeaponClassGenerationRule
						weaponClass: row first
						attribute: (catalog attributeCatalogue
								definitionAt: 'weapon.class.' , row second)
						stat: row third
						label: row fourth
						innateHeadshotDamage: row fifth
						evidence: row sixth) ].
	eligibleIds := ((CIThatGameLaunchCatalog weaponSpecs
			select: [ :row | row third = row fourth ]) collect: #first) asSet.
	catalog weaponReferences
		do: [ :reference | 
			(reference kind ~= #statistics
				and: [ reference itemDefinitionIdentifier notNil
						and: [ reference itemDefinitionIdentifier ~= 'weapon.specialization.firestarter' ] ])
				ifTrue: [ eligibleIds add: reference itemDefinitionIdentifier ] ].
	catalog weaponReferences
		do: [ :reference | 
			(reference kind = #statistics
				and: [ eligibleIds includes: reference itemDefinitionIdentifier ])
				ifTrue: [ (catalog typeAt: reference itemDefinitionIdentifier)
						classGenerationRule: (rules at: reference weaponClass) ] ]
]

{ #category : 'registration' }
CIWorkbookAttributeData class >> registerExpertiseProgressionIn: catalogue [
	catalogue
		registerRule: (CIExpertiseProgressionRule
				id: 'expertise.progression'
				description: 'An item type at maximum Proficiency can advance individual item Grades up to the account Expertise Level.'
				parameters: {#maximumExpertiseLevel -> 30.
						#maximumProficiencyRank -> 10} asDictionary
				evidence: 'Ubisoft Title Update 15, Intelligence Annex: Expertise, and The Pact balance changes')
]

{ #category : 'registration' }
CIWorkbookAttributeData class >> registerIn: catalogue [
	self attributeCaps , self watchBonuses , self resistanceThresholds
		do: [ :spec | 
			| values |
			values := Dictionary new.
			spec fifth
				do: [ :entry | 
					values
						at: entry first
						put: (CIAttributeValue
								status: entry second
								raw: entry third
								magnitude: entry fourth
								unit: entry fifth
								evidence: entry last) ].
			catalogue
				register: (CIAttributeDefinition
						id: spec first
						label: spec second
						context: spec third
						group: spec fourth
						values: values
						notes: spec last) ].
	self registerSupportingRulesIn: catalogue
]

{ #category : 'registration' }
CIWorkbookAttributeData class >> registerSupportingRulesIn: catalogue [
	#(#('skillEfficiency' 'Each 1% of Skill Efficiency contributes 1% to skill damage, haste, duration, health, repair and status effects. The workbook notes that the stat sheet doubles the haste display only.' 'Attribute Info!E49,G49' #(#(affectedStats #(skillDamage skillHaste skillDuration skillHealth repairSkills statusEffects)) #(contributionFactor 1) #(observedHasteDisplayFactor 2))) #('gearModSockets' 'Masks, backpacks and chests have a mod socket. Other gear pieces have one if Improvised.' 'Attribute Info!A66' #(#(ordinarySockets #(Mask Backpack Chest)) #(improvisedSocket true))) #('expertise.weapon' 'Additive with normal weapon damage.' 'Attribute Info!B69:C69' #(#(targetStat weaponDamage) #(operation additive))) #('expertise.skill' 'Additive with normal skill damage for most gadgets. Achilles Pulse is an amplifier.' 'Attribute Info!B70:C70' #(#(targetStat skillDamage) #(operation additive) #(exception Achilles) #(exceptionOperation amplifier))) #('expertise.armor' 'Additive with base armor.' 'Attribute Info!B71:C71' #(#(targetStat baseArmor) #(operation additive))))
		do: [ :spec | 
			| parameters ruleClass |
			parameters := Dictionary new.
			spec fourth do: [ :entry | parameters at: entry first put: entry second ].
			ruleClass := spec first = 'skillEfficiency'
					ifTrue: [ CISkillEfficiencyRule ]
					ifFalse: [ CIAttributeRule ].
			catalogue
				registerRule: (ruleClass
						id: spec first
						description: spec second
						parameters: parameters
						evidence: spec third) ].
	self registerExpertiseProgressionIn: catalogue
]

{ #category : 'workbook data' }
CIWorkbookAttributeData class >> resistanceThresholds [
	^ #(#('immunity.bleed' 'Bleed' statusImmunity 'Status Immunities' #(#(immunityThreshold documented '93.8' 0.938 fraction 'Attribute Info!I2')) #('Attribute Info!H15: *This is against most enemies. Some enemies deal statuses with higher durations than usual and will require more resistance to nullify')) #('immunity.blinddeaf' 'Blind/Deaf' statusImmunity 'Status Immunities' #(#(immunityThreshold documented '91.0' 0.91 fraction 'Attribute Info!I3')) #('Attribute Info!H15: *This is against most enemies. Some enemies deal statuses with higher durations than usual and will require more resistance to nullify')) #('immunity.burn' 'Burn' statusImmunity 'Status Immunities' #(#(immunityThreshold documented '91.4' 0.914 fraction 'Attribute Info!I4')) #('Attribute Info!H15: *This is against most enemies. Some enemies deal statuses with higher durations than usual and will require more resistance to nullify')) #('immunity.disorient' 'Disorient' statusImmunity 'Status Immunities' #(#(immunityThreshold documented '93.8' 0.938 fraction 'Attribute Info!I5')) #('Attribute Info!H15: *This is against most enemies. Some enemies deal statuses with higher durations than usual and will require more resistance to nullify')) #('immunity.disrupt' 'Disrupt' statusImmunity 'Status Immunities' #(#(immunityThreshold documented '95.8' 0.958 fraction 'Attribute Info!I6')) #('Attribute Info!H15: *This is against most enemies. Some enemies deal statuses with higher durations than usual and will require more resistance to nullify')) #('immunity.ensnare' 'Ensnare' statusImmunity 'Status Immunities' #(#(immunityThreshold documented '93.8' 0.938 fraction 'Attribute Info!I7')) #('Attribute Info!H15: *This is against most enemies. Some enemies deal statuses with higher durations than usual and will require more resistance to nullify')) #('immunity.poison' 'Poison' statusImmunity 'Status Immunities' #(#(immunityThreshold documented '89.2' 0.892 fraction 'Attribute Info!I8')) #('Attribute Info!H15: *This is against most enemies. Some enemies deal statuses with higher durations than usual and will require more resistance to nullify')) #('immunity.shock' 'Shock' statusImmunity 'Status Immunities' #(#(immunityThreshold documented '86.0' 0.86 fraction 'Attribute Info!I9')) #('Attribute Info!H15: *This is against most enemies. Some enemies deal statuses with higher durations than usual and will require more resistance to nullify')) #('immunity.pulse' 'Pulse' statusImmunity 'Status Immunities' #(#(immunityThreshold documented '100.0' 1 fraction 'Attribute Info!I10')) #('Attribute Info!H15: *This is against most enemies. Some enemies deal statuses with higher durations than usual and will require more resistance to nullify')) #('immunity.napalmcleaners' 'Napalm (cleaners)' statusImmunity 'Status Immunities' #(#(immunityThreshold documented '88.9' 0.889 fraction 'Attribute Info!I12')) #('Attribute Info!H15: *This is against most enemies. Some enemies deal statuses with higher durations than usual and will require more resistance to nullify')))
]

{ #category : 'workbook data' }
CIWorkbookAttributeData class >> watchBonuses [
	^ #(#('watch.weaponDamage' 'Weapon damage' watch 'Offensive / Attributes' #(#(watchBonus documented '0.1' 0.1 fraction 'Attribute Info!D50')) #()) #('watch.headshotDamage' 'Headshot damage' watch 'Offensive / Attributes' #(#(watchBonus documented '0.2' 0.2 fraction 'Attribute Info!D51')) #()) #('watch.criticalHitChance' 'Critlcal Hit Chance' watch 'Offensive / Attributes' #(#(watchBonus documented '0.1' 0.1 fraction 'Attribute Info!D52')) #()) #('watch.criticalHitDamage' 'Critical Hit Damage' watch 'Offensive / Attributes' #(#(watchBonus documented '0.2' 0.2 fraction 'Attribute Info!D53')) #()) #('watch.armor' 'Armor' watch 'Defensive / Attributes' #(#(watchBonus documented '0.1' 0.1 fraction 'Attribute Info!D54')) #()) #('watch.health' 'Health' watch 'Defensive / Attributes' #(#(watchBonus documented '0.1' 0.1 fraction 'Attribute Info!D55')) #()) #('watch.hazardProtection' 'Hazard Protection' watch 'Defensive / Attributes' #(#(watchBonus documented '0.1' 0.1 fraction 'Attribute Info!D56')) #()) #('watch.explosiveResistance' 'Explosive Resistance' watch 'Defensive / Attributes' #(#(watchBonus documented '0.1' 0.1 fraction 'Attribute Info!D57')) #()) #('watch.skillDamage' 'Skill damage' watch 'Skill / Attributes' #(#(watchBonus documented '0.1' 0.1 fraction 'Attribute Info!D58')) #()) #('watch.skillRepair' 'Skill Repair' watch 'Skill / Attributes' #(#(watchBonus documented '0.1' 0.1 fraction 'Attribute Info!D59')) #()) #('watch.skillHaste' 'Skill Haste' watch 'Skill / Attributes' #(#(watchBonus documented '0.1' 0.1 fraction 'Attribute Info!D60')) #()) #('watch.skillDuration' 'Skill Duration' watch 'Skill / Attributes' #(#(watchBonus documented '0.2' 0.2 fraction 'Attribute Info!D61')) #()) #('watch.reloadSpeed' 'Reload speed' watch 'Utility / Attributes' #(#(watchBonus documented '0.1' 0.1 fraction 'Attribute Info!D62')) #()) #('watch.accuracy' 'Accuracy' watch 'Utility / Attributes' #(#(watchBonus documented '0.1' 0.1 fraction 'Attribute Info!D63')) #()) #('watch.ammo' 'Ammo' watch 'Utility / Attributes' #(#(watchBonus documented '0.2' 0.2 fraction 'Attribute Info!D64')) #()) #('watch.stability' 'Stability' watch 'Utility / Attributes' #(#(watchBonus documented '0.1' 0.1 fraction 'Attribute Info!D65')) #()))
]
