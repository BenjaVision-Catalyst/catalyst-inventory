Class {
	#name : 'CIThatGameLaunchInventoryTest',
	#superclass : 'TestCase',
	#instVars : [
		'directory',
		'service'
	],
	#category : 'BVC-Inventory-Connect-Tests',
	#package : 'BVC-Inventory-Connect-Tests'
}

{ #category : 'support' }
CIThatGameLaunchInventoryTest >> armorKitEncounterIn: catalog named: name selected: selections [
	^ CISpecializationEncounter
		forLoadout: (catalog specializationLoadoutNamed: name selected: selections)
		mode: #pve
		startedAt: 0
]

{ #category : 'support' }
CIThatGameLaunchInventoryTest >> assertSignatureAmmo: grant personal: personal group: group [
	self assert: grant personalPoints equals: personal.
	self assert: grant groupMemberPoints equals: group
]

{ #category : 'helpers' }
CIThatGameLaunchInventoryTest >> gearRowsForFamily: familyId slots: slots catalogue: catalog [
	^ slots
		collect: [ :slot | 
			| identifier spec row |
			identifier := 'gear.launch.' , familyId , '.' , slot asLowercase.
			spec := CIThatGameLaunchCatalog spawnSpecs
					detect: [ :entry | entry key = identifier ].
			row := CIItemGenerator new
					generate: identifier
					type: identifier
					values: spec value
					from: catalog
					using: [ 0 ].
			row equippedSlotIdentifier: slot.
			row ]
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> rowsFor: identity [
	^ (service
		rowsForVerifiedUser: identity
		offset: 0
		limit: 32)
		, (service
				rowsForVerifiedUser: identity
				offset: 32
				limit: 32)
]

{ #category : 'running' }
CIThatGameLaunchInventoryTest >> setUp [
	super setUp.
	directory := FileLocator temp / ('thatgame-inventory-' , UUID new asString).
	directory ensureCreateDirectory
]

{ #category : 'support' }
CIThatGameLaunchInventoryTest >> signatureAmmoEncounterNamed: name selected: perkIds [
	^ CISpecializationEncounter
		forLoadout: (CIGameItemTypes buildCatalog
				specializationLoadoutNamed: name
				selected: perkIds)
		mode: #pve
		startedAt: 0
]

{ #category : 'running' }
CIThatGameLaunchInventoryTest >> startInventory [
	| config |
	config := CIInventoryConfiguration new
			identifier: #inventory;
			label: 'Inventory';
			authoritative: true;
			inventorySnapshotPath: (directory / 'inventory.ston') fullName;
			yourself.
	service := CIInventoryService new installWithConfiguration: config.
	service start
]

{ #category : 'running' }
CIThatGameLaunchInventoryTest >> tearDown [
	[ service ifNotNil: [ service stop ] ]
		ensure: [ directory ensureDeleteAll.
			super tearDown ]
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testAchillesExpertiseAmplifiesOnlyHitsOnMarkedZones [
	| catalog achilles rule |
	catalog := CIGameItemTypes buildCatalog.
	achilles := (catalog gadgetFamilyNamed: 'Pulse') variantNamed: 'Achilles'.
	rule := achilles expertiseRule.
	self assert: rule evidence equals: 'Skill List!M76'.
	self assert: rule operation equals: #amplifier.
	self assert: rule targetTrackLabel isNil.
	self assert: (rule damageMultiplierForMarkedHit: true atGrade: 0) equals: 1.
	self
		assert: (rule damageMultiplierForMarkedHit: true atGrade: 20)
		closeTo: 1.20.
	self assert: (rule damageMultiplierForMarkedHit: false atGrade: 20) equals: 1.
	self
		should: [ rule damageMultiplierForMarkedHit: true atGrade: -1 ]
		raise: Error.
	self deny: ((achilles knownStatsAtTier: 0) includesKey: 'Damage')
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testAcostaGoBagRefundsOnActivationAndGrantsTierOrOvercharge [
	| catalog rule effects |
	catalog := CIGameItemTypes buildCatalog.
	rule := (catalog namedGearReferenceAt: 'Acosta''s Go-Bag') gadgetTalentRule.
	self assert: (rule evidence includesSubstring: 'Gear Named + Exotics!F79:G79').
	self assert: rule cooldownSeconds equals: 60.
	self
		assert: rule passiveBonuses
		equals: {#armorKitCapacity -> 1.
				#grenadeCapacity -> 3.
				#ammoCapacity -> 0.25.
				#repairSkills -> 0.10.
				#statusEffects -> 0.10} asDictionary.
	effects := rule
			effectsOnGrenadeThrowAtGadgetTier: 5
			secondsSinceLastActivation: nil.
	self assert: (effects at: #grenadesRefunded) equals: 1.
	self assert: (effects at: #gadgetTierBonus) equals: 1.
	self assert: (effects at: #gadgetTierBonusSeconds) equals: 15.
	self
		assertEmpty: (rule effectsOnGrenadeThrowAtGadgetTier: 6 secondsSinceLastActivation: 59.99).
	effects := rule
			effectsOnGrenadeThrowAtGadgetTier: 6
			secondsSinceLastActivation: 60.
	self assert: (effects at: #grenadesRefunded) equals: 1.
	self assert: (effects at: #overchargeSeconds) equals: 15.
	self
		assert: (rule
				effectsOnGrenadeThrowAtGadgetTier: #overcharge
				secondsSinceLastActivation: 60) isNil
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testAllDocumentedGadgetHasteTracksResolveAsSpeed [
	| catalog cases track variant result |
	catalog := CIGameItemTypes buildCatalog.
	cases := #(#('Sticky Bomb' 'Burn' 'Cooldown' 60 5) #('Sticky Bomb' 'Explosive' 'Cooldown' 60 5) #('Decoy' 'Holographic Distraction' 'Cooldown' 25 2) #('Pulse' 'Achilles' 'Cooldown' 40 1) #('Hive' 'Restorer' 'Refill Speed' 11 1.5) #('Hive' 'Stinger' 'Refill Speed' 10 3) #('Hive' 'Reviver' 'Refill Speed' 180 10) #('Hive' 'Booster' 'Refill Speed' 11.3 1.5) #('Hive' 'Artificer' 'Refill Speed' 11.3 1.5)).
	cases
		do: [ :row | 
			variant := (catalog gadgetFamilyNamed: row first) variantNamed: row second.
			track := variant trackNamed: row third.
			self
				assert: ((track rawValueAtTier: #overcharge) includesSubstring: 'Skill Haste').
			self assert: (track magnitudeAtTier: 0) equals: row fourth.
			result := (variant knownStatsAtTier: #overcharge) at: row third.
			self assert: result closeTo: row fourth / (1 + row fifth) ].
	variant := (catalog gadgetFamilyNamed: 'Pulse') variantNamed: 'Achilles'.
	self
		assert: ((variant trackNamed: 'Cooldown') magnitudeAtTier: 1)
		closeTo: 40 / 1.1.
	variant := (catalog gadgetFamilyNamed: 'Shield') variantNamed: 'Striker'.
	self
		assert: ((variant trackNamed: 'Damage bonus / (per enemy)') magnitudeAtTier: 1) isNil
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testAllSpecializationGrenadesClaimWithWorkbookStatusAndSource [
	| catalog store owner cases |
	catalog := CIGameItemTypes buildCatalog.
	store := CIInventoryReadStore new.
	owner := 'specialization-grenade-types'.
	cases := #(#('Sharpshooter' 'sharpshooter.flashbanggrenade' #(blind) 'Specializations!G16:H16') #('Survivalist' 'survivalist.incendiarygrenade' #(burn) 'Specializations!K16:L16') #('Technician' 'technician.empgrenade' #(disrupt) 'Specializations!G36:H36') #('Gunner' 'gunner.riotfoamgrenade' #(ensnare) 'Specializations!K35:L35') #('Demolitionist' 'demolitionist.fragmentationgrenade' #(bleed) 'Specializations!G55:H55') #('Firewall' 'firewall.clustergrenade' #() 'Specializations!K55:L55')).
	cases
		do: [ :row | 
			| item type perk |
			store
				specialization: (CISpecializationSelection specialization: row first perks: {row second})
				forOwner: owner.
			item := store
					claimSpecializationGrenadeForPerk: row second
					from: catalog
					forOwner: owner.
			type := catalog typeAt: item definitionIdentifier.
			perk := type rewardPerk.
			self assert: perk id equals: row second.
			self assert: perk equipmentReward appliedStatuses equals: row third.
			self assert: perk evidence equals: row fourth.
			self assert: item displayName equals: perk name ].
	self assert: (store allRowsForOwner: owner) size equals: 6
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testAllWorkbookSpecializationGadgetRewardsResolveToTheirRegisteredItemTypes [
	| catalog store owner rows |
	catalog := CIGameItemTypes buildCatalog.
	store := CIInventoryReadStore new.
	owner := 'all-specialization-gadget-rewards'.
	rows := #(#('Sharpshooter' 'sharpshooter.tactician' 'gadget.workbook.drone.tactician') #('Survivalist' 'survivalist.mender' 'gadget.workbook.seeker.mender') #('Technician' 'technician.artificer' 'gadget.workbook.hive.artificer') #('Gunner' 'gunner.banshee' 'gadget.workbook.pulse.banshee') #('Demolitionist' 'demolitionist.artilleryturret' 'gadget.workbook.turret.artillery') #('Firewall' 'firewall.strikershield' 'gadget.workbook.shield.striker')).
	rows
		do: [ :row | 
			| item |
			store
				specialization: (CISpecializationSelection specialization: row first perks: {row second})
				forOwner: owner.
			item := store
					claimSpecializationGadgetForPerk: row second
					from: catalog
					forOwner: owner.
			self assert: item definitionIdentifier equals: row third ].
	self assert: (store allRowsForOwner: owner) size equals: 6
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testArmorKitOwnerEffectsPreserveWorkbookValuesAndMissingValues [
	| catalog cases |
	catalog := CIGameItemTypes buildCatalog.
	cases := #(#('Sharpshooter' 'sharpshooter.emegencycleanse' #(#(repair onUse 1 nil #()) #(removeStatusEffects onUse nil nil #()) #(statusResistance timed nil 20 #(bleed poison burn)))) #('Gunner' 'gunner.hardenedarmorkits' #(#(armorRepair onUse 1 nil #()) #(bonusArmor timed 0.30 10 #()))) #('Demolitionist' 'demolitionist.stimulantpatch' #(#(repair onUse 1 nil #()) #(weaponHandling timed 0.30 15 #()))) #('Firewall' 'firewall.extracellularmatrixmesh' #(#(armorRepair overTime 2 10 #()) #(healthRecovery overTime 2 10 #())))).
	cases
		do: [ :row | 
			| encounter effects |
			encounter := self
					armorKitEncounterIn: catalog
					named: row first
					selected: {row second}.
			effects := encounter armorKitEffectsForRecipient: #self atDistance: nil.
			self
				assert: (effects
						collect: [ :each | 
							{each kind.
								each timing.
								each fraction.
								each durationSeconds.
								each statuses} ])
				equals: row third.
			self
				assertEmpty: (encounter armorKitEffectsForRecipient: #groupMember atDistance: 0) ]
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testArmorKitRecipientsHonorSelectionAndWorkbookRanges [
	| catalog survivalist technician inactive repair proxyEffect |
	catalog := CIGameItemTypes buildCatalog.
	survivalist := self
			armorKitEncounterIn: catalog
			named: 'Survivalist'
			selected: #('survivalist.distributedrepair').
	technician := self
			armorKitEncounterIn: catalog
			named: 'Technician'
			selected: #('technician.emergencypatch').
	inactive := self
			armorKitEncounterIn: catalog
			named: 'Survivalist'
			selected: #().
	repair := (survivalist armorKitEffectsForRecipient: #self atDistance: nil)
			first.
	self assert: repair kind equals: #repair.
	self assert: repair timing equals: #overTime.
	self assert: repair durationSeconds equals: 5.
	self assert: repair fraction isNil.
	repair := (survivalist armorKitEffectsForRecipient: #groupMember atDistance: 20)
			first.
	self assert: repair recipient equals: #groupMember.
	self assert: repair timing equals: #overTime.
	self assert: repair durationSeconds equals: 5.
	self assert: repair fraction isNil.
	self
		assertEmpty: (survivalist armorKitEffectsForRecipient: #groupMember atDistance: 20.01).
	self
		assertEmpty: (survivalist armorKitEffectsForRecipient: #groupMember atDistance: nil).
	self
		assertEmpty: (survivalist armorKitEffectsForRecipient: #friendlySkillProxy atDistance: 1).
	self
		assertEmpty: (inactive armorKitEffectsForRecipient: #groupMember atDistance: 1).
	proxyEffect := (technician
			armorKitEffectsForRecipient: #friendlySkillProxy
			atDistance: 10) first.
	self assert: proxyEffect kind equals: #shareBaseKit.
	self assert: proxyEffect timing equals: #baseKit.
	self assert: proxyEffect fraction isNil.
	self
		assertEmpty: (technician armorKitEffectsForRecipient: #friendlySkillProxy atDistance: 10.01).
	self
		assertEmpty: (technician armorKitEffectsForRecipient: #groupMember atDistance: 1).
	self
		assertEmpty: (technician armorKitEffectsForRecipient: #self atDistance: nil)
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testArtificerExpertiseAddsFromBaseBuffAmountAtEveryTier [
	| catalog variant rule stats |
	catalog := CIGameItemTypes buildCatalog.
	variant := (catalog gadgetFamilyNamed: 'Hive') variantNamed: 'Artificer'.
	rule := variant expertiseRule.
	self assert: rule evidence equals: 'Skill List!M151'.
	self assert: rule operation equals: #additive.
	self assert: (rule buffAmountAtTier: 0 grade: 2) closeTo: 0.102.
	self assert: (rule buffAmountAtTier: 1 grade: 0) closeTo: 0.20.
	self assert: (rule buffAmountAtTier: 1 grade: 5) closeTo: 0.205.
	self assert: (rule buffAmountAtTier: 6 grade: 30) closeTo: 0.73.
	self assert: (rule buffAmountAtTier: #overcharge grade: 30) closeTo: 0.83.
	stats := variant knownStatsAtTier: 1.
	self assert: (stats at: 'Buff Amount') closeTo: 0.20.
	self assert: (stats at: 'Skill Repair') closeTo: 0.10.
	self assert: (stats at: 'Buff Duration') equals: 10
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testAttributeCataloguePreservesScopeMissingValuesAndConflicts [
	| attributes rifle value gearMod notes |
	attributes := CIGameItemTypes buildCatalog attributeCatalogue.
	self assert: (attributes definitionsIn: #gearMod) size equals: 11.
	self assert: (attributes definitionsIn: #watch) size equals: 16.
	self assert: (attributes definitionsIn: #statusImmunity) size equals: 10.
	value := (attributes definitionAt: 'weapon.damage') valueFor: #prototypeMaximum.
	self assert: value magnitude equals: 0.225.
	self assert: value unit equals: #fraction.
	self assert: value evidence equals: 'Attribute Info!F2'.
	rifle := attributes definitionAt: 'weapon.class.rifle'.
	self assert: (rifle valueFor: #standardMaximum) status equals: #documented.
	self assert: (rifle valueFor: #standardMaximum) magnitude equals: 0.34.
	self assert: (rifle valueFor: #standardMaximum) rawText equals: '34'.
	self assert: (rifle valueFor: #prototypeMaximum) status equals: #documented.
	self assert: (rifle valueFor: #prototypeMaximum) magnitude equals: 0.51.
	self assert: (rifle valueFor: #weaponsTabMaximum) magnitude equals: 0.17.
	self assert: (rifle valueFor: #prototypeMaximum) rawText equals: '51%%'.
	self
		assert: ((attributes definitionAt: 'weapon.class.pistol') valueFor: #standardMaximum)
				status
		equals: #inapplicable.
	self
		assert: ((attributes definitionAt: 'weapon.minor.optimalRange')
				valueFor: #prototypeMaximum) status
		equals: #unspecified.
	gearMod := attributes definitionAt: 'gearMod.criticalHitChance'.
	self assert: (gearMod valueFor: #standardMaximum) magnitude equals: 0.06.
	self assert: (gearMod valueFor: #prototypeMaximum) magnitude isNil.
	value := (attributes definitionAt: 'immunity.shock')
			valueFor: #immunityThreshold.
	self assert: value magnitude equals: 0.86.
	notes := (attributes definitionAt: 'immunity.shock') notes.
	self assert: (notes first includesSubstring: 'most enemies').
	self
		assert: ((attributes ruleAt: 'skillEfficiency') parameters at: #affectedStats) size
		equals: 6.
	self
		assert: ((attributes ruleAt: 'expertise.skill') parameters at: #exception)
		equals: #Achilles
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testBackupBoomstickGeneratesAsShotgunInSidearmSlot [
	| catalog weapon item |
	catalog := CIGameItemTypes buildCatalog.
	weapon := catalog typeAt: 'weapon.workbook.backupBoomstick'.
	self assert: weapon statisticsReference weaponClass equals: #shotgun.
	item := CIItemGenerator new
			generate: 'backupBoomstick'
			type: weapon id
			values: Dictionary new
			from: catalog
			using: [ 0 ].
	self assert: (item permitsCapturedEquipmentSlot: 'LeftHandWeapon').
	self deny: (item permitsCapturedEquipmentSlot: 'RangedWeapon').
	self assert: item comparisonStats first statIdentifier equals: 'weaponDamage'.
	self assert: item comparisonStats first value equals: 0.17
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testBluescreenStackBandsShieldGateAndMarkedKill [
	| catalog bluescreen result nearby |
	catalog := CIGameItemTypes buildCatalog.
	bluescreen := CIExoticWeaponEncounter
			weapon: 'bluescreen'
			talent: (catalog talentAt: 'disruptorRounds')
			magazineCapacity: nil.
	11
		timesRepeat: [ bluescreen recordBluescreenHitFrom: 'bluescreen' on: 'marked' ].
	self
		assertEmpty: (bluescreen
				bluescreenApplicationsOnDeployingShield: true
				nearbyByMarkedTarget: Dictionary new).
	result := bluescreen
			bluescreenApplicationsOnDeployingShield: false
			nearbyByMarkedTarget: Dictionary new.
	self assert: (result collect: #statusIdentifier) equals: #(pulse disrupt).
	self
		assert: (result allSatisfy: [ :application | application durationSeconds = 5 ]).
	self
		assertEmpty: (bluescreen
				bluescreenApplicationsOnDeployingShield: false
				nearbyByMarkedTarget: Dictionary new).
	52
		timesRepeat: [ bluescreen recordBluescreenHitFrom: 'bluescreen' on: 'marked' ].
	nearby := {'marked'
				-> {'edge' -> 10.
						'outside' -> 11} asDictionary} asDictionary.
	self
		assertEmpty: (bluescreen
				bluescreenApplicationsOnKillOf: 'unmarked'
				nearbyByMarkedTarget: nearby).
	result := bluescreen
			bluescreenApplicationsOnKillOf: 'marked'
			nearbyByMarkedTarget: nearby.
	self
		assert: (result collect: #statusIdentifier)
		equals: #(pulse disrupt disorient).
	self
		assert: (result allSatisfy: [ :application | application targetIdentifier = 'edge' ])
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testCalculatedVariantsReportCooldownReductionOnlyOnKillsFromCover [
	| catalog reference standard perfect |
	catalog := CIGameItemTypes buildCatalog.
	reference := catalog talentReferenceAt: 'Gear Talents!D45'.
	standard := CIGearTalentEncounter
			talent: (catalog talentAt: reference talentIdentifier).
	perfect := CIGearTalentEncounter
			talent: (catalog talentAt: reference perfectTalentIdentifier).
	self
		assert: (standard gadgetCooldownReductionFractionOnEnemyKillAt: 0)
		equals: 0.
	standard coverState: #inCover at: 1.
	self
		assert: (standard gadgetCooldownReductionFractionOnEnemyKillAt: 1)
		equals: 0.10.
	self
		assert: (standard gadgetCooldownReductionFractionOnEnemyKillAt: 2)
		equals: 0.10.
	standard coverState: #exposed at: 3.
	self
		assert: (standard gadgetCooldownReductionFractionOnEnemyKillAt: 3)
		equals: 0.
	perfect coverState: #inCover at: 0.
	self
		assert: (perfect gadgetCooldownReductionFractionOnEnemyKillAt: 0)
		equals: 0.15.
	self
		should: [ CIGearTalentEncounter
				talent: (catalog talentAt: reference perfectTalentIdentifier)
				mode: #pvp ]
		raise: Error
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testCapacitorAndLibertyHitStacksUseWorkbookParameters [
	| catalog capacitor liberty |
	catalog := CIGameItemTypes buildCatalog.
	capacitor := CIExoticWeaponEncounter
			weapon: 'capacitor'
			talent: (catalog talentAt: 'capacitance')
			magazineCapacity: 41.
	50 timesRepeat: [ capacitor recordEnemyHitFrom: 'capacitor' at: 0 ].
	self assert: (capacitor capacitorSkillDamageBonusAt: 5) closeTo: 0.60.
	self assert: (capacitor capacitorSkillDamageBonusAt: 6) closeTo: 0.585.
	self assert: (capacitor capacitorSkillDamageBonusAt: 7) closeTo: 0.57.
	self assert: (capacitor capacitorSkillDamageBonusAt: 7) closeTo: 0.57.
	capacitor recordEnemyHitFrom: 'capacitor' at: 7.
	self assert: (capacitor capacitorSkillDamageBonusAt: 12) closeTo: 0.585.
	self assert: (capacitor capacitorWeaponDamageBonusAtSkillTier: 6) closeTo: 0.45.
	liberty := CIExoticWeaponEncounter
			weapon: 'liberty'
			talent: (catalog talentAt: 'libertyOrDeath')
			magazineCapacity: 8.
	35 timesRepeat: [ liberty recordEnemyHitFrom: 'liberty' at: 0 ].
	self assert: liberty libertyWeaponDamageBonus closeTo: 0.60.
	self assert: (liberty consumeLibertyStacksOnHeadshotFrom: 'other') equals: 0.
	self
		assert: (liberty consumeLibertyStacksOnHeadshotFrom: 'liberty')
		closeTo: 0.90.
	self assert: liberty libertyWeaponDamageBonus equals: 0
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testChatterboxReloadAndRefillUseEffectiveMagazine [
	| catalog owner row encounter distances |
	self startInventory.
	catalog := CIGameItemTypes buildCatalog.
	owner := 'chatterbox-combat'.
	row := CIItemGenerator new
			generate: 'chatterbox'
			type: 'weapon.launch.chatterbox'
			values: (Dictionary new
					at: 'weaponDamage' put: 0.1;
					yourself)
			from: catalog
			using: [ 0 ].
	row equippedSlotIdentifier: 'RangedWeapon'.
	service replaceReadRows: {row} forOwner: owner.
	encounter := service
			exoticWeaponEncounterFor: 'chatterbox'
			forVerifiedUser: owner.
	distances := {'a' -> 4.
			'b' -> 15.
			'c' -> 16} asDictionary.
	self
		deny: (encounter recordReloadFrom: 'another' enemiesAtDistances: distances).
	self assert: encounter rateOfFireBonus equals: 0.
	self
		assert: (encounter recordReloadFrom: 'chatterbox' enemiesAtDistances: distances).
	self assert: encounter rateOfFireBonus equals: 0.50.
	self
		assert: (encounter magazineRefillOnKillFrom: 'chatterbox' remaining: 8)
		equals: 30.
	self
		assert: (encounter magazineRefillOnKillFrom: 'chatterbox' remaining: 55)
		equals: 5.
	self assert: encounter rateOfFireBonus equals: 0.50.
	1 to: 8 do: [ :index | distances at: index put: 3 ].
	encounter recordReloadFrom: 'chatterbox' enemiesAtDistances: distances.
	self assert: encounter rateOfFireBonus equals: 1.25.
	encounter recordMagazineEndedFrom: 'chatterbox'.
	self assert: encounter rateOfFireBonus equals: 0
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testClassifiedUpgradesFollowEquippedSlots [
	| catalog evaluator rows chest backup red jupiter |
	catalog := CIGameItemTypes buildCatalog.
	evaluator := CILoadoutFamilyEvaluator new.
	rows := self
			gearRowsForFamily: 'redLotusAssault'
			slots: #('Chest' 'Backpack' 'Mask' 'Gloves' 'KneePads')
			catalogue: catalog.
	chest := rows first.
	backup := rows second.
	red := [ (evaluator
			evaluateRows: rows
			catalogue: catalog
			mode: #pve)
			detect: [ :activation | activation family id = 'redLotusAssault' ] ].
	chest equippedSlotIdentifier: nil.
	self assert: red value equippedCount equals: 4.
	self
		assert: (red value activeTalents collect: #id)
		equals: #('strikersGamble' 'riskManagement').
	self assert: (red value effectiveSetParameters at: #maxStacks) equals: 100.
	self
		assert: (red value effectiveSetParameters at: #damagePerStack)
		equals: 0.009.
	chest equippedSlotIdentifier: 'Chest'.
	self assert: (red value effectiveSetParameters at: #maxStacks) equals: 200.
	chest equippedSlotIdentifier: nil.
	backup equippedSlotIdentifier: nil.
	self assertEmpty: red value activeTalents.
	self assert: red value effectiveSetParameters isNil.
	rows := self
			gearRowsForFamily: 'jupiterTechnologies'
			slots: #('Chest' 'Backpack' 'Mask' 'Gloves')
			catalogue: catalog.
	jupiter := (evaluator
			evaluateRows: rows
			catalogue: catalog
			mode: #pve)
			detect: [ :activation | activation family id = 'jupiterTechnologies' ].
	self
		assert: (jupiter effectiveSetParameters at: #spreadRadiusMetres)
		equals: 15.
	self
		assert: (jupiter effectiveSetParameters at: #durationRefreshFraction)
		equals: 0.75.
	self
		assert: (jupiter effectiveSetParameters at: #damageAmplificationToStatusTargets)
		equals: 0.30
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testCombatMedicResolvesReviveProtectionAndOvercharge [
	| reference rule effects |
	reference := CIGameItemTypes buildCatalog
			namedGearReferenceAt: 'Birdie''s Quick Fix Pack'.
	rule := reference gadgetTalentRule.
	self assert: (rule evidence includesSubstring: 'Gear Named + Exotics!F81:G81').
	self assert: rule manualReviveSpeedBonus equals: 0.80.
	self assert: rule weakenedDurationReduction equals: 0.50.
	self assert: rule hiveEfficiencyBonus equals: 0.45.
	self assert: (rule damageResistanceDuringReviveFor: #reviver) equals: 0.50.
	self assert: (rule damageResistanceDuringReviveFor: #revivedAgent) equals: 0.50.
	self assert: (rule damageResistanceDuringReviveFor: #bystander) equals: 0.
	self
		assert: (rule
				damageResistanceAfterSuccessfulRevive: #hive
				for: #revivedAgent
				elapsedSeconds: 4.99)
		equals: 0.50.
	self
		assert: (rule
				damageResistanceAfterSuccessfulRevive: #hive
				for: #revivedAgent
				elapsedSeconds: 5)
		equals: 0.
	self
		assert: (rule
				damageResistanceAfterSuccessfulRevive: #manual
				for: #reviver
				elapsedSeconds: 9.99)
		equals: 0.50.
	self
		assert: (rule
				damageResistanceAfterSuccessfulRevive: #manual
				for: #reviver
				elapsedSeconds: 10)
		equals: 0.
	self
		assert: (rule
				damageResistanceAfterSuccessfulRevive: nil
				for: #reviver
				elapsedSeconds: 0) isNil.
	effects := rule effectsOnSuccessfulReviveAtGadgetTier: 5.
	self assert: (effects at: #gadgetTierBonus) equals: 1.
	self assert: (effects at: #gadgetTierBonusSeconds) equals: 5.
	self
		assert: ((rule effectsOnSuccessfulReviveAtGadgetTier: 6) at: #overchargeSeconds)
		equals: 15.
	self assert: (rule effectsOnSuccessfulReviveAtGadgetTier: #overcharge) isNil
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testDoctorHomeMarksExpireAndNemesisKeepsItsDocumentedBounds [
	| catalog doctor nemesis pickup |
	catalog := CIGameItemTypes buildCatalog.
	doctor := CIExoticWeaponEncounter
			weapon: 'doctor'
			talent: (catalog talentAt: 'doctorHome')
			magazineCapacity: 10.
	self
		deny: (doctor
				recordDoctorHomeHitFrom: 'other'
				on: 'target'
				at: 0).
	self assert: (doctor doctorHomePickupOnKillOf: 'target' at: 0) isNil.
	self
		assert: (doctor
				recordDoctorHomeHitFrom: 'doctor'
				on: 'target'
				at: 1).
	pickup := doctor doctorHomePickupOnKillOf: 'target' at: 5.
	self assert: pickup fraction equals: 0.10.
	self deny: pickup grantsBonusArmor.
	self assert: (doctor doctorHomePickupOnKillOf: 'target' at: 5) isNil.
	doctor
		recordDoctorHomeHitFrom: 'doctor'
		on: 'expired'
		at: 5.
	self assert: (doctor doctorHomePickupOnKillOf: 'expired' at: 10) isNil.
	nemesis := CIExoticWeaponEncounter
			weapon: 'nemesis'
			talent: (catalog talentAt: 'electromagneticAccelerator')
			magazineCapacity: nil.
	self assert: nemesis nemesisChargeDamageBounds equals: #(0 1).
	self
		assert: (nemesis damageMultiplierForResolvedNemesisCharge: 0.5)
		equals: 0.5.
	self
		should: [ nemesis damageMultiplierForResolvedNemesisCharge: 1.1 ]
		raise: Error
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testEnergizeVariantsRespectCooldownAndPreserveUnknownOverchargeDuration [
	| catalog reference standard perfect tierBonus overcharge |
	catalog := CIGameItemTypes buildCatalog.
	reference := catalog talentReferenceAt: 'Gear Talents!D44'.
	standard := reference gadgetTalentRule.
	perfect := reference perfectGadgetTalentRule.
	self
		assert: (catalog namedGearReferenceAt: 'Axel') gadgetTalentRule
		identicalTo: perfect.
	self assert: standard cooldownSeconds equals: 60.
	self assert: perfect cooldownSeconds equals: 30.
	tierBonus := standard
			effectsOnArmorKitUseAtGadgetTier: 5
			secondsSinceLastActivation: nil.
	self assert: (tierBonus at: #gadgetTierBonus) equals: 1.
	self assert: (tierBonus at: #gadgetTierBonusSeconds) equals: 15.
	self
		assertEmpty: (standard effectsOnArmorKitUseAtGadgetTier: 5 secondsSinceLastActivation: 59.99).
	self
		assert: (standard effectsOnArmorKitUseAtGadgetTier: 5 secondsSinceLastActivation: 60)
		equals: tierBonus.
	self
		assertEmpty: (perfect effectsOnArmorKitUseAtGadgetTier: 6 secondsSinceLastActivation: 29.99).
	overcharge := perfect
			effectsOnArmorKitUseAtGadgetTier: 6
			secondsSinceLastActivation: 30.
	self assert: (overcharge at: #overcharge).
	self deny: (overcharge includesKey: #overchargeSeconds).
	self
		assert: (perfect
				effectsOnArmorKitUseAtGadgetTier: #overcharge
				secondsSinceLastActivation: 30) isNil
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testEquipmentExpertiseContributesOnePercentOfItemBaseStatPerGrade [
	| attributes weapon armor |
	attributes := CIGameItemTypes buildCatalog attributeCatalogue.
	weapon := attributes ruleAt: 'expertise.weapon'.
	armor := attributes ruleAt: 'expertise.armor'.
	self assert: (weapon parameters at: #operation) equals: #additive.
	self assert: (weapon parameters at: #baseStat) equals: #baseWeaponDamage.
	self assert: (armor parameters at: #operation) equals: #additive.
	self assert: (armor parameters at: #baseStat) equals: #baseArmor.
	self assert: (weapon contributionAtGrade: 0) equals: 0.
	self assert: (weapon contributionAtGrade: 30) closeTo: 0.30.
	self assert: (weapon bonusAtGrade: 15 onBase: 100000) closeTo: 15000.
	self assert: (armor bonusAtGrade: 27 onBase: 157961) closeTo: 42649.47.
	self should: [ armor contributionAtGrade: -1 ] raise: Error.
	self should: [ weapon bonusAtGrade: 1 onBase: -1 ] raise: Error
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testEquippedCreepingDeathSpreadsWithCooldown [
	| owner catalog row encounter application distances targets |
	self startInventory.
	owner := 'gear-talent-owner'.
	catalog := CIGameItemTypes buildCatalog.
	row := (catalog typeAt: 'gear.launch.morrowWorks.backpack')
			inventoryItem: 'pack'
			values: (Dictionary new
					at: 'skillTier' put: 1;
					yourself)
			talentIdentifier: 'perfectCreepingDeath'.
	service replaceReadRows: {row} forOwner: owner.
	self
		should: [ service pveGearTalentEncounterFor: 'pack' forVerifiedUser: owner ]
		raise: Error.
	row := row copy.
	row equippedSlotIdentifier: 'Backpack'.
	service replaceReadRows: {row} forOwner: owner.
	encounter := service pveGearTalentEncounterFor: 'pack' forVerifiedUser: owner.
	application := CICombatStatusApplication
			status: 'burn'
			target: 'primary'
			durationSeconds: 5.
	distances := {'primary' -> 0.
			'edge' -> 10.
			'outside' -> 11} asDictionary.
	targets := encounter
			spreadStatus: application
			targetsAtDistances: distances
			at: 0.
	self assert: (targets collect: #targetIdentifier) equals: #('edge').
	self assert: targets first durationSeconds equals: 5.
	self
		assertEmpty: (encounter
				spreadStatus: application
				targetsAtDistances: distances
				at: 9).
	self
		assert: (encounter
				spreadStatus: application
				targetsAtDistances: distances
				at: 10) size
		equals: 1
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testExoticGenerationSeparatesCoreOverridesMinorRollsAndFactoryMods [
	| catalog generator capacitor values item testSubject |
	catalog := CIGameItemTypes buildCatalog.
	generator := CIItemGenerator new.
	capacitor := catalog typeAt: 'weapon.launch.capacitor'.
	self
		assert: (capacitor classGenerationRule maximumFor: #standardMaximum)
		equals: 0.12.
	self
		assert: (capacitor classGenerationRule maximumFor: #prototypeMaximum) isNil.
	self
		assert: capacitor classGenerationRule evidence
		equals: 'Weapons Named + Exotics!F112'.
	self
		assert: capacitor minorAttributeRule evidence
		equals: 'Weapons Named + Exotics!G112'.
	self
		deny: (capacitor minorAttributeRule attributeIdentifiers
				includes: 'weapon.minor.damageToArmor').
	self
		assert: ((catalog typeAt: 'weapon.launch.chatterbox') minorAttributeRule
				attributeIdentifiers includes: 'weapon.minor.damageToArmor').
	values := {'weaponDamage' -> 0.10.
			'damageToArmor' -> 0.11.
			'minorAttributeIdentifier' -> 'weapon.minor.rateOfFire'.
			'minorAttributeValue' -> 0.05} asDictionary.
	item := generator
			generate: 'capacitor'
			type: capacitor id
			values: values
			from: catalog
			using: [ 0 ].
	self
		assert: (item comparisonStats collect: #statIdentifier)
		equals: #('weaponDamage' 'damageToArmor' 'weapon.minor.rateOfFire').
	self assert: (item comparisonStats collect: #value) equals: #(0.10 0.11 0.05).
	self assert: (item modSlots anySatisfy: #isLocked).
	values at: 'minorAttributeValue' put: 0.06.
	self
		should: [ generator
				generate: 'bad'
				type: capacitor id
				values: values
				from: catalog
				using: [ 0 ] ]
		raise: Error.
	values at: 'minorAttributeValue' put: 0.05.
	values at: 'minorAttributeIdentifier' put: 'weapon.minor.damageToArmor'.
	self
		should: [ generator
				generate: 'duplicate'
				type: capacitor id
				values: values
				from: catalog
				using: [ 0 ] ]
		raise: Error.
	values removeKey: 'minorAttributeIdentifier'.
	self
		should: [ generator
				generate: 'partial'
				type: capacitor id
				values: values
				from: catalog
				using: [ 0 ] ]
		raise: Error.
	testSubject := catalog typeAt: 'weapon.workbook.testSubject'.
	self
		assert: (testSubject classGenerationRule maximumFor: #standardMaximum)
		equals: 0.21
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testExpertiseProgressionRequiresProficiencyAndRespectsAccountCap [
	| catalog rule |
	catalog := CIGameItemTypes buildCatalog.
	rule := catalog attributeCatalogue ruleAt: 'expertise.progression'.
	self assert: rule maximumExpertiseLevel equals: 30.
	self assert: rule maximumProficiencyRank equals: 10.
	self
		assert: (rule
				canUpgradeFromGrade: 0
				expertiseLevel: 1
				proficiencyRank: 10).
	self
		deny: (rule
				canUpgradeFromGrade: 0
				expertiseLevel: 30
				proficiencyRank: 9).
	self
		deny: (rule
				canUpgradeFromGrade: 0
				expertiseLevel: 0
				proficiencyRank: 10).
	self
		deny: (rule
				canUpgradeFromGrade: 15
				expertiseLevel: 15
				proficiencyRank: 10).
	self
		assert: (rule
				canUpgradeFromGrade: 29
				expertiseLevel: 30
				proficiencyRank: 10).
	self
		deny: (rule
				canUpgradeFromGrade: 30
				expertiseLevel: 30
				proficiencyRank: 10).
	self
		should: [ rule
				canUpgradeFromGrade: 0
				expertiseLevel: 31
				proficiencyRank: 10 ]
		raise: Error.
	self
		should: [ rule
				canUpgradeFromGrade: 0
				expertiseLevel: 30
				proficiencyRank: 11 ]
		raise: Error.
	self
		should: [ rule
				canUpgradeFromGrade: -1
				expertiseLevel: 30
				proficiencyRank: 10 ]
		raise: Error
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testFeedbackLoopTargetsOtherGadgetAndAppliesSlotBonusesIndependently [
	| catalog rule normal upgraded |
	catalog := CIGameItemTypes buildCatalog.
	rule := (catalog gearFamilyReferenceAt: 'Hard Wired') gadgetTalentRule.
	self assert: rule evidence equals: 'Gearsets!E23:G23'.
	self assert: (rule cooldownSecondsWithShortCircuit: false) equals: 10.
	self assert: (rule cooldownSecondsWithShortCircuit: true) equals: 5.
	self
		assertEmpty: (rule
				effectsOnGadgetEvent: #use
				equippedPieces: 3
				secondsSinceLastActivation: nil
				positiveReinforcement: false
				shortCircuit: false).
	self
		assertEmpty: (rule
				effectsOnGadgetEvent: #hit
				equippedPieces: 4
				secondsSinceLastActivation: nil
				positiveReinforcement: false
				shortCircuit: false).
	normal := rule
			effectsOnGadgetEvent: #use
			equippedPieces: 4
			secondsSinceLastActivation: nil
			positiveReinforcement: false
			shortCircuit: false.
	self assert: (normal at: #otherGadgetCooldownReductionSeconds) equals: 30.
	self assert: (normal at: #totalGadgetDamageBonus) equals: 0.10.
	self assert: (normal at: #totalGadgetRepairBonus) equals: 0.10.
	self assert: (normal at: #buffDurationSeconds) equals: 20.
	self
		assertEmpty: (rule
				effectsOnGadgetEvent: #cancel
				equippedPieces: 4
				secondsSinceLastActivation: 5
				positiveReinforcement: true
				shortCircuit: false).
	self
		assert: (rule
				effectsOnGadgetEvent: #cancel
				equippedPieces: 4
				secondsSinceLastActivation: 5
				positiveReinforcement: false
				shortCircuit: true)
		equals: normal.
	upgraded := rule
			effectsOnGadgetEvent: #cancel
			equippedPieces: 4
			secondsSinceLastActivation: 10
			positiveReinforcement: true
			shortCircuit: false.
	self assert: (upgraded at: #totalGadgetDamageBonus) equals: 0.25.
	self assert: (upgraded at: #totalGadgetRepairBonus) equals: 0.25.
	self assert: (upgraded at: #otherGadgetCooldownReductionSeconds) equals: 30.
	self assert: (upgraded at: #buffDurationSeconds) equals: 20
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testFirstSightUsesDocumentedEmptyReloadTime [
	| catalog weapon reload item |
	catalog := CIGameItemTypes buildCatalog.
	weapon := catalog typeAt: 'weapon.workbook.firstSight'.
	reload := weapon fixedAttributes
			detect: [ :attribute | attribute statIdentifier = 'emptyReloadSeconds' ].
	self assert: reload magnitude equals: 2.8.
	self assert: reload unit equals: #seconds.
	self assert: reload role equals: #intrinsic.
	self assert: reload evidence equals: 'Weapons!G8'.
	self
		assert: (weapon namedReference fieldAt: #talentOrAttribute)
		equals: '+30% HSD, +50% reload speed debuff'.
	item := CIItemGenerator new
			generate: 'firstSight'
			type: weapon id
			values: {'weaponDamage' -> 0.10} asDictionary
			from: catalog
			using: [ 0 ].
	self
		assert: (item comparisonStats collect: #statIdentifier)
		equals: #('weaponDamage' 'innateHeadshotDamage' 'emptyReloadSeconds').
	self assert: (item comparisonStats collect: #value) equals: #(0.10 0.85 2.8)
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testFixedNamedWeaponAttributesGenerateWithoutAReplacementRoll [
	| catalog generator cases weapon roll fixed item comparison |
	catalog := CIGameItemTypes buildCatalog.
	generator := CIItemGenerator new.
	cases := #(#('firstSight' 'innateHeadshotDamage' 0.85 'Weapons!O8') #('firstSight' 'emptyReloadSeconds' 2.8 'Weapons!G8') #('backupBoomstick' 'weaponDamage' 0.17 'Weapons Named + Exotics!E59') #('theMop' 'armorOnKill' 0.10 'Weapons Named + Exotics!E64') #('theWhiteDeath' 'headshotDamage' 1.37 'Weapons Named + Exotics!E76') #('ohCarol' 'headshotDamage' 1.37 'Weapons Named + Exotics!E77') #('tdiKardCustom' 'skillTier' 1 'Weapons Named + Exotics!E97')).
	cases
		do: [ :row | 
			weapon := catalog typeAt: 'weapon.workbook.' , row first.
			fixed := weapon fixedAttributes
					detect: [ :attribute | attribute statIdentifier = row second ].
			self assert: fixed evidence equals: row fourth.
			roll := row second = 'weaponDamage'
					ifTrue: [ Dictionary new ]
					ifFalse: [ {'weaponDamage' -> 0.1} asDictionary ].
			item := generator
					generate: 'named'
					type: weapon id
					values: roll
					from: catalog
					using: [ 0 ].
			comparison := item comparisonStats
					detect: [ :stat | stat statIdentifier = row second ].
			self assert: comparison value equals: row third.
			self assert: item talentIdentifier isNil.
			roll at: row second put: 0.05.
			self
				should: [ generator
						generate: 'overwrite'
						type: weapon id
						values: roll
						from: catalog
						using: [ 0 ] ]
				raise: Error ].
	self assertEmpty: (weapon fixedAttributesWhileWeaponInUse: false).
	self
		assert: (weapon fixedAttributesWhileWeaponInUse: true) first magnitude
		equals: 1
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testFullSpecializationSelectionsFitQualificationReplyBudget [
	| owner catalog shared picks profile reply |
	self startInventory.
	owner := 'specialization-profile-budget-owner'.
	catalog := CIGameItemTypes buildCatalog.
	shared := (catalog specializationNamed: 'Universal') perks.
	(catalog specializations reject: [ :each | each name = 'Universal' ])
		do: [ :definition | 
			picks := (definition perks , shared collect: #id)
					reject: [ :id | id = 'technician.enhanceddiagnostics' ].
			service
				selectSpecialization: definition name
				perks: picks
				forVerifiedUser: owner.
			profile := service specializationProfileForVerifiedUser: owner.
			self assert: (profile at: 'selectedPerks') size equals: picks size.
			reply := CIInventoryProfileGraph encodeReply: profile.
			self assert: reply notNil.
			self assert: reply size <= 4080 ]
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testFuturePerfectionUsesItsOwnStackCapAndDuration [
	| catalog scanner encounter |
	catalog := CIGameItemTypes buildCatalog.
	scanner := (catalog gadgetFamilyNamed: 'Pulse') variantNamed: 'Scanner'.
	encounter := CIGadgetEncounter
			variant: scanner
			baseTier: 0
			weapon: 'weapon'
			talent: (catalog talentAt: 'futurePerfection').
	4
		timesRepeat: [ self assert: (encounter recordWeaponKillFrom: 'weapon' at: 0) ].
	self deny: (encounter recordWeaponKillFrom: 'weapon' at: 1).
	self assert: (encounter effectiveTierAt: 18) equals: 4.
	self assert: (encounter effectiveTierAt: 19) equals: 0.
	self should: [ encounter effectiveTierAt: 18 ] raise: Error
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testGadgetEncounterOverchargeExpiresAndHonorsCooldown [
	| catalog owner type gadget weapon gear encounter |
	self startInventory.
	catalog := CIGameItemTypes buildCatalog.
	owner := 'overcharge-test-owner'.
	type := catalog typeAt: 'gadget.workbook.pulse.scanner'.
	gadget := type inventoryItem: 'scanner' values: Dictionary new.
	gadget equippedSlotIdentifier: 'GadgetLeft'.
	weapon := (catalog typeAt: 'weapon.launch.akM')
			inventoryItem: 'weapon'
			values: (Dictionary new
					at: 'weaponDamage' put: 0.1;
					yourself)
			talentIdentifier: 'futurePerfect'.
	weapon equippedSlotIdentifier: 'RangedWeapon'.
	gear := self
			gearRowsForFamily: 'morrowWorks'
			slots: #('Mask' 'Chest' 'Backpack' 'Gloves' 'KneePads')
			catalogue: catalog.
	service
		replaceReadRows: {gadget.
				weapon} , gear
		forOwner: owner.
	encounter := service
			gadgetEncounterFor: 'scanner'
			weapon: 'weapon'
			forVerifiedUser: owner.
	self assert: (encounter effectiveTierAt: 0) equals: 5.
	self deny: (encounter recordWeaponKillFrom: 'another' at: 0).
	self assert: (encounter recordWeaponKillFrom: 'weapon' at: 0).
	self assert: (encounter effectiveTierAt: 0) equals: 6.
	self assert: (encounter recordWeaponKillFrom: 'weapon' at: 1).
	self assert: (encounter effectiveTierAt: 1) equals: #overcharge.
	self assert: ((encounter statsAt: 1) at: 'Duration') equals: 24.
	self assert: (encounter overchargeEffectsAt: 1) notEmpty.
	self
		assert: (encounter activeOverchargeRuleAt: 1) kind
		equals: #weaknessExploit.
	self deny: (encounter recordWeaponKillFrom: 'weapon' at: 14).
	self assert: (encounter effectiveTierAt: 16) equals: 5.
	self assertEmpty: (encounter overchargeEffectsAt: 16).
	self assert: (encounter activeOverchargeRuleAt: 16) isNil.
	self assert: (encounter recordWeaponKillFrom: 'weapon' at: 90).
	self deny: (encounter recordWeaponKillFrom: 'weapon' at: 90).
	self assert: (encounter recordWeaponKillFrom: 'weapon' at: 91).
	self assert: (encounter effectiveTierAt: 91) equals: #overcharge
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testGadgetUpgradeAddsCountAndPreservesUnspecifiedTierValues [
	| catalog type loadout upgrades stats base |
	catalog := CIGameItemTypes buildCatalog.
	type := catalog typeAt: 'gadget.workbook.turret.artillery'.
	loadout := catalog
			specializationLoadoutNamed: 'Demolitionist'
			selected: #('demolitionist.artilleryturret' 'demolitionist.cyclonemagazine' 'demolitionist.shdcpuv2').
	upgrades := loadout resolvedGadgetUpgradesForType: type id.
	base := type statsAtUtilityTier: 0.
	stats := type workbookVariantDefinition
			knownStatsAtTier: 0
			withSpecializationUpgrades: upgrades.
	self assert: (stats at: 'Ammo') equals: (base at: 'Ammo') + 1.
	self assert: (stats at: 'Damage') closeTo: (base at: 'Damage') * 1.10.
	self assert: (stats at: 'PvP Damage') equals: (base at: 'PvP Damage').
	stats := type workbookVariantDefinition
			knownStatsAtTier: 6
			withSpecializationUpgrades: upgrades.
	self deny: (stats includesKey: 'Ammo').
	self deny: (stats includesKey: 'Damage').
	self assert: stats equals: (type statsAtUtilityTier: 6)
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testGearFamilyThresholdsAndModeValues [
	| catalog evaluator rows pve pvp rook |
	catalog := CIGameItemTypes buildCatalog.
	evaluator := CILoadoutFamilyEvaluator new.
	self
		assert: (catalog gearFamilies
				count: [ :family | (family id beginsWith: 'brand.workbook.') not ])
		equals: 5.
	rows := self
			gearRowsForFamily: 'rookStandard'
			slots: #('Mask' 'Gloves')
			catalogue: catalog.
	rook := [ :mode | 
		(evaluator
			evaluateRows: rows
			catalogue: catalog
			mode: mode) detect: [ :activation | activation family id = 'rookStandard' ] ].
	pve := rook value: #pve.
	pvp := rook value: #pvp.
	self assert: (pve activeTiers collect: #pieceCount) equals: #(1 2).
	self
		assert: (pve modifiers detect: [ :effect | effect stat = #hazardProtection ]) magnitude
		equals: 0.20.
	self
		assert: (pvp modifiers detect: [ :effect | effect stat = #hazardProtection ]) magnitude
		equals: 0.15.
	self assert: pvp activeTiers last evidence equals: 'Brandsets!F6,L6'
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testGearTalentTimersAndThresholds [
	| catalog make obliterate armor overwatch composure arms |
	catalog := CIGameItemTypes buildCatalog.
	make := [ :id | CIGearTalentEncounter talent: (catalog talentAt: id) ].
	obliterate := make value: 'perfectObliterate'.
	obliterate recordEnemyShotCritical: false at: 0.
	self assert: (obliterate totalWeaponDamageBonusAt: 0) equals: 0.
	25 timesRepeat: [ obliterate recordEnemyShotCritical: true at: 1 ].
	self assert: (obliterate totalWeaponDamageBonusAt: 10) closeTo: 0.24.
	self assert: (obliterate totalWeaponDamageBonusAt: 11) equals: 0.
	armor := make value: 'unbreakable'.
	self assert: (armor armorRepairFractionOnDepletionAt: 0) equals: 0.95.
	self assert: (armor armorRepairFractionOnDepletionAt: 59) equals: 0.
	self assert: (armor armorRepairFractionOnDepletionAt: 60) equals: 0.95.
	self
		assert: ((make value: 'perfectUnbreakable') armorRepairFractionOnDepletionAt: 0)
		equals: 1.
	overwatch := make value: 'perfectOverwatch'.
	overwatch coverState: #inCover at: 0.
	self assert: ((overwatch squadDamageBonusesAt: 7) at: #weaponDamage) equals: 0.
	overwatch coverState: #coverMove at: 8.
	self
		assert: ((overwatch squadDamageBonusesAt: 18) at: #skillDamage)
		equals: 0.14.
	overwatch coverState: #inCover at: 19.
	self
		assert: ((overwatch squadDamageBonusesAt: 19) at: #weaponDamage)
		equals: 0.14.
	overwatch coverState: #exposed at: 20.
	self assert: ((overwatch squadDamageBonusesAt: 20) at: #weaponDamage) equals: 0.
	composure := make value: 'perfectComposure'.
	composure coverState: #inCover at: 0.
	self assert: (composure totalWeaponDamageBonusAt: 0) equals: 0.20.
	composure coverState: #coverMove at: 1.
	self assert: (composure totalWeaponDamageBonusAt: 1) equals: 0.
	arms := make value: 'perfectCombinedArms'.
	arms recordEnemyShotCritical: false at: 0.
	self assert: (arms totalSkillDamageBonusAt: 2) equals: 0.30.
	self assert: (arms totalSkillDamageBonusAt: 3) equals: 0
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testGeneratedWeaponClassRollSurvivesInventoryRestart [
	| weapon owner retained |
	self startInventory.
	owner := 'weapon-class-roll-owner'.
	weapon := service
			grantItem: 'pp19'
			type: 'weapon.launch.pp19'
			values: {'weaponDamage' -> 0.10.
					'criticalHitChance' -> 0.19} asDictionary
			forVerifiedUser: owner.
	service stop.
	service := nil.
	self startInventory.
	retained := (service
			rowsForVerifiedUser: owner
			offset: 0
			limit: 32) first.
	self assert: retained talentIdentifier equals: weapon talentIdentifier.
	self
		assert: retained comparisonStats last statIdentifier
		equals: 'criticalHitChance'.
	self assert: retained comparisonStats last value equals: 0.19
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testGunnerEncounterUsesSelectedPerksAndDocumentedTiming [
	| owner encounter grant |
	self startInventory.
	owner := 'gunner-encounter-owner'.
	service
		selectSpecialization: 'Gunner'
		perks: #('gunner.barrage' 'gunner.coupler' 'gunner.supplyline')
		forVerifiedUser: owner.
	encounter := service
			specializationEncounterForVerifiedUser: owner
			mode: #pve
			startedAt: 10.
	self assert: (encounter rateOfFireBonusAt: 10) equals: 0.
	encounter recordEnemyKillAt: 11.
	self assert: (encounter rateOfFireBonusAt: 15) equals: 0.05.
	self assert: (encounter rateOfFireBonusAt: 16) equals: 0.
	self assert: (encounter reloadSpeedBonusForNextReloadAt: 20) equals: 0.
	self assert: (encounter reloadSpeedBonusForNextReloadAt: 21) equals: 0.
	self assert: (encounter reloadSpeedBonusForNextReloadAt: 22) equals: 0.50.
	self assert: (encounter supplyLineGrantsThrough: 69) isNil.
	grant := encounter supplyLineGrantsThrough: 70.
	self assert: grant ticks equals: 1.
	self assert: grant personalFraction equals: 0.10.
	self assert: grant partyFraction equals: 0.05.
	self assert: (encounter supplyLineGrantsThrough: 70) isNil.
	self assert: (encounter supplyLineGrantsThrough: 190) ticks equals: 2
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testHuddleUsesSetThresholdAndIndependentCooldownModifiers [
	| catalog reference rule |
	catalog := CIGameItemTypes buildCatalog.
	reference := catalog gearFamilyReferenceAt: 'Measured Assembly'.
	rule := reference gadgetTalentRule.
	self assert: (rule evidence includesSubstring: 'Gearsets!E31:G31').
	self
		assert: (rule gadgetTierBonusForAlliesInRange: 2 equippedPieces: 3)
		equals: 0.
	self
		assert: (rule gadgetTierBonusForAlliesInRange: 2 equippedPieces: 4)
		equals: 2.
	self assert: (rule overchargeCooldownSecondsWithHivemind: false) equals: 40.
	self assert: (rule overchargeCooldownSecondsWithHivemind: true) equals: 25.
	self
		assert: (rule
				overchargeSecondsAtGadgetTier: 6
				equippedPieces: 3
				secondsQualifying: 4
				secondsSinceLastActivation: nil
				hivemind: false)
		equals: 0.
	self
		assert: (rule
				overchargeSecondsAtGadgetTier: 6
				equippedPieces: 4
				secondsQualifying: 3.99
				secondsSinceLastActivation: nil
				hivemind: false)
		equals: 0.
	self
		assert: (rule
				overchargeSecondsAtGadgetTier: 5
				equippedPieces: 4
				secondsQualifying: 4
				secondsSinceLastActivation: nil
				hivemind: false)
		equals: 0.
	self
		assert: (rule
				overchargeSecondsAtGadgetTier: 6
				equippedPieces: 4
				secondsQualifying: 4
				secondsSinceLastActivation: 25
				hivemind: false)
		equals: 0.
	self
		assert: (rule
				overchargeSecondsAtGadgetTier: 6
				equippedPieces: 4
				secondsQualifying: 4
				secondsSinceLastActivation: 25
				hivemind: true)
		equals: 15.
	self
		assert: (rule
				overchargeSecondsAtGadgetTier: #overcharge
				equippedPieces: 4
				secondsQualifying: 4
				secondsSinceLastActivation: nil
				hivemind: false) isNil.
	self
		assert: (rule interceptionCooldownSecondsWithSmartCooperation: false)
		equals: 10.
	self
		assert: (rule interceptionCooldownSecondsWithSmartCooperation: true)
		equals: 1.
	self assert: rule reportedInterceptionSpeedBonusPerAlly equals: 0.20.
	self
		assert: (rule
				interceptsTargetEnteringRange: #mortar
				equippedPieces: 4
				cooldownReady: true).
	self
		assert: (rule
				interceptsTargetEnteringRange: #enemyGadget
				equippedPieces: 4
				cooldownReady: true).
	self
		deny: (rule
				interceptsTargetEnteringRange: #allyGadget
				equippedPieces: 4
				cooldownReady: true).
	self
		deny: (rule
				interceptsTargetEnteringRange: #mortar
				equippedPieces: 4
				cooldownReady: false)
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testInSyncEffectsOverlapAndExpireIndependently [
	| owner catalog weapon encounter |
	self startInventory.
	owner := 'weapon-talent-owner'.
	catalog := CIGameItemTypes buildCatalog.
	weapon := (catalog typeAt: 'weapon.launch.akM')
			inventoryItem: 'weapon'
			values: (Dictionary new
					at: 'weaponDamage' put: 0.1;
					yourself)
			talentIdentifier: 'perfectInSync'.
	service replaceReadRows: {weapon} forOwner: owner.
	self
		should: [ service weaponTalentEncounterFor: 'weapon' forVerifiedUser: owner ]
		raise: Error.
	weapon := weapon copy.
	weapon equippedSlotIdentifier: 'RangedWeapon'.
	service replaceReadRows: {weapon} forOwner: owner.
	encounter := service weaponTalentEncounterFor: 'weapon' forVerifiedUser: owner.
	encounter
		recordEnemyHitFrom: 'weapon'
		critical: false
		at: 1.
	self assert: ((encounter damageBonusesAt: 1) at: #skillDamage) equals: 0.20.
	encounter recordGadgetUseOrDamageAt: 3.
	self assert: ((encounter damageBonusesAt: 3) at: #skillDamage) equals: 0.40.
	self assert: ((encounter damageBonusesAt: 3) at: #weaponDamage) equals: 0.40.
	self assert: ((encounter damageBonusesAt: 6) at: #skillDamage) equals: 0.
	self assert: ((encounter damageBonusesAt: 6) at: #weaponDamage) equals: 0.20.
	self assert: ((encounter damageBonusesAt: 8) at: #weaponDamage) equals: 0
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testInstalledModEffectsUseWorkbookMagazineAndOwnedRoll [
	| catalog store owner value chatterbox capacitor vest gearMod report magazine gear graph row |
	catalog := CIGameItemTypes buildCatalog.
	store := CIInventoryReadStore new.
	owner := 'mod-evaluation-owner'.
	value := Dictionary new
			at: 'weaponDamage' put: 0.1;
			yourself.
	chatterbox := store
			grantItem: 'chatterbox'
			type: 'weapon.launch.chatterbox'
			values: value
			from: catalog
			forOwner: owner.
	capacitor := store
			grantItem: 'capacitor'
			type: 'weapon.launch.capacitor'
			values: value
			from: catalog
			forOwner: owner.
	store
		grantItem: 'vest'
		type: 'gear.launch.vossAndVale.chest'
		values: value
		from: catalog
		forOwner: owner.
	gearMod := store
			grantGearMod: 'gear-mod'
			definition: 'gearMod.criticalHitChance'
			tier: 2
			value: 0.04
			from: catalog
			forOwner: owner.
	vest := store
			installMod: gearMod itemIdentifier
			on: 'vest'
			socket: 'gearMod'
			from: catalog
			forOwner: owner.
	report := CIEquipmentModEvaluator new
			evaluateEquipment: {chatterbox.
					capacitor.
					vest}
			owned: (store allRowsForOwner: owner)
			catalogue: catalog modCatalogue.
	self assertEmpty: report unresolved.
	self
		assert: (report
				magazineCapacityFor: chatterbox
				base: (catalog typeAt: chatterbox definitionIdentifier) baseMagazineCapacity)
		equals: 60.
	self
		assert: (report
				magazineCapacityFor: capacitor
				base: (catalog typeAt: capacitor definitionIdentifier) baseMagazineCapacity)
		equals: 41.
	magazine := (report contributionsFor: #magazineCapacity on: 'chatterbox') first.
	self assert: magazine value equals: 10.
	self assert: magazine evidence equals: 'Weapons Named + Exotics!F130'.
	gear := (report contributionsFor: #criticalHitChance on: 'vest') first.
	self assert: gear value equals: 0.04.
	self assert: gear operation equals: #percent.
	row := chatterbox copy.
	row equippedSlotIdentifier: 'RangedWeapon'.
	graph := CIInventoryProfileGraph
			forVerifiedUser: owner
			rows: {row.
					vest.
					gearMod}
			savedSets: Dictionary new
			catalog: catalog.
	self assert: ((STON toString: graph) includesSubstring: '60 rounds').
	row := vest withMod: 'missing-mod' inSocket: 'gearMod'.
	report := CIEquipmentModEvaluator new
			evaluateEquipment: {row}
			owned: #()
			catalogue: catalog modCatalogue.
	self assertEmpty: report contributions.
	self assert: report unresolved equals: #(#('vest' 'gearMod' 'missing-mod'))
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testJupiterCombatSpreadUsesRangeAndDocumentedRefresh [
	| owner catalog rows encounter statuses targets result |
	self startInventory.
	owner := 'jupiter-combat'.
	catalog := CIGameItemTypes buildCatalog.
	rows := self
			gearRowsForFamily: 'jupiterTechnologies'
			slots: #('Mask' 'Chest' 'Backpack' 'Gloves' 'KneePads')
			catalogue: catalog.
	rows second equippedSlotIdentifier: nil.
	service replaceReadRows: rows forOwner: owner.
	encounter := service classifiedEncounterForVerifiedUser: owner mode: #pve.
	statuses := {CICombatStatusApplication
				status: 'burn'
				target: 'defeated'
				durationSeconds: 8.
			CICombatStatusApplication
				status: 'shock'
				target: 'another'
				durationSeconds: 6}.
	targets := {'defeated' -> 0.
			'ten' -> 10.
			'fifteen' -> 15.
			'outside' -> 16} asDictionary.
	result := encounter
			spreadOnKillOf: 'defeated'
			statuses: statuses
			targetsAtDistances: targets.
	self assert: (result collect: #targetIdentifier) equals: #('ten').
	self assert: result first statusIdentifier equals: 'burn'.
	self assert: result first durationSeconds equals: 4.
	self
		assert: (encounter jupiterDamageMultiplierForStatusAffected: true)
		equals: 1.30.
	self
		assert: (encounter jupiterDamageMultiplierForStatusAffected: false)
		equals: 1.
	rows second equippedSlotIdentifier: 'Chest'.
	rows third equippedSlotIdentifier: nil.
	service replaceReadRows: rows forOwner: owner.
	service
		updateClassifiedEncounter: encounter
		forVerifiedUser: owner
		mode: #pve.
	result := encounter
			spreadOnKillOf: 'defeated'
			statuses: statuses
			targetsAtDistances: targets.
	self
		assert: (result collect: #targetIdentifier) asSet
		equals: #('ten' 'fifteen') asSet.
	self
		assert: (result allSatisfy: [ :application | application durationSeconds = 6 ]).
	self
		assert: (encounter jupiterDamageMultiplierForStatusAffected: true)
		equals: 1.
	rows second equippedSlotIdentifier: nil.
	service replaceReadRows: rows forOwner: owner.
	service
		updateClassifiedEncounter: encounter
		forVerifiedUser: owner
		mode: #pve.
	self
		assertEmpty: (encounter
				spreadOnKillOf: 'defeated'
				statuses: statuses
				targetsAtDistances: targets)
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testLaunchInventoryAndTalentsSurviveRestart [
	| owner catalog before after |
	owner := 'launch-inventory-owner'.
	catalog := CIGameItemTypes buildCatalog.
	self startInventory.
	self
		assert: (service provisionLaunchInventoryForVerifiedUser: owner)
		equals: 53.
	before := (self rowsFor: owner)
			collect: [ :item | 
				{item itemIdentifier.
					item definitionIdentifier.
					item talentIdentifier} ].
	self assert: (before count: [ :entry | entry third notNil ]) equals: 38.
	before
		do: [ :entry | 
			| pool |
			pool := catalog talentPoolFor: entry second.
			pool
				ifEmpty: [ self assert: entry third isNil ]
				ifNotEmpty: [ self assert: (pool includes: entry third) ] ].
	service stop.
	service := nil.
	self startInventory.
	after := (self rowsFor: owner)
			collect: [ :item | 
				{item itemIdentifier.
					item definitionIdentifier.
					item talentIdentifier} ].
	self assert: after equals: before.
	self assert: (service provisionLaunchInventoryForVerifiedUser: owner) equals: 0.
	self assertEmpty: (self rowsFor: 'another-owner')
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testLiquidCoolingIncreasesArtificerDuration [
	| catalog typeIdentifier variant loadout upgrades liquid base effective |
	catalog := CIGameItemTypes buildCatalog.
	typeIdentifier := 'gadget.workbook.hive.artificer'.
	variant := (catalog typeAt: typeIdentifier) workbookVariantDefinition.
	loadout := catalog
			specializationLoadoutNamed: 'Technician'
			selected: #('technician.artificer' 'technician.upgradedsensorpackage' 'technician.liquidcooling').
	upgrades := loadout resolvedGadgetUpgradesForType: typeIdentifier.
	liquid := upgrades
			detect: [ :upgrade | upgrade resolvedTrack label = 'Duration' ].
	self assert: liquid resolvedMagnitude equals: 0.10.
	self deny: liquid reviewEvidence isEmpty.
	base := variant knownStatsAtTier: 0 withSpecializationUpgrades: #().
	effective := variant knownStatsAtTier: 0 withSpecializationUpgrades: upgrades.
	self assert: (base at: 'Duration') equals: 180.
	self assert: (effective at: 'Duration') closeTo: 198.
	self assert: (effective at: 'Refill Speed') equals: (base at: 'Refill Speed').
	self assert: (effective at: 'Buff Duration') equals: (base at: 'Buff Duration')
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testLootAwardPersistsSelectionAndGeneratedTalent [
	| catalog loot pool entries owner store path award samples calls reloaded noValues values |
	catalog := CIGameItemTypes buildCatalog.
	loot := catalog lootCatalogue.
	entries := #('weapon.launch.akM' 'weapon.launch.scorpio')
			collect: [ :id | 
				CILootPoolEntry
					item: (catalog typeAt: id)
					weight: 1
					requiring: nil
					evidence: 'Test fixture' ].
	pool := CILootPool
			id: 'testLoot'
			source: (loot poolAt: 'exoticCaches') source
			entries: entries
			complete: true.
	loot register: pool.
	owner := 'loot-test-owner'.
	path := (directory / 'loot.ston') fullName.
	store := CIInventorySnapshotStore at: path.
	noValues := [ :type | Dictionary new ].
	self
		should: [ store
				grantLoot: 'failed'
				pool: 'testLoot'
				valuesFrom: noValues
				satisfying: [ :entry | true ]
				from: catalog
				forOwner: owner
				using: [ 0.0 ] ]
		raise: Error.
	self assertEmpty: (store allRowsForOwner: owner).
	self assert: path asFileReference exists not.
	values := [ :type | 
		Dictionary new
			at: 'weaponDamage' put: 0.1;
			yourself ].
	calls := 0.
	samples := [ calls := calls + 1.
		#(0.2 0.0) at: calls ].
	award := store
			grantLoot: 'loot-award'
			pool: 'testLoot'
			valuesFrom: values
			satisfying: [ :entry | true ]
			from: catalog
			forOwner: owner
			using: samples.
	self assert: calls equals: 2.
	self assert: award definitionIdentifier equals: 'weapon.launch.akM'.
	self assert: award talentIdentifier equals: 'optimist'.
	reloaded := ((CIInventorySnapshotStore at: path) allRowsForOwner: owner) first.
	self assert: reloaded itemIdentifier equals: award itemIdentifier.
	self assert: reloaded lootPoolIdentifier equals: 'testLoot'.
	self assert: reloaded talentIdentifier equals: award talentIdentifier.
	self assert: reloaded comparisonStats first value equals: 0.1
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testNamedFixedAndExoticMinorAttributesSurviveInventoryRestart [
	| owner rows named exotic |
	self startInventory.
	owner := 'variant-attribute-restart'.
	service
		grantItem: 'mop'
		type: 'weapon.workbook.theMop'
		values: {'weaponDamage' -> 0.1} asDictionary
		forVerifiedUser: owner.
	service
		grantItem: 'cap'
		type: 'weapon.launch.capacitor'
		values: {'weaponDamage' -> 0.12.
				'damageToArmor' -> 0.10.
				'minorAttributeIdentifier' -> 'weapon.minor.reloadSpeed'.
				'minorAttributeValue' -> 0.11} asDictionary
		forVerifiedUser: owner.
	service stop.
	service := nil.
	self startInventory.
	rows := service
			rowsForVerifiedUser: owner
			offset: 0
			limit: 32.
	named := rows detect: [ :row | row itemIdentifier = 'mop' ].
	exotic := rows detect: [ :row | row itemIdentifier = 'cap' ].
	self assert: named comparisonStats last value equals: 0.10.
	self
		assert: exotic comparisonStats last statIdentifier
		equals: 'weapon.minor.reloadSpeed'.
	self assert: exotic comparisonStats last value equals: 0.11
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testNamedGearLayoutsEnforceFixedRollsExclusionsAndSocketCounts [
	| catalog type layout path store owner punch chill missing roll snapshot |
	catalog := CIGameItemTypes buildCatalog.
	type := catalog typeAt: 'gear.workbook.punchDrunk'.
	layout := type generationLayout.
	self assert: (layout slots collect: #id) equals: #('core' 'minor1' 'minor2').
	self assert: layout slots second fixedValue equals: 0.20.
	self
		deny: (layout slots third eligibleAttributeIds includes: 'gear.minor.headshotDamage').
	self assert: (type sourceInformation at: #acquisition) equals: 'LZ'.
	path := (directory / 'named-gear.ston') fullName.
	store := CIInventorySnapshotStore at: path.
	owner := 'named-layout-owner'.
	missing := Dictionary new
			at: 'core' put: 0.10;
			yourself.
	self
		should: [ store
				grantItem: 'missing'
				type: type id
				values: missing
				from: catalog
				forOwner: owner ]
		raise: Error.
	roll := CIGearAttributeRoll attribute: 'gear.minor.headshotDamage' value: 0.05.
	self
		should: [ store
				grantItem: 'excluded'
				type: type id
				values: (missing copy
						at: 'minor2' put: roll;
						yourself)
				from: catalog
				forOwner: owner ]
		raise: Error.
	roll := CIGearAttributeRoll
			attribute: 'gear.minor.criticalHitChance'
			value: 0.07.
	self
		should: [ store
				grantItem: 'over-cap'
				type: type id
				values: (missing copy
						at: 'minor2' put: roll;
						yourself)
				from: catalog
				forOwner: owner ]
		raise: Error.
	self assertEmpty: (store allRowsForOwner: owner).
	roll := CIGearAttributeRoll
			attribute: 'gear.minor.criticalHitChance'
			value: 0.06.
	punch := store
			grantItem: 'punch'
			type: type id
			values: (missing copy
					at: 'minor2' put: roll;
					yourself)
			from: catalog
			forOwner: owner.
	self assert: punch rolledAttributes first value equals: 0.20.
	self assert: punch rolledAttributes second value equals: 0.06.
	self assert: (punch modSlots collect: #slotIdentifier) equals: #('gearMod1').
	chill := store
			grantItem: 'chill'
			type: 'gear.workbook.chillOut'
			values: (Dictionary new
					at: 'core' put: 170000;
					at: 'minor1' put: roll;
					yourself)
			from: catalog
			forOwner: owner.
	self assert: chill rolledAttributes size equals: 1.
	self
		assert: (chill modSlots collect: #slotIdentifier)
		equals: #('gearMod1' 'gearMod2').
	snapshot := (CIInventorySnapshotStore at: path) allRowsForOwner: owner.
	self
		assert: (snapshot first rolledAttributes collect: #generationSlotIdentifier)
		equals: #('minor1' 'minor2').
	self
		assert: snapshot second primaryAttribute generationSlotIdentifier
		equals: 'core'
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testNamedGearReferencesPreserveSplitRowsAndExposeSupportedLayouts [
	| catalog reference rows store minor1 minor2 values courier gloves |
	catalog := CIGameItemTypes buildCatalog.
	rows := catalog namedGearReferences.
	self assert: (rows count: [ :each | each kind = #named ]) equals: 65.
	self assert: (rows count: [ :each | each kind = #exotic ]) equals: 32.
	self
		assert: (rows count: [ :each | each itemDefinitionIdentifier notNil ])
		equals: 13.
	reference := catalog namedGearReferenceAt: 'Vile'.
	self assert: (reference fieldAt: #talent) equals: 'Toxic Delivery'.
	self
		assert: (reference evidenceForField: #name)
		equals: 'Gear Named + Exotics!D69'.
	self
		assert: (reference evidenceForField: #talent)
		equals: 'Gear Named + Exotics!F68'.
	reference := catalog namedGearReferenceAt: 'Forge'.
	self assert: reference slot equals: 'Holster'.
	self assert: reference itemDefinitionIdentifier isNil.
	reference := catalog namedGearReferenceAt: 'The Courier'.
	self
		assert: reference itemDefinitionIdentifier
		equals: 'gear.workbook.theCourier'.
	store := CIInventoryReadStore new.
	minor1 := CIGearAttributeRoll
			attribute: 'gear.minor.criticalHitChance'
			value: 0.05.
	minor2 := CIGearAttributeRoll
			attribute: 'gear.minor.criticalHitDamage'
			value: 0.10.
	values := Dictionary new
			at: 'core' put: 50000;
			at: 'minor1' put: minor1;
			at: 'minor2' put: minor2;
			yourself.
	courier := store
			grantItem: 'courier'
			type: reference itemDefinitionIdentifier
			values: values
			from: catalog
			forOwner: 'owner'
			using: [ self error: 'Fixed talent must not draw' ].
	self assert: courier talentIdentifier equals: 'perfectCreepingDeath'.
	self assert: courier gearSlotIdentifier equals: 'Backpack'.
	self assert: courier modSlots size equals: 1.
	gloves := store
			grantItem: 'gloves'
			type: 'gear.workbook.firmHandshake'
			values: (Dictionary new
					at: 'core' put: 0.10;
					at: 'minor2' put: minor1;
					yourself)
			from: catalog
			forOwner: 'owner'.
	self assert: gloves gearSlotIdentifier equals: 'Gloves'.
	self assert: gloves rolledAttributes first value equals: 0.16.
	self assertEmpty: gloves modSlots
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testOverclockUsesWorkbookRangeAndReducesOnlyActiveCooldowns [
	| catalog reference named remaining values item |
	catalog := CIGameItemTypes buildCatalog.
	reference := catalog talentReferenceAt: 'Gear Talents!D46'.
	remaining := {#hive -> 1.
			#pulse -> 0.1.
			#shield -> 0} asDictionary.
	{{reference talentIdentifier.
			7.
			0.25.
			0.8}.
		{reference perfectTalentIdentifier.
			15.
			0.30.
			0.4}}
		do: [ :row | 
			| encounter radius result |
			encounter := CIGearTalentEncounter talent: (catalog talentAt: row first).
			radius := row second.
			self
				assert: (encounter
						overclockReloadSpeedBonusFor: #self
						distanceFromDeployedGadgetMetres: radius)
				equals: row third.
			self
				assert: (encounter
						overclockReloadSpeedBonusFor: #ally
						distanceFromDeployedGadgetMetres: radius + 0.01)
				equals: 0.
			self
				assert: (encounter
						overclockReloadSpeedBonusFor: #enemy
						distanceFromDeployedGadgetMetres: radius)
				equals: 0.
			self
				assert: (encounter
						overclockReloadSpeedBonusFor: #ally
						distanceFromDeployedGadgetMetres: nil)
				equals: 0.
			result := encounter
					overclockCooldownsAfterTickFor: #ally
					distanceFromDeployedGadgetMetres: radius
					remainingGadgetCooldowns: remaining.
			self
				assert: result
				equals: {#hive -> row fourth.
						#pulse -> 0.
						#shield -> 0} asDictionary.
			self
				assert: (encounter
						overclockCooldownsAfterTickFor: #ally
						distanceFromDeployedGadgetMetres: radius + 1
						remainingGadgetCooldowns: remaining)
				equals: remaining ].
	self assert: (remaining at: #hive) equals: 1.
	named := catalog namedGearReferenceAt: 'Hermano'.
	values := {'core' -> 50000.
			'minor1'
				-> (CIGearAttributeRoll attribute: 'gear.minor.criticalHitChance' value: 0.05).
			'minor2'
				-> (CIGearAttributeRoll attribute: 'gear.minor.criticalHitDamage' value: 0.10)}
			asDictionary.
	item := CIInventoryReadStore new
			grantItem: 'hermano'
			type: named itemDefinitionIdentifier
			values: values
			from: catalog
			forOwner: 'owner'
			using: [ self error: 'Fixed talent must not draw' ].
	self assert: item talentIdentifier equals: reference perfectTalentIdentifier.
	self assert: item gearSlotIdentifier equals: 'Backpack'.
	self assert: item modSlots size equals: 1
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testPathfinderDraftMagritteValidationAndRevisionRegistration [
	| catalog id baseline draft field restored path released |
	catalog := CIGameItemTypes buildCatalog.
	id := 'weapon.ranged.pathfinder'.
	baseline := catalog activeWeaponRevisionFor: id.
	self assert: baseline state equals: #baseline.
	self assert: baseline magazineCapacity equals: 30.
	self assert: baseline presentation missingBindings size equals: 16.
	self should: [ baseline magazineCapacity: 31 ] raise: Error.
	self should: [ baseline presentation icon: '/Game/Test' ] raise: Error.
	draft := baseline draftForNextRevision.
	field := draft magritteDescription children
			detect: [ :each | each label = 'Magazine capacity (rounds)' ].
	self deny: field isReadOnly.
	self should: [ field validate: 0 ] raise: Error.
	field validate: 31.
	field write: 31 to: draft.
	draft presentation icon: '/Game/Test/Icon'.
	path := directory / 'pathfinder-draft.ston'.
	draft writeDraftTo: path.
	restored := CIWeaponDefinitionRevision readDraftFrom: path.
	self assert: restored revision equals: 2.
	self assert: restored magazineCapacity equals: 31.
	self assert: restored presentation icon equals: '/Game/Test/Icon'.
	self assert: catalog weaponRevisions size equals: 1.
	self should: [ catalog publishWeaponDraft: restored ] raise: Error.
	restored presentation magritteDescription children
		do: [ :binding | binding write: '/Game/Test/FixtureBinding' to: restored presentation ].
	released := catalog publishWeaponDraft: restored.
	restored magazineCapacity: 32.
	self assert: released magazineCapacity equals: 31.
	self assert: (catalog typeAt: id) baseMagazineCapacity equals: 31.
	self assert: (catalog weaponRevisionFor: id number: 1) identicalTo: baseline.
	self should: [ catalog publishWeaponDraft: restored ] raise: Error
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testPathfinderGrantPinsDefinitionAndRolledTalentAcrossReload [
	| catalog id store path item restored revision encounter |
	catalog := CIGameItemTypes buildCatalog.
	id := 'weapon.ranged.pathfinder'.
	path := (directory / 'pathfinder-inventory.ston') fullName.
	store := CIInventorySnapshotStore at: path.
	item := store
			grantItem: 'pathfinder-instance'
			type: id
			values: {'weaponDamage' -> 0.05} asDictionary
			from: catalog
			forOwner: 'rifle-test-owner'
			using: [ 0 ].
	self
		assert: item weaponDefinitionRevision
		identicalTo: (catalog activeWeaponRevisionFor: id).
	restored := ((CIInventorySnapshotStore at: path)
			allRowsForOwner: 'rifle-test-owner') first.
	self assert: restored itemIdentifier equals: 'pathfinder-instance'.
	self assert: restored talentIdentifier equals: 'optimist'.
	self assert: restored comparisonStats first value equals: 0.05.
	revision := restored weaponDefinitionRevision.
	self assert: revision definitionIdentifier equals: id.
	self assert: revision revision equals: 1.
	self assert: revision weaponDamage equals: 25.
	self assert: revision magazineCapacity equals: 30.
	encounter := CIWeaponTalentEncounter
			weapon: restored itemIdentifier
			talent: (revision talentAt: restored talentIdentifier).
	self
		assert: (encounter weaponDamageBonusForMagazine: 30 remaining: 28)
		equals: 0.
	self
		assert: (encounter weaponDamageBonusForMagazine: 30 remaining: 27)
		equals: 0.035
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testPrototypeConversionRequiresEligibleQualityLevelAndGrade [
	| catalog rule capacitor |
	catalog := CIGameItemTypes buildCatalog.
	rule := catalog attributeCatalogue ruleAt: 'prototype.conversion'.
	capacitor := catalog weaponReferences
			detect: [ :reference | reference name = 'Capacitor' and: [ reference kind = #exotic ] ].
	self assert: rule sourceQualities equals: #(highEnd named gearSet).
	self assert: rule requiredItemLevel equals: 40.
	self assert: rule requiredItemGrade equals: 30.
	self assert: rule requiredPrototypeCores equals: 1.
	self
		deny: (rule
				eligibilityForQuality: capacitor kind
				itemLevel: 40
				itemGrade: 30
				itemEligible: nil).
	self
		deny: (rule
				eligibilityForQuality: #highEnd
				itemLevel: 39
				itemGrade: 30
				itemEligible: true).
	self
		deny: (rule
				eligibilityForQuality: #highEnd
				itemLevel: 40
				itemGrade: 29
				itemEligible: true).
	self
		deny: (rule
				eligibilityForQuality: #gearSet
				itemLevel: 40
				itemGrade: 30
				itemEligible: false).
	self
		assert: (rule
				eligibilityForQuality: #named
				itemLevel: 40
				itemGrade: 30
				itemEligible: nil) isNil.
	self
		assert: (rule
				eligibilityForQuality: #highEnd
				itemLevel: nil
				itemGrade: 30
				itemEligible: true) isNil.
	self
		assert: (rule
				eligibilityForQuality: #highEnd
				itemLevel: 40
				itemGrade: 30
				itemEligible: true)
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testProxyGeneratesWithFixedPerfectlyTamperProof [
	| catalog reference values proxy |
	catalog := CIGameItemTypes buildCatalog.
	reference := catalog namedGearReferenceAt: 'Proxy'.
	self assert: reference itemDefinitionIdentifier equals: 'gear.workbook.proxy'.
	self assert: (catalog talentAt: 'tamperProof') eligibility equals: #Chest.
	self
		assert: (catalog talentAt: 'perfectlyTamperProof') eligibility
		equals: #Backpack.
	values := Dictionary new
			at: 'core' put: 50000;
			at: 'minor1'
				put: (CIGearAttributeRoll attribute: 'gear.minor.criticalHitChance' value: 0.05);
			at: 'minor2'
				put: (CIGearAttributeRoll attribute: 'gear.minor.criticalHitDamage' value: 0.10);
			yourself.
	proxy := CIInventoryReadStore new
			grantItem: 'proxy'
			type: reference itemDefinitionIdentifier
			values: values
			from: catalog
			forOwner: 'owner'
			using: [ self error: 'Fixed talent must not draw' ].
	self assert: proxy talentIdentifier equals: 'perfectlyTamperProof'.
	self assert: proxy gearSlotIdentifier equals: 'Backpack'.
	self assert: proxy modSlots size equals: 1
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testPvPGearTalentProfilesPreserveConflictsAndUseDocumentedOverrides [
	| catalog normal perfect conflicting missing owner row encounter cover |
	catalog := CIGameItemTypes buildCatalog.
	normal := catalog talentAt: 'obliterate'.
	perfect := catalog talentAt: 'perfectObliterate'.
	self assert: ((normal parametersForMode: #pvp) at: #maxStacks) equals: 16.
	self assert: ((perfect parametersForMode: #pvp) at: #maxStacks) equals: 20.
	self assert: ((perfect parametersForMode: #pve) at: #maxStacks) equals: 24.
	conflicting := (catalog talentAt: 'unbreakable') modeProfileFor: #pvp.
	self assert: conflicting status equals: #conflicting.
	self
		assert: ((conflicting sources at: 'Gear Talents!H14') includesSubstring: '50%').
	self
		assert: ((conflicting sources at: 'Gear Talents!K14') includesSubstring: '30%').
	self assert: ((catalog talentAt: 'unbreakable') parametersForMode: #pvp) isNil.
	self
		should: [ CIGearTalentEncounter talent: (catalog talentAt: 'unbreakable') mode: #pvp ]
		raise: Error.
	missing := (catalog talentAt: 'creepingDeath') modeProfileFor: #pvp.
	self assert: missing status equals: #unspecified.
	self assert: (missing sources at: 'Gear Talents!K47') isNil.
	self startInventory.
	owner := 'pvp-talent-owner'.
	row := (catalog typeAt: 'gear.launch.vossAndVale.chest')
			inventoryItem: 'vest'
			values: (Dictionary new
					at: 'weaponDamage' put: 0.1;
					yourself)
			talentIdentifier: 'obliterate'.
	row equippedSlotIdentifier: 'Chest'.
	service replaceReadRows: {row} forOwner: owner.
	encounter := service
			gearTalentEncounterFor: 'vest'
			forVerifiedUser: owner
			mode: #pvp.
	20 timesRepeat: [ encounter recordEnemyShotCritical: true at: 0 ].
	self assert: (encounter totalWeaponDamageBonusAt: 0) closeTo: 0.16.
	self assert: (encounter totalWeaponDamageBonusAt: 10) equals: 0.
	cover := CIGearTalentEncounter
			talent: (catalog talentAt: 'perfectOverwatch')
			mode: #pvp.
	cover coverState: #inCover at: 0.
	self assert: ((cover squadDamageBonusesAt: 5) at: #weaponDamage) equals: 0.
	self assert: ((cover squadDamageBonusesAt: 6) at: #weaponDamage) equals: 0.18
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testRedLotusCombatStacksDecayAndRefreshWithLoadout [
	| owner catalog rows encounter |
	self startInventory.
	owner := 'red-lotus-combat'.
	catalog := CIGameItemTypes buildCatalog.
	rows := self
			gearRowsForFamily: 'redLotusAssault'
			slots: #('Mask' 'Chest' 'Backpack' 'Gloves' 'KneePads')
			catalogue: catalog.
	service replaceReadRows: rows forOwner: owner.
	encounter := service classifiedEncounterForVerifiedUser: owner mode: #pve.
	50 timesRepeat: [ encounter recordWeaponHit ].
	self assert: encounter decayTick equals: 49.
	2 timesRepeat: [ encounter recordWeaponHit ].
	self assert: encounter decayTick equals: 49.
	300 timesRepeat: [ encounter recordWeaponHit ].
	self assert: encounter recordWeaponHit equals: 200.
	self assert: (encounter redLotusDamageMultiplier - 2.8) abs < 0.0001.
	self assert: encounter decayTick equals: 197.
	rows second equippedSlotIdentifier: nil.
	service replaceReadRows: rows forOwner: owner.
	service
		updateClassifiedEncounter: encounter
		forVerifiedUser: owner
		mode: #pve.
	self assert: encounter recordWeaponHit equals: 100.
	self assert: (encounter redLotusDamageMultiplier - 1.9) abs < 0.0001.
	rows third equippedSlotIdentifier: nil.
	service replaceReadRows: rows forOwner: owner.
	service
		updateClassifiedEncounter: encounter
		forVerifiedUser: owner
		mode: #pve.
	self assert: encounter recordWeaponHit equals: 0.
	self assert: encounter redLotusDamageMultiplier equals: 1
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testRiggerAppliesNonRefreshingBuffAndResetsCanceledGadget [
	| catalog rule standard improved |
	catalog := CIGameItemTypes buildCatalog.
	rule := (catalog gearFamilyReferenceAt: 'Rigger') gadgetTalentRule.
	self assert: rule evidence equals: 'Gearsets!E43:G43'.
	standard := {#interactedGadgetDamageBonus -> 0.25.
			#buffDurationSeconds -> 10} asDictionary.
	improved := {#interactedGadgetDamageBonus -> 0.50.
			#buffDurationSeconds -> 10} asDictionary.
	#(use deploy changeTarget heal)
		do: [ :action | 
			self
				assert: (rule
						damageBuffOnGadgetInteraction: action
						equippedPieces: 4
						buffActive: false
						bestBuds: false)
				equals: standard ].
	self
		assert: (rule
				damageBuffOnGadgetInteraction: #heal
				equippedPieces: 4
				buffActive: false
				bestBuds: true)
		equals: improved.
	self
		assertEmpty: (rule
				damageBuffOnGadgetInteraction: #heal
				equippedPieces: 4
				buffActive: true
				bestBuds: true).
	self
		assertEmpty: (rule
				damageBuffOnGadgetInteraction: #deploy
				equippedPieces: 3
				buffActive: false
				bestBuds: false).
	self
		assertEmpty: (rule
				damageBuffOnGadgetInteraction: #cancel
				equippedPieces: 4
				buffActive: false
				bestBuds: false).
	self
		assert: (rule
				cooldownAfterGadgetEndsBy: #cancel
				remainingSeconds: 24
				equippedPieces: 4
				completeUptime: true)
		equals: 0.
	self
		assert: (rule
				cooldownAfterGadgetEndsBy: #expired
				remainingSeconds: 24
				equippedPieces: 4
				completeUptime: true)
		equals: 24.
	self
		assert: (rule
				cooldownAfterGadgetEndsBy: #destroyed
				remainingSeconds: 24
				equippedPieces: 4
				completeUptime: true)
		equals: 24.
	self
		assert: (rule
				cooldownAfterGadgetEndsBy: #cancel
				remainingSeconds: 24
				equippedPieces: 4
				completeUptime: false)
		equals: 24.
	self
		assert: (rule
				cooldownAfterGadgetEndsBy: #cancel
				remainingSeconds: 24
				equippedPieces: 3
				completeUptime: true)
		equals: 24
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testRockNRollGeneratesWithPerfectlyExtraIncludedInMagazineCapacity [
	| catalog weapon talent item acs12 |
	catalog := CIGameItemTypes buildCatalog.
	weapon := catalog typeAt: 'weapon.workbook.rockNRoll'.
	acs12 := catalog weaponReferenceAt: 'Weapons!C156'.
	talent := catalog talentAt: 'perfectlyExtra'.
	self assert: weapon statisticsReference weaponClass equals: #shotgun.
	self assert: (talent parameters at: #magazineCapacityBonus) equals: 0.50.
	self
		assert: (talent parameters at: #evidence)
		equals: 'Weapons Named + Exotics!E52'.
	self assert: (acs12 fieldAt: #baseMagazine) asNumber equals: 20.
	self assert: weapon baseMagazineCapacity equals: 30.
	self
		assert: weapon baseMagazineCapacity
		equals: (acs12 fieldAt: #baseMagazine) asNumber
				* (1 + (talent parameters at: #magazineCapacityBonus)).
	item := CIItemGenerator new
			generate: 'rockNRoll'
			type: weapon id
			values: {'weaponDamage' -> 0.10} asDictionary
			from: catalog
			using: [ 0 ].
	self assert: item talentIdentifier equals: 'perfectlyExtra'
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testRoundAfterRoundQualifiesAfterTwentySecondsAndCountsOnlyNewIntervals [
	| catalog encounter loadout rule expected |
	catalog := CIGameItemTypes buildCatalog.
	loadout := catalog
			specializationLoadoutNamed: 'Sharpshooter'
			selected: #('sharpshooter.roundafterround').
	encounter := CISpecializationEncounter
			forLoadout: loadout
			mode: #pve
			startedAt: 0.
	self
		assert: (encounter roundAfterRoundAmmoAccrualAfterCoverSeconds: 19.99) isNil.
	rule := encounter roundAfterRoundAmmoAccrualAfterCoverSeconds: 20.
	self assert: rule condition equals: #inCover.
	self assert: rule qualificationSeconds equals: 20.
	self assert: rule intervalSeconds equals: 10.
	expected := {#marksmanRifle -> 5.
			#rifle -> 5} asDictionary.
	self assert: rule roundsByTarget equals: expected.
	self assertEmpty: (rule roundsAccruedFromActiveSeconds: 0 through: 9.99).
	self
		assert: (rule roundsAccruedFromActiveSeconds: 9.99 through: 10)
		equals: expected.
	self assertEmpty: (rule roundsAccruedFromActiveSeconds: 10 through: 10).
	self
		assert: (rule roundsAccruedFromActiveSeconds: 10 through: 30.5)
		equals: {#marksmanRifle -> 10.
				#rifle -> 10} asDictionary.
	self assert: (encounter roundAfterRoundAmmoAccrualAfterCoverSeconds: 0) isNil
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSadistArmsOneBleedOnTheNextHitFromTheSameWeapon [
	| catalog encounter |
	catalog := CIGameItemTypes buildCatalog.
	encounter := CIWeaponTalentEncounter
			weapon: 'd50'
			talent: (catalog talentAt: 'perfectSadist.survivalistD50').
	self assert: (encounter weaponDamageBonusAgainstBleeding: true) equals: 0.25.
	self assert: (encounter weaponDamageBonusAgainstBleeding: false) equals: 0.
	encounter recordEnemyKillFrom: 'd50' at: 0.
	encounter recordEnemyKillFrom: 'd50' at: 1.
	encounter recordEnemyKillFrom: 'other' at: 2.
	self assert: (encounter consumeStatusOnEnemyHitFrom: 'd50' at: 2) isNil.
	encounter recordEnemyKillFrom: 'd50' at: 3.
	self assert: (encounter consumeStatusOnEnemyHitFrom: 'other' at: 4) isNil.
	self
		assert: (encounter consumeStatusOnEnemyHitFrom: 'd50' at: 4)
		equals: #bleed.
	self assert: (encounter consumeStatusOnEnemyHitFrom: 'd50' at: 5) isNil
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSavedSpecializationChangesGadgetTierAndSurvivesRestart [
	| owner catalog gadget loadout stats graph |
	self startInventory.
	owner := 'specialization-save-owner'.
	catalog := CIGameItemTypes buildCatalog.
	gadget := (catalog typeAt: 'gadget.workbook.pulse.scanner')
			inventoryItem: 'scanner'
			values: Dictionary new.
	gadget equippedSlotIdentifier: 'GadgetLeft'.
	service replaceReadRows: {gadget} forOwner: owner.
	self
		assert: ((service workbookGadgetStatsFor: 'scanner' forVerifiedUser: owner)
				at: 'Duration')
		equals: 8.
	service
		selectSpecialization: 'Technician'
		perks: #('technician.amped')
		forVerifiedUser: owner.
	self
		should: [ service
				selectSpecialization: 'Gunner'
				perks: #('technician.amped')
				forVerifiedUser: owner ]
		raise: Error.
	self assert: (service specializationLoadoutForVerifiedUser: 'other') isNil.
	service stop.
	service := nil.
	self startInventory.
	loadout := service specializationLoadoutForVerifiedUser: owner.
	self assert: loadout definition name equals: 'Technician'.
	self assert: (loadout selectedPerks collect: #id) equals: #('technician.amped').
	stats := service workbookGadgetStatsFor: 'scanner' forVerifiedUser: owner.
	self assert: (stats at: 'Duration') closeTo: 9.2.
	graph := service profileGraphForVerifiedUser: owner.
	self assert: ((STON toString: graph) includesSubstring: '9.200 s').
	service clearSpecializationForVerifiedUser: owner.
	self assert: (service specializationLoadoutForVerifiedUser: owner) isNil.
	self
		assert: ((service workbookGadgetStatsFor: 'scanner' forVerifiedUser: owner)
				at: 'Duration')
		equals: 8
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSavedSpecializationOnlyExposesItsSelectedEquipmentRewards [
	| owner rewards |
	self startInventory.
	owner := 'specialization-equipment-owner'.
	self
		assertEmpty: (service specializationEquipmentRewardPerksForVerifiedUser: owner).
	service
		selectSpecialization: 'Firewall'
		perks: #('firewall.clustergrenade' 'firewall.firestartersawedoffshotgun' 'firewall.fieryresponse')
		forVerifiedUser: owner.
	rewards := service specializationEquipmentRewardPerksForVerifiedUser: owner.
	self
		assert: (rewards collect: #id)
		equals: #('firewall.clustergrenade' 'firewall.firestartersawedoffshotgun').
	self assertEmpty: rewards first equipmentReward appliedStatuses.
	self
		assertEmpty: (service specializationEquipmentRewardPerksForVerifiedUser: 'another-owner').
	self
		assertEmpty: (service
				rowsForVerifiedUser: owner
				offset: 0
				limit: 32)
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testScorpioVenomThresholdsAndStackNineRefresh [
	| catalog scorpio outcome |
	catalog := CIGameItemTypes buildCatalog.
	scorpio := CIExoticWeaponEncounter
			weapon: 'scorpio'
			talent: (catalog talentAt: 'septicShock')
			magazineCapacity: nil.
	outcome := scorpio
			recordScorpioHitFrom: 'scorpio'
			on: 'target'
			venomStacks: 6
			pelletHitFraction: 0.5
			at: 0.
	self assert: outcome triggeredStatuses equals: #(poison disorient shock).
	self assert: outcome pelletHitFraction equals: 0.5.
	self assert: outcome damageMultiplier isNil.
	outcome := scorpio
			recordScorpioHitFrom: 'scorpio'
			on: 'target'
			venomStacks: 2
			pelletHitFraction: 1
			at: 0.
	self assert: outcome stackCount equals: 8.
	self assert: outcome damageMultiplier equals: 1.20.
	self deny: outcome refreshesDamageDebuff.
	outcome := scorpio
			recordScorpioHitFrom: 'scorpio'
			on: 'target'
			venomStacks: 2
			pelletHitFraction: 1
			at: 0.
	self assert: outcome stackCount equals: 9.
	self assert: outcome refreshesDamageDebuff.
	outcome := scorpio
			recordScorpioHitFrom: 'scorpio'
			on: 'target'
			venomStacks: 1
			pelletHitFraction: 1
			at: 10.
	self assert: outcome stackCount equals: 1.
	self assertEmpty: outcome triggeredStatuses
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testScrapingByOnlyAccruesCurrentWeaponAmmoDuringCombatCoverToCover [
	| catalog loadout encounter inactive rule |
	catalog := CIGameItemTypes buildCatalog.
	loadout := catalog
			specializationLoadoutNamed: 'Survivalist'
			selected: #('survivalist.scrapingby').
	encounter := CISpecializationEncounter
			forLoadout: loadout
			mode: #pve
			startedAt: 0.
	inactive := CISpecializationEncounter
			forLoadout: (catalog specializationLoadoutNamed: 'Survivalist' selected: #())
			mode: #pve
			startedAt: 0.
	self
		assert: (encounter scrapingByAmmoAccrualDuringCoverToCover: true inCombat: false) isNil.
	self
		assert: (encounter scrapingByAmmoAccrualDuringCoverToCover: false inCombat: true) isNil.
	self
		assert: (inactive scrapingByAmmoAccrualDuringCoverToCover: true inCombat: true) isNil.
	rule := encounter scrapingByAmmoAccrualDuringCoverToCover: true inCombat: true.
	self assert: rule condition equals: #coverToCoverInCombat.
	self assert: rule intervalSeconds equals: 1.
	self assertEmpty: (rule roundsAccruedFromActiveSeconds: 0 through: 0.99).
	self
		assert: (rule roundsAccruedFromActiveSeconds: 0.99 through: 2.2)
		equals: {#currentWeapon -> 10} asDictionary.
	self assertEmpty: (rule roundsAccruedFromActiveSeconds: 2.2 through: 2.9).
	self should: [ rule roundsAccruedFromActiveSeconds: 1 through: 0 ] raise: Error
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSelectedGadgetUpgradesReachInventoryInspectorAndEncounter [
	| owner catalog tactician scanner weapon stats graph encounter |
	self startInventory.
	owner := 'applied-gadget-upgrade-owner'.
	catalog := CIGameItemTypes buildCatalog.
	tactician := (catalog typeAt: 'gadget.workbook.drone.tactician')
			inventoryItem: 'tactician'
			values: Dictionary new.
	tactician equippedSlotIdentifier: 'GadgetLeft'.
	scanner := (catalog typeAt: 'gadget.workbook.pulse.scanner')
			inventoryItem: 'scanner'
			values: Dictionary new.
	scanner equippedSlotIdentifier: 'GadgetRight'.
	weapon := (catalog typeAt: 'weapon.launch.akM')
			inventoryItem: 'weapon'
			values: (Dictionary new
					at: 'weaponDamage' put: 0.1;
					yourself)
			talentIdentifier: 'futurePerfect'.
	weapon equippedSlotIdentifier: 'RangedWeapon'.
	service
		replaceReadRows: {tactician.
				scanner.
				weapon}
		forOwner: owner.
	self
		assert: ((service workbookGadgetStatsFor: 'tactician' forVerifiedUser: owner)
				at: 'Duration')
		equals: 300.
	service
		selectSpecialization: 'Sharpshooter'
		perks: #('sharpshooter.tactician' 'sharpshooter.graphenebattery' 'sharpshooter.carbonfiberframe')
		forVerifiedUser: owner.
	stats := service workbookGadgetStatsFor: 'tactician' forVerifiedUser: owner.
	self assert: (stats at: 'Duration') closeTo: 345.
	self assert: (stats at: 'Scan Range') equals: 50.
	self assert: (stats at: 'Cooldown') equals: 20.
	self
		assert: ((service workbookGadgetStatsFor: 'scanner' forVerifiedUser: owner)
				at: 'Duration')
		equals: 8.
	graph := service profileGraphForVerifiedUser: owner.
	self assert: ((STON toString: graph) includesSubstring: '345 s').
	encounter := service
			gadgetEncounterFor: 'tactician'
			weapon: 'weapon'
			forVerifiedUser: owner.
	self assert: ((encounter statsAt: 0) at: 'Duration') closeTo: 345.
	self assert: (encounter recordWeaponKillFrom: 'weapon' at: 1).
	stats := encounter statsAt: 1.
	self assert: (stats at: 'Duration') closeTo: 345.
	self assert: (stats at: 'Scan Range') closeTo: 55.
	service clearSpecializationForVerifiedUser: owner.
	self
		assert: ((service workbookGadgetStatsFor: 'tactician' forVerifiedUser: owner)
				at: 'Duration')
		equals: 300
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSelectedSpecializationGadgetsCanBeClaimedOnceAndSurviveRestart [
	| owner perk item retry |
	self startInventory.
	owner := 'specialization-gadget-claim-owner'.
	perk := 'sharpshooter.tactician'.
	self
		should: [ service claimSpecializationGadgetForPerk: perk forVerifiedUser: owner ]
		raise: Error.
	service
		selectSpecialization: 'Sharpshooter'
		perks: #('sharpshooter.tactician' 'sharpshooter.graphenebattery')
		forVerifiedUser: owner.
	self
		should: [ service claimSpecializationGadgetForPerk: perk forVerifiedUser: 'other-owner' ]
		raise: Error.
	self
		should: [ service
				claimSpecializationGadgetForPerk: 'sharpshooter.graphenebattery'
				forVerifiedUser: owner ]
		raise: Error.
	item := service claimSpecializationGadgetForPerk: perk forVerifiedUser: owner.
	self
		assert: item definitionIdentifier
		equals: 'gadget.workbook.drone.tactician'.
	self assert: item equippedSlotIdentifier isNil.
	self
		assert: ((service workbookGadgetStatsFor: item itemIdentifier forVerifiedUser: owner)
				at: 'Duration')
		closeTo: 345.
	retry := service claimSpecializationGadgetForPerk: perk forVerifiedUser: owner.
	self assert: retry itemIdentifier equals: item itemIdentifier.
	service stop.
	service := nil.
	self startInventory.
	retry := service claimSpecializationGadgetForPerk: perk forVerifiedUser: owner.
	self assert: retry itemIdentifier equals: item itemIdentifier.
	self
		assert: (service
				rowsForVerifiedUser: owner
				offset: 0
				limit: 32) size
		equals: 1
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSheriffAutenticoUsesBuiltInBonusesAndNoDamageFalloff [
	| catalog weapon item rows |
	catalog := CIGameItemTypes buildCatalog.
	weapon := catalog typeAt: 'weapon.workbook.theSheriff'.
	self assert: weapon namedReference kind equals: #exotic.
	self assert: weapon damageFalloffPolicy equals: #none.
	self assertEmpty: weapon inspectorFalloffRows.
	self
		assert: (catalog typeAt: 'weapon.workbook.slingshot') damageFalloffPolicy isNil.
	self
		assert: (catalog typeAt: 'weapon.ranged.pathfinder') damageFalloffPolicy
		equals: #curve.
	self assert: (weapon fixedAttributes collect: #magnitude) equals: #(0.35 1).
	self
		assert: (weapon fixedAttributes
				allSatisfy: [ :attribute | attribute evidence = 'Weapons Named + Exotics!E146' ]).
	item := CIItemGenerator new
			generate: 'theSheriff'
			type: weapon id
			values: {'weaponDamage' -> 0} asDictionary
			from: catalog
			using: [ 0 ].
	self assert: (item comparisonStats collect: #value) equals: #(0 0.35 1).
	rows := (weapon inspectorSectionsAtUtilityTier: 0 item: item) first third.
	self assert: rows first second asNumber equals: 526412.
	self assert: item talentIdentifier isNil
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSignatureAmmoDeviceDestructionAndMultikillsUseDistinctEvents [
	| technician gunner demolitionist |
	technician := self
			signatureAmmoEncounterNamed: 'Technician'
			selected: #('technician.micromissileammoacquisition' 'technician.groupsignatureammoacquisition').
	gunner := self
			signatureAmmoEncounterNamed: 'Gunner'
			selected: #('gunner.762minigunammoacquisition' 'gunner.groupsignatureammoacquisition').
	demolitionist := self
			signatureAmmoEncounterNamed: 'Demolitionist'
			selected: #('demolitionist.40mmammoacquisition' 'demolitionist.groupsignatureammosupply').
	#(skillProxy drone robotics)
		do: [ :target | 
			self
				assertSignatureAmmo: (technician
						signatureAmmoForDestroyedHostileTarget: target
						fromSignatureWeapon: true)
				personal: 3
				group: 1 ].
	self
		assertSignatureAmmo: (technician
				signatureAmmoForDestroyedHostileTarget: #human
				fromSignatureWeapon: false)
		personal: 0
		group: 0.
	self
		assertSignatureAmmo: (gunner
				signatureAmmoForKillsWithoutReleasingTrigger: 1
				fromSignatureWeapon: false)
		personal: 0
		group: 0.
	self
		assertSignatureAmmo: (gunner
				signatureAmmoForKillsWithoutReleasingTrigger: 2
				fromSignatureWeapon: false)
		personal: 3
		group: 1.
	self
		assertSignatureAmmo: (gunner
				signatureAmmoForKillsWithoutReleasingTrigger: 2
				fromSignatureWeapon: true)
		personal: 0
		group: 0.
	self
		assertSignatureAmmo: (demolitionist
				signatureAmmoForEnemyKillWithHeadshot: false
				targetHadStatusEffect: false
				explosive: true
				distance: nil
				fromSignatureWeapon: false)
		personal: 3
		group: 0.
	self
		assertSignatureAmmo: (demolitionist
				signatureAmmoForExplosiveMultikill: 1
				fromSignatureWeapon: false)
		personal: 0
		group: 0.
	self
		assertSignatureAmmo: (demolitionist
				signatureAmmoForExplosiveMultikill: 2
				fromSignatureWeapon: false)
		personal: 0
		group: 2.
	self
		assertSignatureAmmo: (demolitionist
				signatureAmmoForExplosiveMultikill: 2
				fromSignatureWeapon: true)
		personal: 0
		group: 0.
	gunner := self
			signatureAmmoEncounterNamed: 'Gunner'
			selected: #('gunner.groupsignatureammoacquisition').
	self
		assertSignatureAmmo: (gunner
				signatureAmmoForKillsWithoutReleasingTrigger: 2
				fromSignatureWeapon: false)
		personal: 0
		group: 1
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSignatureAmmoSingleKillsHonorQualificationAndWeaponExclusions [
	| sharpshooter survivalist firewall kill |
	sharpshooter := self
			signatureAmmoEncounterNamed: 'Sharpshooter'
			selected: #('sharpshooter.50caliberammoacquisition' 'sharpshooter.groupsigantureammosupply' 'sharpshooter.breathcontrol').
	survivalist := self
			signatureAmmoEncounterNamed: 'Survivalist'
			selected: #('survivalist.explosiveboltaqusition' 'survivalist.groupsigantureammosupply').
	firewall := self
			signatureAmmoEncounterNamed: 'Firewall'
			selected: #('firewall.firewallammoacquisition' 'firewall.groupsignatureammoacquisition').
	kill := [ :encounter :headshot :status :metres :signature | 
		encounter
			signatureAmmoForEnemyKillWithHeadshot: headshot
			targetHadStatusEffect: status
			explosive: false
			distance: metres
			fromSignatureWeapon: signature ].
	self
		assertSignatureAmmo: (kill
				valueWithArguments: {sharpshooter.
						true.
						false.
						nil.
						false})
		personal: 2
		group: 1.
	self
		assertSignatureAmmo: (kill
				valueWithArguments: {sharpshooter.
						true.
						false.
						nil.
						true})
		personal: 0
		group: 0.
	self
		assertSignatureAmmo: (kill
				valueWithArguments: {sharpshooter.
						false.
						true.
						nil.
						false})
		personal: 0
		group: 0.
	self
		assertSignatureAmmo: (kill
				valueWithArguments: {survivalist.
						false.
						true.
						nil.
						false})
		personal: 3
		group: 3.
	self
		assertSignatureAmmo: (kill
				valueWithArguments: {survivalist.
						false.
						true.
						nil.
						true})
		personal: 0
		group: 0.
	self
		assertSignatureAmmo: (kill
				valueWithArguments: {survivalist.
						true.
						false.
						nil.
						false})
		personal: 0
		group: 0.
	self
		assertSignatureAmmo: (kill
				valueWithArguments: {firewall.
						false.
						false.
						10.
						false})
		personal: 3
		group: 1.
	self
		assertSignatureAmmo: (kill
				valueWithArguments: {firewall.
						false.
						false.
						10.01.
						false})
		personal: 0
		group: 0.
	self
		assertSignatureAmmo: (kill
				valueWithArguments: {firewall.
						false.
						false.
						10.
						true})
		personal: 0
		group: 0
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSignatureWeaponClaimsRequireMatchingSelectionAndSurviveRestart [
	| owner perk item retry |
	self startInventory.
	owner := 'signature-weapon-claim-owner'.
	perk := 'gunner.minigun'.
	self
		should: [ service claimSpecializationSignatureWeaponForPerk: perk forVerifiedUser: owner ]
		raise: Error.
	service
		selectSpecialization: 'Gunner'
		perks: {perk.
				'gunner.riotfoamgrenade'}
		forVerifiedUser: owner.
	self
		should: [ service
				claimSpecializationSignatureWeaponForPerk: 'gunner.riotfoamgrenade'
				forVerifiedUser: owner ]
		raise: Error.
	self
		should: [ service
				claimSpecializationSignatureWeaponForPerk: perk
				forVerifiedUser: 'other-owner' ]
		raise: Error.
	item := service
			claimSpecializationSignatureWeaponForPerk: perk
			forVerifiedUser: owner.
	self
		assert: item definitionIdentifier
		equals: 'weapon.signature.gunner.minigun'.
	service stop.
	service := nil.
	self startInventory.
	retry := service
			claimSpecializationSignatureWeaponForPerk: perk
			forVerifiedUser: owner.
	self assert: retry itemIdentifier equals: item itemIdentifier.
	self deny: (retry permitsCapturedEquipmentSlot: 'RangedWeapon').
	self
		assert: (service
				rowsForVerifiedUser: owner
				offset: 0
				limit: 32) size
		equals: 1
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSignatureWeaponRewardsClaimWithSourceNamesAndUnspecifiedCombatStats [
	| catalog store owner cases |
	catalog := CIGameItemTypes buildCatalog.
	store := CIInventoryReadStore new.
	owner := 'signature-weapon-reward-types'.
	cases := #(#('Sharpshooter' 'sharpshooter.tac50crifle' 'TAC-50 C Rifle' 'Specializations!G18') #('Survivalist' 'survivalist.crossbow' 'Crossbow' 'Specializations!K18') #('Technician' 'technician.p017launcher' 'P-017 Launcher' 'Specializations!G38') #('Gunner' 'gunner.minigun' 'Minigun' 'Specializations!K37') #('Demolitionist' 'demolitionist.m32a1multishotgrenadelauncher' 'M32A1 Multi-shot Grenade Launcher' 'Specializations!G57') #('Firewall' 'firewall.k8jetstreamflamethrower' 'K8-JetStream Flamethrower' 'Specializations!K57')).
	cases
		do: [ :row | 
			| item type perk |
			store
				specialization: (CISpecializationSelection specialization: row first perks: {row second})
				forOwner: owner.
			item := store
					claimSpecializationSignatureWeaponForPerk: row second
					from: catalog
					forOwner: owner.
			self assert: item displayName equals: row third.
			self deny: (item permitsCapturedEquipmentSlot: 'RangedWeapon').
			type := catalog typeAt: item definitionIdentifier.
			perk := type rewardPerk.
			self assert: perk evidence equals: row fourth.
			self assert: perk equipmentReward weaponStatistics isNil.
			self assertEmpty: (catalog talentPoolFor: type id) ].
	self assert: (store allRowsForOwner: owner) size equals: 6
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSkillEfficiencyUsesActualHasteForCooldownAndDoublesOnlyTheReportedHaste [
	| rule actual reported |
	rule := CIGameItemTypes buildCatalog attributeCatalogue
			ruleAt: 'skillEfficiency'.
	self assert: rule evidence equals: 'Attribute Info!E49,G49'.
	actual := rule actualContributionsForEfficiency: 0.2.
	self
		assert: actual keys asSet
		equals: #(skillDamage skillHaste skillDuration skillHealth repairSkills statusEffects)
				asSet.
	self assert: (actual values allSatisfy: [ :value | value = 0.2 ]).
	reported := rule reportedContributionsForEfficiency: 0.2.
	self assert: (reported at: #skillHaste) closeTo: 0.4.
	reported at: #skillHaste put: 0.2.
	self assert: reported equals: actual.
	self assert: (rule cooldownSecondsFromBase: 60 efficiency: 0.2) closeTo: 50.
	self assert: (rule cooldownSecondsFromBase: 60 efficiency: 1) equals: 30.
	self assert: (rule cooldownSecondsFromBase: 60 efficiency: 0) equals: 60.
	self
		assert: (rule
				cooldownSecondsFromBase: 60
				skillHaste: 0.50
				efficiency: 0.20)
		closeTo: 60 / 1.70.
	self
		assert: (rule
				cooldownSecondsFromBase: 60
				skillHaste: 0.50
				efficiency: 0)
		equals: 40.
	self
		assert: (rule
				cooldownSecondsFromBase: 60
				skillHaste: 0
				efficiency: 0.20)
		closeTo: 50.
	self
		should: [ rule
				cooldownSecondsFromBase: 60
				skillHaste: nil
				efficiency: 0.20 ]
		raise: Error.
	self
		should: [ rule
				cooldownSecondsFromBase: 60
				skillHaste: -1.20
				efficiency: 0.10 ]
		raise: Error.
	self should: [ rule actualContributionsForEfficiency: -0.1 ] raise: Error
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSkilledGearTalentBanksOnlyOneResetForTheNextGadget [
	| catalog encounter ready |
	catalog := CIGameItemTypes buildCatalog.
	encounter := CIGearTalentEncounter talent: (catalog talentAt: 'skilled').
	ready := {#hive -> 0.
			#pulse -> 0} asDictionary.
	encounter
		recordGadgetKillAt: 0
		roll: 0.25
		remainingGadgetCooldowns: ready.
	self assert: (encounter gadgetCooldownOnStart: 10 at: 1) equals: 10.
	self
		assert: (encounter
				recordGadgetKillAt: 2
				roll: 0.1
				remainingGadgetCooldowns: ready)
		equals: ready.
	encounter
		recordGadgetKillAt: 3
		roll: 0.1
		remainingGadgetCooldowns: ready.
	self assert: (encounter gadgetCooldownOnStart: 0 at: 4) equals: 0.
	self assert: (encounter gadgetCooldownOnStart: 10 at: 5) equals: 0.
	self assert: (encounter gadgetCooldownOnStart: 20 at: 5) equals: 20
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSkilledGearTalentResetsActiveCooldownsAtDocumentedChances [
	| catalog reference remaining ready |
	catalog := CIGameItemTypes buildCatalog.
	reference := catalog talentReferenceAt: 'Gear Talents!D21'.
	self assert: reference talentIdentifier equals: 'skilled'.
	self assert: reference perfectTalentIdentifier equals: 'perfectlySkilled'.
	remaining := {#hive -> 9.
			#pulse -> 2.
			#shield -> 0} asDictionary.
	ready := {#hive -> 0.
			#pulse -> 0.
			#shield -> 0} asDictionary.
	{{reference talentIdentifier.
			#pve.
			0.25.
			0.24}.
		{reference perfectTalentIdentifier.
			#pve.
			0.30.
			0.29}.
		{reference talentIdentifier.
			#pvp.
			0.20.
			0.19}.
		{reference perfectTalentIdentifier.
			#pvp.
			0.25.
			0.24}}
		do: [ :row | 
			| talent encounter |
			talent := catalog talentAt: row first.
			self assert: talent eligibility equals: #Chest.
			encounter := CIGearTalentEncounter talent: talent mode: row second.
			self
				assert: (encounter
						recordGadgetKillAt: 0
						roll: row third
						remainingGadgetCooldowns: remaining)
				equals: remaining.
			self
				assert: (encounter
						recordGadgetKillAt: 1
						roll: row fourth
						remainingGadgetCooldowns: remaining)
				equals: ready.
			self assert: (encounter gadgetCooldownOnStart: 8 at: 2) equals: 8 ].
	self assert: (remaining at: #hive) equals: 9
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSlingshotGeneratesWithDocumentedTotalOptimalRange [
	| catalog weapon range item comparison |
	catalog := CIGameItemTypes buildCatalog.
	weapon := catalog typeAt: 'weapon.workbook.slingshot'.
	self assert: weapon statisticsReference weaponClass equals: #smg.
	self assert: weapon optimalRangeMetres equals: 60.
	self
		assert: (weapon namedReference fieldAt: #talentOrAttribute)
		equals: '+45 Optimal Range (60 total)'.
	range := weapon fixedAttributes
			detect: [ :attribute | attribute statIdentifier = 'optimalRangeMetres' ].
	self assert: range magnitude equals: 60.
	self assert: range unit equals: #metres.
	self assert: range evidence equals: 'Weapons!M142'.
	item := CIItemGenerator new
			generate: 'slingshot'
			type: weapon id
			values: {'weaponDamage' -> 0.10} asDictionary
			from: catalog
			using: [ 0 ].
	comparison := item comparisonStats
			detect: [ :stat | stat statIdentifier = 'optimalRangeMetres' ].
	self assert: comparison value equals: 60.
	self assert: item talentIdentifier isNil.
	self
		should: [ CIItemGenerator new
				generate: 'bad'
				type: weapon id
				values: {'weaponDamage' -> 0.10.
						'optimalRangeMetres' -> 61} asDictionary
				from: catalog
				using: [ 0 ] ]
		raise: Error
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSpecializationConditionalPerksHonorRangeCooldownAndPvP [
	| catalog loadout field pve pvp demolitionist targets |
	catalog := CIGameItemTypes buildCatalog.
	loadout := catalog
			specializationLoadoutNamed: 'Technician'
			selected: #('technician.faradayfield').
	field := CISpecializationEncounter
			forLoadout: loadout
			mode: #pve
			startedAt: 0.
	self
		assert: (field
				faradayImmunitiesForPartyMember: true
				atDistance: 5
				deployed: true
				disrupted: false)
		equals: #(shock disrupt).
	self
		assertEmpty: (field
				faradayImmunitiesForPartyMember: true
				atDistance: 5
				deployed: true
				disrupted: true).
	self
		assertEmpty: (field
				faradayImmunitiesForPartyMember: true
				atDistance: 6
				deployed: true
				disrupted: false).
	self
		assertEmpty: (field
				faradayImmunitiesForPartyMember: false
				atDistance: 5
				deployed: true
				disrupted: false).
	loadout := catalog
			specializationLoadoutNamed: 'Firewall'
			selected: #('firewall.fieryresponse').
	pve := CISpecializationEncounter
			forLoadout: loadout
			mode: #pve
			startedAt: 0.
	pvp := CISpecializationEncounter
			forLoadout: loadout
			mode: #pvp
			startedAt: 0.
	targets := {'edge' -> 5.
			'out' -> 6} asDictionary.
	self
		assert: (pve fieryResponseBurnTargetsOnArmorBreak: targets at: 0)
		equals: #('edge').
	self assertEmpty: (pvp fieryResponseBurnTargetsOnArmorBreak: targets at: 0).
	loadout := catalog
			specializationLoadoutNamed: 'Demolitionist'
			selected: #('demolitionist.bracedforimpact').
	demolitionist := CISpecializationEncounter
			forLoadout: loadout
			mode: #pve
			startedAt: 0.
	self assert: (demolitionist blocksExplosionAt: 0).
	self deny: (demolitionist blocksExplosionAt: 59).
	self assert: (demolitionist blocksExplosionAt: 60)
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSpecializationEquipmentRewardsRetainWorkbookReferencesAndUnspecifiedStats [
	| catalog equipped firestarter diceros emp |
	catalog := CIGameItemTypes buildCatalog.
	equipped := catalog specializations
			flatCollect: [ :each | (each perks collect: #equipmentReward) reject: #isNil ].
	#(grenade sidearm signatureWeapon)
		do: [ :kind | self assert: (equipped count: [ :reward | reward kind = kind ]) equals: 6 ].
	(equipped select: [ :reward | reward kind = #signatureWeapon ])
		do: [ :reward | 
			self assert: reward weaponStatistics isNil.
			self assert: reward namedWeaponReference isNil ].
	firestarter := ((catalog specializationNamed: 'Firewall')
			perkAt: 'firewall.firestartersawedoffshotgun') equipmentReward.
	self assert: firestarter weaponStatistics name equals: 'Firestarter'.
	self assert: firestarter weaponStatistics id equals: 'Weapons!C164'.
	self
		assert: ((firestarter namedWeaponReference fieldAt: #talentOrAttribute)
				includesSubstring: 'Primer Rounds').
	diceros := ((catalog specializationNamed: 'Demolitionist')
			perkAt: 'demolitionist.dicerosspecial') equipmentReward.
	self
		assert: ((diceros namedWeaponReference fieldAt: #talentOrAttribute)
				includesSubstring: '4%').
	emp := (catalog specializationNamed: 'Technician')
			perkAt: 'technician.empgrenade'.
	self assert: emp equipmentReward appliedStatuses equals: #(disrupt).
	self assert: (emp description includesSubstring: 'electrical abilities')
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSpecializationGadgetBehaviorsUseWorkbookTargetRulesAndTierStats [
	| catalog variant banshee profile stats loadout result artificer striker |
	catalog := CIGameItemTypes buildCatalog.
	variant := [ :id | (catalog typeAt: 'gadget.workbook.' , id) workbookVariantDefinition ].
	self
		assert: (variant value: 'drone.tactician') behaviorProfile effects
		equals: #(markHostileTarget).
	self
		assert: (variant value: 'seeker.mender') behaviorProfile targetKind
		equals: #ally.
	self
		assert: (variant value: 'turret.artillery') behaviorProfile delivery
		equals: #indirectFire.
	banshee := variant value: 'pulse.banshee'.
	profile := banshee behaviorProfile.
	self assert: profile ignoresCover.
	self assert: profile evidence equals: 'Specializations!K31:L31'.
	loadout := catalog
			specializationLoadoutNamed: 'Gunner'
			selected: #('gunner.banshee' 'gunner.microwaveamplifier' 'gunner.directionaltransmitter').
	stats := banshee
			knownStatsAtTier: 1
			withSpecializationUpgrades: (loadout resolvedGadgetUpgradesForType: 'gadget.workbook.pulse.banshee').
	result := profile
			effectsForTargetKind: #enemy
			ownedByAgent: false
			holstered: false
			withinAffectedArea: true
			stats: stats.
	self assert: (result at: #effects) equals: #(disorient).
	self assert: ((result at: #stats) at: 'Disorient Duration') closeTo: 5.06.
	self assert: ((result at: #stats) at: 'Radius') closeTo: 34.5.
	self
		assertEmpty: (profile
				effectsForTargetKind: #ally
				ownedByAgent: false
				holstered: false
				withinAffectedArea: true
				stats: stats).
	self
		assertEmpty: (profile
				effectsForTargetKind: #enemy
				ownedByAgent: false
				holstered: false
				withinAffectedArea: false
				stats: stats).
	artificer := variant value: 'hive.artificer'.
	profile := artificer behaviorProfile.
	stats := artificer knownStatsAtTier: 0.
	self
		assertEmpty: (profile
				effectsForTargetKind: #friendlyGadget
				ownedByAgent: false
				holstered: true
				withinAffectedArea: true
				stats: stats).
	result := profile
			effectsForTargetKind: #friendlyGadget
			ownedByAgent: true
			holstered: true
			withinAffectedArea: true
			stats: stats.
	self
		assert: (result at: #effects)
		equals: #(boostGadget refreshGadget repairGadget).
	self assert: ((result at: #stats) at: 'Skill Refresh') equals: 3.
	self
		deny: (profile
				effectsForTargetKind: #friendlyGadget
				ownedByAgent: false
				holstered: false
				withinAffectedArea: true
				stats: stats) isEmpty.
	striker := variant value: 'shield.striker'.
	profile := striker behaviorProfile.
	self
		assert: (profile
				allowsSignatureWeapon: 'weapon.signature.firewall.k8jetstreamflamethrower').
	self deny: (profile allowsSignatureWeapon: 'weapon.signature.gunner.minigun').
	self
		assert: (profile
				damageBonusForEnemiesInFront: 3
				recipientIsOwner: false
				allyBehind: true
				stats: (striker knownStatsAtTier: 0))
		closeTo: 0.15.
	self
		assert: (profile
				damageBonusForEnemiesInFront: 3
				recipientIsOwner: false
				allyBehind: false
				stats: (striker knownStatsAtTier: 0))
		equals: 0.
	self
		assert: (profile
				damageBonusForEnemiesInFront: 3
				recipientIsOwner: true
				allyBehind: false
				stats: (striker knownStatsAtTier: 1)) isNil
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSpecializationGadgetUpgradesKeepUnspecifiedEffectsOutOfStats [
	| catalog upgrades conflicts mortar carbon magnetic |
	catalog := CIGameItemTypes buildCatalog.
	upgrades := catalog specializations
			flatCollect: [ :specialization | specialization perks select: [ :perk | perk gadgetUpgrade notNil ] ].
	self assert: upgrades size equals: 12.
	conflicts := upgrades reject: [ :perk | perk gadgetUpgrade isResolved ].
	self
		assert: (conflicts collect: #id) asSet
		equals: #('sharpshooter.carbonfiberframe' 'survivalist.magneticdisc') asSet.
	conflicts
		do: [ :perk | 
			| upgrade variant |
			upgrade := perk gadgetUpgrade.
			variant := (catalog typeAt: upgrade gadgetTypeIdentifier)
					workbookVariantDefinition.
			self deny: perk description isEmpty.
			self assert: upgrade resolvedTrack isNil.
			self assert: upgrade resolvedMagnitude isNil.
			self assert: upgrade reportedMagnitude > 0.
			self deny: upgrade reviewEvidence isEmpty.
			self
				assert: (variant knownStatsAtTier: 0 withSpecializationUpgrades: {upgrade})
				equals: (variant knownStatsAtTier: 0 withSpecializationUpgrades: #()) ].
	carbon := ((catalog specializationNamed: 'Sharpshooter')
			perkAt: 'sharpshooter.carbonfiberframe') gadgetUpgrade.
	magnetic := ((catalog specializationNamed: 'Survivalist')
			perkAt: 'survivalist.magneticdisc') gadgetUpgrade.
	self assert: carbon supportedTargetTrack label equals: 'Scan Range'.
	self assert: magnetic supportedTargetTrack label equals: 'Health'.
	mortar := ((catalog specializationNamed: 'Demolitionist')
			perkAt: 'demolitionist.cyclonemagazine') gadgetUpgrade.
	self assert: mortar reportedStatLabel equals: 'Extra Mortar Ammo'.
	self assert: mortar reportedMagnitude equals: 1.
	self assert: mortar unit equals: #count.
	self assert: mortar resolvedTrack label equals: 'Ammo'
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSpecializationGrenadeClaimsRequireSelectedPerkAndSurviveRestart [
	| owner perk item retry |
	self startInventory.
	owner := 'specialization-grenade-claim-owner'.
	perk := 'technician.empgrenade'.
	self
		should: [ service claimSpecializationGrenadeForPerk: perk forVerifiedUser: owner ]
		raise: Error.
	service
		selectSpecialization: 'Technician'
		perks: {perk.
				'technician.artificer'}
		forVerifiedUser: owner.
	self
		should: [ service
				claimSpecializationGrenadeForPerk: 'technician.artificer'
				forVerifiedUser: owner ]
		raise: Error.
	self
		should: [ service claimSpecializationGrenadeForPerk: perk forVerifiedUser: 'other-owner' ]
		raise: Error.
	item := service claimSpecializationGrenadeForPerk: perk forVerifiedUser: owner.
	self
		assert: item definitionIdentifier
		equals: 'grenade.specialization.technician.empgrenade'.
	retry := service claimSpecializationGrenadeForPerk: perk forVerifiedUser: owner.
	self assert: retry itemIdentifier equals: item itemIdentifier.
	service stop.
	service := nil.
	self startInventory.
	retry := service claimSpecializationGrenadeForPerk: perk forVerifiedUser: owner.
	self assert: retry itemIdentifier equals: item itemIdentifier.
	self
		assert: (service
				rowsForVerifiedUser: owner
				offset: 0
				limit: 32) size
		equals: 1
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSpecializationPassivesHonorCoverAimingAndStationaryConditions [
	| catalog encounter sharpshooter survivalist technician gunner firewall inactive |
	catalog := CIGameItemTypes buildCatalog.
	encounter := [ :name :selections | 
		CISpecializationEncounter
			forLoadout: (catalog specializationLoadoutNamed: name selected: selections)
			mode: #pve
			startedAt: 0 ].
	sharpshooter := encounter
			value: 'Sharpshooter'
			value: #('sharpshooter.myhomeismycastle').
	survivalist := encounter
			value: 'Survivalist'
			value: #('survivalist.crunchtime').
	technician := encounter value: 'Technician' value: #('technician.technomancy').
	gunner := encounter value: 'Gunner' value: #('gunner.emplacement').
	firewall := encounter value: 'Firewall' value: #('firewall.bullrush').
	inactive := encounter value: 'Gunner' value: #().
	self assert: (sharpshooter coverBonusArmorIsActiveWhileInCover: true).
	self deny: (sharpshooter coverBonusArmorIsActiveWhileInCover: false).
	self deny: (inactive coverBonusArmorIsActiveWhileInCover: true).
	self assert: (survivalist gadgetHasteBonusWhileInCover: true) equals: 0.10.
	self assert: (survivalist gadgetHasteBonusWhileInCover: false) equals: 0.
	self assert: (technician bonusArmorWhileAimingGadget: true) equals: 0.15.
	self assert: (technician bonusArmorWhileAimingGadget: false) equals: 0.
	self
		assert: (gunner emplacementWeaponHandlingAfterStationarySeconds: 0.99)
		equals: 0.
	self
		assert: (gunner emplacementWeaponHandlingAfterStationarySeconds: 1)
		equals: 0.10.
	self
		assert: (gunner emplacementWeaponHandlingAfterStationarySeconds: 0)
		equals: 0.
	self
		assert: (inactive emplacementWeaponHandlingAfterStationarySeconds: 1)
		equals: 0.
	self assert: (firewall bonusArmorDuringCoverToCoverMove: true) equals: 0.30.
	self assert: (firewall bonusArmorDuringCoverToCoverMove: false) equals: 0
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSpecializationPassivesHonorTargetKindKillAndArmorBreak [
	| catalog encounter technician demolitionist gunner inactive |
	catalog := CIGameItemTypes buildCatalog.
	encounter := [ :name :selections | 
		CISpecializationEncounter
			forLoadout: (catalog specializationLoadoutNamed: name selected: selections)
			mode: #pve
			startedAt: 0 ].
	technician := encounter value: 'Technician' value: #('technician.dismantling').
	demolitionist := encounter
			value: 'Demolitionist'
			value: #('demolitionist.crisisresponse').
	gunner := encounter value: 'Gunner' value: #('gunner.incessant').
	inactive := encounter value: 'Demolitionist' value: #().
	#(drone skillProxy robotics)
		do: [ :target | self assert: (technician dismantlingDamageBonusAgainst: target) equals: 0.12 ].
	self assert: (technician dismantlingDamageBonusAgainst: #human) equals: 0.
	self assert: gunner incessantArmorFractionOnEnemyKill equals: 0.10.
	self assert: inactive incessantArmorFractionOnEnemyKill equals: 0.
	self
		assert: (demolitionist crisisResponseRefillsMainWeaponMagazinesFromArmor: 1 to: 0).
	self
		deny: (demolitionist crisisResponseRefillsMainWeaponMagazinesFromArmor: 0 to: 0).
	self
		deny: (demolitionist crisisResponseRefillsMainWeaponMagazinesFromArmor: 5 to: 1).
	self
		deny: (inactive crisisResponseRefillsMainWeaponMagazinesFromArmor: 1 to: 0)
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSpecializationQualificationReplyShowsOnlyVerifiedOwnersRewardState [
	| owner other gadget request gateway binding previous response profile perks technician |
	self startInventory.
	owner := 'specialization-profile-owner'.
	other := 'another-profile-owner'.
	service
		selectSpecialization: 'Technician'
		perks: #('technician.artificer' 'technician.empgrenade' 'technician.amped')
		forVerifiedUser: owner.
	gadget := service
			claimSpecializationGadgetForPerk: 'technician.artificer'
			forVerifiedUser: owner.
	request := CCQuicRequest new
			operation: 109;
			body: #[];
			yourself.
	gateway := CIInventoryGatewayQualificationApplication new.
	binding := CIInventoryGatewayQualificationApplication classPool
			associationAt: #InventoryService.
	previous := binding value.
	[ binding value: service.
	response := (gateway
			execute: request
			asVerifiedUser: owner
			using: nil) response.
	self assert: response second equals: 0.
	profile := STONJSON fromString: response first utf8Decoded.
	self assert: (profile at: 'format') equals: 'inventory.specialization/1'.
	self assert: (profile at: 'name') equals: 'Technician'.
	perks := profile at: 'selectedPerks'.
	self assert: perks size equals: 3.
	technician := perks
			detect: [ :perk | (perk at: 'perkIdentifier') = 'technician.artificer' ].
	self
		assert: (technician at: 'ownedRewardItemIdentifier')
		equals: gadget itemIdentifier.
	self
		assert: (technician at: 'rewardDefinitionIdentifier')
		equals: gadget definitionIdentifier.
	self
		assert: ((technician at: 'description') includesSubstring: 'micro electro-booster').
	self assert: (technician at: 'evidence') equals: 'Specializations!G32:H32'.
	technician := perks
			detect: [ :perk | (perk at: 'perkIdentifier') = 'technician.empgrenade' ].
	self deny: (technician includesKey: 'ownedRewardItemIdentifier').
	response := (gateway
			execute: request
			asVerifiedUser: other
			using: nil) response.
	profile := STONJSON fromString: response first utf8Decoded.
	self assert: (profile at: 'name') isNil.
	self assertEmpty: (profile at: 'selectedPerks').
	request body: owner utf8Encoded.
	self
		assert: (gateway
				execute: request
				asVerifiedUser: other
				using: nil) response second
		equals: 403 ] ensure: [ binding value: previous ]
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSpecializationSidearmClaimsValidateRollAndSurviveRestart [
	| owner perk values item retry catalog talent encounter preservation repair |
	self startInventory.
	owner := 'specialization-sidearm-claim-owner'.
	perk := 'demolitionist.dicerosspecial'.
	values := {'weaponDamage' -> 0.10} asDictionary.
	self
		should: [ service
				claimSpecializationSidearmForPerk: perk
				values: values
				forVerifiedUser: owner ]
		raise: Error.
	service
		selectSpecialization: 'Demolitionist'
		perks: {perk}
		forVerifiedUser: owner.
	self
		should: [ service
				claimSpecializationSidearmForPerk: perk
				values: Dictionary new
				forVerifiedUser: owner ]
		raise: Error.
	self
		should: [ service
				claimSpecializationSidearmForPerk: perk
				values: {'weaponDamage' -> 0.16} asDictionary
				forVerifiedUser: owner ]
		raise: Error.
	item := service
			claimSpecializationSidearmForPerk: perk
			values: values
			forVerifiedUser: owner.
	self assert: item equippedSlotIdentifier isNil.
	service stop.
	service := nil.
	self startInventory.
	retry := service
			claimSpecializationSidearmForPerk: perk
			values: values
			forVerifiedUser: owner.
	self assert: retry itemIdentifier equals: item itemIdentifier.
	self assert: retry talentIdentifier equals: 'perfectOptimist.dicerosSpecial'.
	self
		assert: (service
				rowsForVerifiedUser: owner
				offset: 0
				limit: 32) size
		equals: 1.
	catalog := CIGameItemTypes buildCatalog.
	talent := catalog talentAt: retry talentIdentifier.
	encounter := CIWeaponTalentEncounter
			weapon: retry itemIdentifier
			talent: talent.
	self
		assert: (encounter weaponDamageBonusForMagazine: 10 remaining: 9)
		closeTo: 0.04.
	self assert: encounter evidence equals: 'Weapons Named + Exotics!E99'.
	preservation := CIWeaponTalentEncounter
			weapon: 'p320'
			talent: (catalog talentAt: 'perfectPreservation.p320XCompact').
	repair := preservation armorRepairOnKillFrom: 'p320' headshot: true.
	self assert: repair fraction closeTo: 0.24.
	self assert: repair durationSeconds equals: 5.
	self
		assert: ((catalog talentAt: 'perfectPreservation') parameters at: #armorRepairOnKill)
		equals: 0.15
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSpecializationSidearmsClaimWithTheirSourceSpecificFixedTalents [
	| catalog store owner cases values |
	catalog := CIGameItemTypes buildCatalog.
	store := CIInventoryReadStore new.
	owner := 'specialization-sidearm-types'.
	values := {'weaponDamage' -> 0.1} asDictionary.
	cases := #(#('Sharpshooter' 'sharpshooter.sharpshooters93r' 'perfectUnwavering.sharpshooter93r') #('Survivalist' 'survivalist.survivalistd50' 'perfectSadist.survivalistD50') #('Technician' 'technician.maxim9' 'perfectSpike.maxim9') #('Gunner' 'gunner.p320xcompact' 'perfectPreservation.p320XCompact') #('Demolitionist' 'demolitionist.dicerosspecial' 'perfectOptimist.dicerosSpecial') #('Firewall' 'firewall.firestartersawedoffshotgun' 'primerRounds.firestarter')).
	cases
		do: [ :row | 
			| item perk weapon |
			store
				specialization: (CISpecializationSelection specialization: row first perks: {row second})
				forOwner: owner.
			item := store
					claimSpecializationSidearmForPerk: row second
					values: values
					from: catalog
					forOwner: owner.
			perk := (catalog specializationNamed: row first) perkAt: row second.
			weapon := catalog typeAt: item definitionIdentifier.
			self assert: item definitionIdentifier equals: perk rewardIdentifier.
			self assert: item talentIdentifier equals: row third.
			self
				assert: (catalog talentPoolFor: item definitionIdentifier)
				equals: {row third}.
			self assert: (item permitsCapturedEquipmentSlot: 'LeftHandWeapon').
			self deny: (item permitsCapturedEquipmentSlot: 'RangedWeapon').
			self assert: weapon namedReference itemDefinitionIdentifier equals: weapon id.
			self
				assert: weapon statisticsReference itemDefinitionIdentifier
				equals: weapon id ].
	self assert: (store allRowsForOwner: owner) size equals: 6
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSpecializationWeaponModRewardsRetainExactWorkbookSocketInterfaces [
	| catalog rows |
	catalog := CIGameItemTypes buildCatalog.
	rows := #(#('attachment.workbook7' 'sharpshooter.digitalscope' #(longOpticsRail) shortOpticsRail) #('attachment.workbook43' 'survivalist.infantry556mag' #(magazine556) magazine762) #('attachment.workbook87' 'technician.linkedlaserpointer' #(longUnderbarrelRail) shortUnderbarrelRail) #('attachment.workbook27' 'gunner.largepouchlmgs' #(ammunitionBelt) integratedMagazine) #('attachment.workbook92' 'demolitionist.smalllaserpointer' #(longUnderbarrelRail shortUnderbarrelRail) sideMount) #('attachment.workbook86' 'firewall.tacticalshortgrip' #(longUnderbarrelRail) shortUnderbarrelRail)).
	rows
		do: [ :row | 
			| definition perk |
			definition := catalog modCatalogue definitionAt: row first.
			perk := catalog specializationPerkGrantingReward: row first.
			self assert: perk id equals: row second.
			row third
				do: [ :interface | 
					self
						assert: (definition
								fitsSocket: (CIItemSocket
										id: 'socket'
										interface: interface
										fixedMod: nil)
								on: 'test-weapon') ].
			self
				deny: (definition
						fitsSocket: (CIItemSocket
								id: 'socket'
								interface: row fourth
								fixedMod: nil)
						on: 'test-weapon') ].
	self
		assert: (catalog specializationPerkGrantingReward: 'attachment.workbook26') isNil
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSpecializationWeaponModUnlocksRequireSelectedPerkAndSurviveRespec [
	| owner modId unlock duplicate |
	self startInventory.
	owner := 'specialization-weapon-mod-owner'.
	modId := 'attachment.workbook7'.
	self
		should: [ service unlockWeaponMod: modId forVerifiedUser: owner ]
		raise: Error.
	self
		should: [ service
				selectSpecialization: 'Sharpshooter'
				perks: #('sharpshooter.digitalscope')
				forVerifiedUser: owner ]
		raise: Error.
	service
		selectSpecialization: 'Sharpshooter'
		perks: #('universal.thisismyrifle')
		forVerifiedUser: owner.
	self
		should: [ service unlockWeaponMod: modId forVerifiedUser: owner ]
		raise: Error.
	service
		selectSpecialization: 'Sharpshooter'
		perks: #('sharpshooter.digitalscope' 'universal.thisismyrifle')
		forVerifiedUser: owner.
	self
		should: [ service unlockWeaponMod: modId forVerifiedUser: 'another-owner' ]
		raise: Error.
	unlock := service unlockWeaponMod: modId forVerifiedUser: owner.
	self assert: unlock definitionIdentifier equals: modId.
	service
		selectSpecialization: 'Gunner'
		perks: #()
		forVerifiedUser: owner.
	service stop.
	service := nil.
	self startInventory.
	self
		assert: (service specializationLoadoutForVerifiedUser: owner) definition name
		equals: 'Gunner'.
	duplicate := service unlockWeaponMod: modId forVerifiedUser: owner.
	self assert: duplicate itemIdentifier equals: unlock itemIdentifier.
	self
		assert: ((service
				rowsForVerifiedUser: owner
				offset: 0
				limit: 32) count: [ :each | each definitionIdentifier = modId ])
		equals: 1
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSpecializationsPreserveWorkbookPerksAndValidateSelections [
	| catalog technician amped selected gear damage digital |
	catalog := CIGameItemTypes buildCatalog.
	self assert: catalog specializations size equals: 7.
	self
		assert: (catalog specializations sum: [ :specialization | specialization perks size ])
		equals: 100.
	technician := catalog specializationNamed: 'Technician'.
	amped := technician perkAt: 'technician.amped'.
	self assert: amped evidence equals: 'Specializations!G28:H28'.
	self assert: amped description equals: '+1 Skill Tier'.
	self
		should: [ catalog
				specializationLoadoutNamed: 'Technician'
				selected: #('technician.overclockedcpu' 'technician.enhanceddiagnostics') ]
		raise: Error.
	self
		should: [ catalog
				specializationLoadoutNamed: 'Technician'
				selected: #('sharpshooter.tactician') ]
		raise: Error.
	self
		should: [ catalog
				specializationLoadoutNamed: 'Technician'
				selected: #('technician.linkedlaserpointer') ]
		raise: Error.
	selected := catalog
			specializationLoadoutNamed: 'Technician'
			selected: #('technician.amped' 'technician.artificer' 'technician.linkedlaserpointer' 'universal.thisismyrifle' 'universal.emi').
	self
		assert: selected rewardIdentifiers asSet
		equals: #('attachment.workbook87' 'gadget.workbook.hive.artificer') asSet.
	gear := catalog typeAt: 'gadget.workbook.hive.artificer'.
	self assert: gear workbookVariantDefinition name equals: 'Artificer'.
	damage := (selected modifiersFor: #rifle)
			select: [ :each | each stat = #weaponDamage ].
	self assert: damage size equals: 1.
	self assert: damage first magnitude equals: 0.15.
	self
		assert: ((selected modifiersFor: #pistol) select: [ :each | each stat = #weaponDamage ])
				isEmpty.
	self
		assert: ((selected modifiersFor: #pistol) detect: [ :each | each stat = #skillTier ])
				unit
		equals: #skillTier.
	digital := (catalog specializationNamed: 'Sharpshooter')
			perkAt: 'sharpshooter.digitalscope'.
	self
		assert: (catalog modCatalogue definitionAt: digital rewardIdentifier) name
		equals: 'Digital Scope'
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSpikeHeadshotsAndPrimerRoundsUseWorkbookMagnitudesAndDurations [
	| catalog spike primer reduction |
	catalog := CIGameItemTypes buildCatalog.
	spike := CIWeaponTalentEncounter
			weapon: 'maxim'
			talent: (catalog talentAt: 'perfectSpike.maxim9').
	spike
		recordEnemyHitFrom: 'maxim'
		critical: true
		at: 0.
	spike
		recordEnemyHitFrom: 'other'
		critical: false
		headshot: true
		at: 1.
	self assert: ((spike damageBonusesAt: 1) at: #skillDamage) equals: 0.
	spike
		recordEnemyHitFrom: 'maxim'
		critical: false
		headshot: true
		at: 3.
	self assert: ((spike damageBonusesAt: 17.9) at: #skillDamage) equals: 0.25.
	self assert: ((spike damageBonusesAt: 18) at: #skillDamage) equals: 0.
	primer := CIWeaponTalentEncounter
			weapon: 'firestarter'
			talent: (catalog talentAt: 'primerRounds.firestarter').
	self assert: (primer burnResistanceReductionOnEnemyDamageFrom: 'other') isNil.
	reduction := primer burnResistanceReductionOnEnemyDamageFrom: 'firestarter'.
	self assert: reduction stat equals: #burnResistance.
	self assert: reduction fraction equals: 0.50.
	self assert: reduction durationSeconds equals: 5
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testStandardWeaponClassGenerationUsesOnlyDocumentedCaps [
	| catalog generator ar lmg rifle mmr pistol exotic item create |
	catalog := CIGameItemTypes buildCatalog.
	generator := CIItemGenerator new.
	create := [ :id :key :value | 
		generator
			generate: 'weapon'
			type: id
			values: {'weaponDamage' -> 0.10.
					key -> value} asDictionary
			from: catalog
			using: [ 0 ] ].
	ar := catalog typeAt: 'weapon.launch.akM'.
	lmg := catalog typeAt: 'weapon.launch.mg5'.
	rifle := catalog typeAt: 'weapon.launch.classicM1a'.
	mmr := catalog typeAt: 'weapon.launch.model700'.
	pistol := catalog typeAt: 'weapon.launch.d50'.
	exotic := catalog typeAt: 'weapon.launch.capacitor'.
	self assert: (ar classGenerationRule maximumFor: #standardMaximum) equals: 0.21.
	self
		assert: (ar classGenerationRule maximumFor: #prototypeMaximum)
		equals: 0.315.
	self assert: ar classGenerationRule innateHeadshotDamage equals: 0.55.
	self
		assert: (lmg classGenerationRule maximumFor: #standardMaximum)
		equals: 0.12.
	self
		assert: (rifle classGenerationRule maximumFor: #standardMaximum)
		equals: 0.34.
	self
		assert: (rifle classGenerationRule maximumFor: #prototypeMaximum)
		equals: 0.51.
	self assert: rifle classGenerationRule innateHeadshotDamage equals: 0.80.
	self
		assert: (mmr classGenerationRule maximumFor: #standardMaximum)
		equals: 1.11.
	self assert: (mmr classGenerationRule maximumFor: #prototypeMaximum) isNil.
	self assert: mmr classGenerationRule innateHeadshotDamage equals: 0.
	self assert: pistol classGenerationRule statIdentifier isNil.
	self assert: exotic classGenerationRule statIdentifier equals: 'damageToArmor'.
	item := create
			value: ar id
			value: 'healthDamage'
			value: 0.21.
	self assert: item comparisonStats last statIdentifier equals: 'healthDamage'.
	self assert: item comparisonStats last value equals: 0.21.
	self
		should: [ create
				value: ar id
				value: 'healthDamage'
				value: 0.211 ]
		raise: Error.
	self
		should: [ create
				value: ar id
				value: 'criticalHitChance'
				value: 0.10 ]
		raise: Error.
	item := create
			value: rifle id
			value: 'criticalHitDamage'
			value: 0.34.
	self
		assert: item comparisonStats last statIdentifier
		equals: 'criticalHitDamage'.
	self assert: item comparisonStats last value equals: 0.34.
	self
		should: [ create
				value: rifle id
				value: 'criticalHitDamage'
				value: 0.341 ]
		raise: Error.
	self
		should: [ create
				value: exotic id
				value: 'healthDamage'
				value: 0.21 ]
		raise: Error
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testStrikerShieldResolvesActiveRegenerationFromWorkbookTiers [
	| catalog striker track stats |
	catalog := CIGameItemTypes buildCatalog.
	striker := (catalog gadgetFamilyNamed: 'Shield') variantNamed: 'Striker'.
	track := striker trackNamed: 'Active / Regeneration'.
	self assert: track evidence equals: 'Skill List!C283:M283'.
	self assert: (track magnitudeAtTier: 0) equals: 39817.
	#(43798.7 47780.4 51762.1 55743.8 59725.5 63707.2)
		withIndexDo: [ :expected :tier | 
			stats := striker knownStatsAtTier: tier.
			self assert: (stats at: track label) closeTo: expected ].
	stats := striker knownStatsAtTier: #overcharge.
	self assert: (stats at: track label) closeTo: 63707.2.
	self assert: (striker expertiseRule contributionAtGrade: 20) closeTo: 0.20.
	self assert: striker expertiseRule operation isNil
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testStrikerShieldUsesWorkbookBuffRangeForAllies [
	| catalog striker profile bonus tierZero tierOne overcharge track |
	catalog := CIGameItemTypes buildCatalog.
	striker := (catalog gadgetFamilyNamed: 'Shield') variantNamed: 'Striker'.
	profile := striker behaviorProfile.
	bonus := [ :count :owner :behind :distance :stats | 
		profile
			damageBonusForEnemiesInFront: count
			recipientIsOwner: owner
			allyBehind: behind
			allyDistanceInMetres: distance
			stats: stats ].
	tierZero := striker knownStatsAtTier: 0.
	tierOne := striker knownStatsAtTier: 1.
	overcharge := striker knownStatsAtTier: #overcharge.
	self assert: (tierZero at: 'Buff Range') equals: 10.
	self assert: (tierOne at: 'Buff Range') equals: 10.
	self assert: (overcharge at: 'Buff Range') equals: 10.
	self
		assert: (bonus
				valueWithArguments: {3.
						false.
						true.
						10.
						tierZero})
		closeTo: 0.15.
	self
		assert: (bonus
				valueWithArguments: {3.
						false.
						true.
						10.01.
						tierZero})
		equals: 0.
	self
		assert: (bonus
				valueWithArguments: {3.
						false.
						false.
						1.
						tierZero})
		equals: 0.
	self
		assert: (bonus
				valueWithArguments: {3.
						true.
						false.
						nil.
						tierZero})
		closeTo: 0.15.
	self
		assert: (bonus
				valueWithArguments: {3.
						false.
						true.
						nil.
						tierZero}) isNil.
	self
		assert: (bonus
				valueWithArguments: {3.
						false.
						true.
						5.
						tierOne}) isNil.
	self
		assert: (bonus
				valueWithArguments: {3.
						false.
						true.
						5.
						overcharge}) isNil.
	self
		assert: (bonus
				valueWithArguments: {3.
						false.
						true.
						11.
						overcharge})
		equals: 0.
	track := striker trackNamed: 'Damage bonus / (per enemy)'.
	self assert: (track rawValueAtTier: #overcharge) equals: '+2.5 Buff strength'
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testSwapChainGeneratesWithPerfectUnwaveringAndSharesLockout [
	| catalog weapon item swapChain standard state |
	catalog := CIGameItemTypes buildCatalog.
	weapon := catalog typeAt: 'weapon.workbook.swapChain'.
	self assert: weapon statisticsReference weaponClass equals: #smg.
	item := CIItemGenerator new
			generate: 'swapChain'
			type: weapon id
			values: {'weaponDamage' -> 0.10} asDictionary
			from: catalog
			using: [ 0 ].
	self assert: item talentIdentifier equals: 'perfectUnwavering.swapChain'.
	swapChain := CIWeaponTalentEncounter
			weapon: item itemIdentifier
			talent: (catalog talentAt: item talentIdentifier).
	standard := CIWeaponTalentEncounter
			weapon: 'standard'
			talent: (catalog talentAt: 'unwavering').
	state := CIUnwaveringSwapState new.
	swapChain useUnwaveringSwapState: state.
	standard useUnwaveringSwapState: state.
	standard
		recordWeaponSwapFrom: 'other'
		to: 'standard'
		at: 0.
	self assert: (standard weaponHandlingBonusAt: 0) equals: 3.
	self assert: (standard weaponHandlingBonusAt: 5) equals: 0.
	standard
		recordWeaponSwapFrom: 'standard'
		to: 'other'
		at: 5.
	swapChain
		recordWeaponSwapFrom: 'other'
		to: 'swapChain'
		at: 10.
	self assert: (swapChain weaponHandlingBonusAt: 10) equals: 4.
	swapChain recordEnemyKillFrom: 'swapChain' at: 14.
	self assert: (swapChain weaponHandlingBonusAt: 18) equals: 4.
	swapChain
		recordWeaponSwapFrom: 'swapChain'
		to: 'standard'
		at: 18.
	self assert: (standard weaponHandlingBonusAt: 18) equals: 0
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testTacticalLinksUseSelectedPerksAndTargetConditions [
	| catalog encounter sharpshooter survivalist demolitionist firewall inactive |
	catalog := CIGameItemTypes buildCatalog.
	encounter := [ :name :selected | 
		CISpecializationEncounter
			forLoadout: (catalog specializationLoadoutNamed: name selected: selected)
			mode: #pve
			startedAt: 0 ].
	sharpshooter := encounter
			value: 'Sharpshooter'
			value: #('sharpshooter.sharpshootertacticallink').
	survivalist := encounter
			value: 'Survivalist'
			value: #('survivalist.survivalisttacticallink').
	demolitionist := encounter
			value: 'Demolitionist'
			value: #('demolitionist.demolitionisttacticallink').
	firewall := encounter
			value: 'Firewall'
			value: #('firewall.firewalltacticallink').
	inactive := encounter value: 'Firewall' value: #().
	self
		assert: (sharpshooter
				headshotDamageBonusForGroupMember: true
				attackerDistance: 9
				ownerDistance: 10)
		equals: 0.10.
	self
		assert: (sharpshooter
				headshotDamageBonusForGroupMember: true
				attackerDistance: 10
				ownerDistance: 10)
		equals: 0.
	self
		assert: (sharpshooter
				headshotDamageBonusForGroupMember: false
				attackerDistance: 9
				ownerDistance: 10)
		equals: 0.
	self
		assert: (survivalist damageBonusForGroupMember: true targetHasStatusEffect: true)
		equals: 0.10.
	self
		assert: (survivalist damageBonusForGroupMember: true targetHasStatusEffect: false)
		equals: 0.
	self
		assert: (survivalist damageBonusForGroupMember: false targetHasStatusEffect: true)
		equals: 0.
	self
		assert: (demolitionist damageBonusForGroupMember: true targetOutOfCover: true)
		equals: 0.05.
	self
		assert: (demolitionist damageBonusForGroupMember: true targetOutOfCover: false)
		equals: 0.
	self
		assert: (demolitionist damageBonusForGroupMember: false targetOutOfCover: true)
		equals: 0.
	self
		assert: (firewall damageBonusForAlly: true targetDistanceFromOwner: 10)
		equals: 0.10.
	self
		assert: (firewall damageBonusForAlly: true targetDistanceFromOwner: 10.01)
		equals: 0.
	self
		assert: (firewall damageBonusForAlly: false targetDistanceFromOwner: 10)
		equals: 0.
	self
		assert: (inactive damageBonusForAlly: true targetDistanceFromOwner: 10)
		equals: 0.
	self
		should: [ firewall damageBonusForAlly: true targetDistanceFromOwner: -1 ]
		raise: Error
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testTagTeamConsumesLatestMarkOnlyToReduceActiveCooldowns [
	| catalog reference encounter remaining result |
	catalog := CIGameItemTypes buildCatalog.
	reference := catalog talentReferenceAt: 'Gear Talents!D22'.
	encounter := CIGearTalentEncounter
			talent: (catalog talentAt: reference talentIdentifier).
	self assert: encounter evidence equals: 'Gear Talents!D22:F22'.
	encounter recordGadgetDamageToEnemy: 'first' at: 0.
	encounter recordGadgetDamageToEnemy: 'last' at: 1.
	self assert: encounter markedEnemyIdentifier equals: 'last'.
	self
		assertEmpty: (encounter
				recordWeaponDamageToEnemy: 'last'
				at: 1
				remainingGadgetCooldowns: Dictionary new).
	self assert: encounter markedEnemyIdentifier equals: 'last'.
	remaining := {#hive -> 9.
			#pulse -> 2.
			#shield -> 0} asDictionary.
	self
		assert: (encounter
				recordWeaponDamageToEnemy: 'first'
				at: 2
				remainingGadgetCooldowns: remaining)
		equals: remaining.
	result := encounter
			recordWeaponDamageToEnemy: 'last'
			at: 2
			remainingGadgetCooldowns: remaining.
	self
		assert: result
		equals: {#hive -> 3.
				#pulse -> 0.
				#shield -> 0} asDictionary.
	self assert: (remaining at: #hive) equals: 9.
	self assert: encounter markedEnemyIdentifier isNil.
	encounter recordGadgetDamageToEnemy: 'first' at: 5.99.
	self assert: encounter markedEnemyIdentifier isNil.
	encounter recordGadgetDamageToEnemy: 'first' at: 6.
	self assert: encounter markedEnemyIdentifier equals: 'first'
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testTamperProofArmsAndCoolsDownPerDeployment [
	| catalog reference pulse remote hive turret decoy scanner |
	catalog := CIGameItemTypes buildCatalog.
	reference := catalog talentReferenceAt: 'Gear Talents!D24'.
	pulse := catalog gadgetFamilyNamed: 'Pulse'.
	remote := pulse variantNamed: 'Remote'.
	scanner := pulse variantNamed: 'Scanner'.
	hive := (catalog gadgetFamilyNamed: 'Hive') variants first.
	turret := (catalog gadgetFamilyNamed: 'Turret') variantNamed: 'Assault'.
	decoy := (catalog gadgetFamilyNamed: 'Decoy') variants first.
	{{reference talentIdentifier.
			#pve.
			3.
			10.
			false}.
		{reference perfectTalentIdentifier.
			#pve.
			3.
			8.
			true}.
		{reference talentIdentifier.
			#pvp.
			4.
			15.
			false}.
		{reference perfectTalentIdentifier.
			#pvp.
			4.
			10.
			true}}
		do: [ :row | 
			| encounter radius readyAt shockOn |
			encounter := CIGearTalentEncounter
					talent: (catalog talentAt: row first)
					mode: row second.
			radius := row third.
			readyAt := 2 + row fourth.
			shockOn := [ :deployment :seconds :distance | 
				encounter
					statusOnEnemyEnteringRangeOfGadget: deployment
					at: seconds
					distanceMetres: distance ].
			encounter
				recordGadgetDeployment: #hive
				variant: hive
				at: 0.
			encounter
				recordGadgetDeployment: #turret
				variant: turret
				at: 0.
			encounter
				recordGadgetDeployment: #remote
				variant: remote
				at: 0.
			encounter
				recordGadgetDeployment: #scanner
				variant: scanner
				at: 0.
			encounter
				recordGadgetDeployment: #decoy
				variant: decoy
				at: 0.
			self
				assert: (shockOn
						value: #hive
						value: 1.99
						value: radius) isNil.
			self
				assert: (shockOn
						value: #hive
						value: 2
						value: radius + 0.01) isNil.
			self
				assert: (shockOn
						value: #hive
						value: 2
						value: radius)
				equals: #shock.
			self
				assert: (shockOn
						value: #turret
						value: 2
						value: radius)
				equals: #shock.
			self
				assert: (shockOn
						value: #remote
						value: 2
						value: radius)
				equals: #shock.
			self
				assert: (shockOn
						value: #scanner
						value: 2
						value: radius) isNil.
			self
				assert: (shockOn
						value: #decoy
						value: 2
						value: radius)
				equals: (row fifth ifTrue: [ #shock ]).
			self
				assert: (shockOn
						value: #hive
						value: readyAt - 0.01
						value: radius) isNil.
			self
				assert: (shockOn
						value: #hive
						value: readyAt
						value: radius)
				equals: #shock.
			encounter recordGadgetDeploymentEnded: #hive at: readyAt.
			self
				assert: (shockOn
						value: #hive
						value: readyAt + 20
						value: radius) isNil ]
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testTechSupportUsesWorkbookDamageDurationsAndFixedNamedTalent [
	| catalog reference named values item |
	catalog := CIGameItemTypes buildCatalog.
	reference := catalog talentReferenceAt: 'Gear Talents!D27'.
	{{reference talentIdentifier.
			25}.
		{reference perfectTalentIdentifier.
			27}}
		do: [ :row | 
			| talent encounter |
			talent := catalog talentAt: row first.
			encounter := CIGearTalentEncounter talent: talent.
			self assert: (encounter totalSkillDamageBonusAt: 0) equals: 0.
			encounter recordGadgetKillAt: 1.
			self assert: (encounter totalSkillDamageBonusAt: row second) equals: 0.25.
			self assert: (encounter totalSkillDamageBonusAt: row second + 1) equals: 0.
			encounter recordGadgetKillAt: 40.
			encounter recordGadgetKillAt: 41.
			self
				assert: (encounter totalSkillDamageBonusAt: 40 + row second)
				equals: 0.25.
			self assert: (encounter totalSkillDamageBonusAt: 41 + row second) equals: 0.
			self assert: (talent parametersForMode: #pvp) isNil ].
	named := catalog namedGearReferenceAt: 'Percussive Maintenance'.
	values := {'minor1'
				-> (CIGearAttributeRoll attribute: 'gear.minor.criticalHitChance' value: 0.05).
			'minor2'
				-> (CIGearAttributeRoll attribute: 'gear.minor.criticalHitDamage' value: 0.10)}
			asDictionary.
	item := CIInventoryReadStore new
			grantItem: 'percussive'
			type: named itemDefinitionIdentifier
			values: values
			from: catalog
			forOwner: 'owner'
			using: [ self error: 'Fixed talent must not draw' ].
	self assert: item talentIdentifier equals: reference perfectTalentIdentifier.
	self assert: item gearSlotIdentifier equals: 'Backpack'.
	self assert: item modSlots size equals: 1
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testTransferenceOverclockUsesRecipientLockout [
	| reference rule effects |
	reference := CIGameItemTypes buildCatalog
			namedGearReferenceAt: 'BTSU Datagloves'.
	rule := reference gadgetTalentRule.
	self assert: rule evidence equals: 'Gear Named + Exotics!F101:G101'.
	self assert: (rule hiveHasteAtGadgetTier: 0) equals: 0.
	self assert: (rule hiveHasteAtGadgetTier: 3) closeTo: 0.45.
	self assert: (rule hiveHasteAtGadgetTier: #overcharge) isNil.
	effects := rule
			effectsOnHiveDetonationFor: #self
			detonatorGadgetTier: 3
			secondsSinceLastTransfer: 0.
	self assert: (effects at: #refreshGadgetCooldowns).
	self assert: (effects at: #overchargeSeconds) equals: 15.
	self
		assert: (rule
				effectsOnHiveDetonationFor: #ally
				detonatorGadgetTier: 6
				secondsSinceLastTransfer: nil)
		equals: effects.
	self
		assertEmpty: (rule
				effectsOnHiveDetonationFor: #ally
				detonatorGadgetTier: 5
				secondsSinceLastTransfer: nil).
	self
		assertEmpty: (rule
				effectsOnHiveDetonationFor: #enemy
				detonatorGadgetTier: 6
				secondsSinceLastTransfer: nil).
	self
		assertEmpty: (rule
				effectsOnHiveDetonationFor: #ally
				detonatorGadgetTier: 6
				secondsSinceLastTransfer: 119.99).
	self
		assert: (rule
				effectsOnHiveDetonationFor: #ally
				detonatorGadgetTier: 6
				secondsSinceLastTransfer: 120)
		equals: effects
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testUnwaveringRefreshAndSwapLockoutApplyAcrossWeapons [
	| catalog talent shared first second |
	catalog := CIGameItemTypes buildCatalog.
	talent := catalog talentAt: 'perfectUnwavering.sharpshooter93r'.
	first := CIWeaponTalentEncounter weapon: 'first93r' talent: talent.
	second := CIWeaponTalentEncounter weapon: 'second93r' talent: talent.
	shared := CIUnwaveringSwapState new.
	first useUnwaveringSwapState: shared.
	second useUnwaveringSwapState: shared.
	first
		recordWeaponSwapFrom: 'ordinary'
		to: 'first93r'
		at: 0.
	self assert: (first weaponHandlingBonusAt: 0) equals: 4.
	first recordEnemyKillFrom: 'second93r' at: 3.
	first recordEnemyKillFrom: 'first93r' at: 4.
	self assert: (first weaponHandlingBonusAt: 5) equals: 4.
	self assert: (first weaponHandlingBonusAt: 9) equals: 0.
	first
		recordWeaponSwapFrom: 'first93r'
		to: 'second93r'
		at: 10.
	self assert: (first weaponHandlingBonusAt: 10) equals: 0.
	self assert: (second weaponHandlingBonusAt: 10) equals: 0.
	second
		recordWeaponSwapFrom: 'second93r'
		to: 'ordinary'
		at: 11.
	second
		recordWeaponSwapFrom: 'ordinary'
		to: 'second93r'
		at: 16.
	self assert: (second weaponHandlingBonusAt: 16) equals: 4.
	self assert: (first weaponHandlingBonusAt: 16) equals: 0
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testVerifiedSpecializationReturnsOnlySelectedUpgradesForMatchingGadget [
	| owner tactician perks graphene carbon |
	self startInventory.
	owner := 'gadget-upgrade-owner'.
	tactician := 'gadget.workbook.drone.tactician'.
	self
		should: [ service
				selectSpecialization: 'Sharpshooter'
				perks: #('sharpshooter.tactician' 'sharpshooter.carbonfiberframe')
				forVerifiedUser: owner ]
		raise: Error.
	service
		selectSpecialization: 'Sharpshooter'
		perks: #('sharpshooter.tactician' 'sharpshooter.graphenebattery')
		forVerifiedUser: owner.
	perks := service
			specializationGadgetUpgradePerksForType: tactician
			forVerifiedUser: owner.
	self assert: (perks collect: #id) equals: #('sharpshooter.graphenebattery').
	graphene := perks first gadgetUpgrade.
	self assert: graphene reportedMagnitude equals: 0.15.
	self assert: graphene resolvedTrack label equals: 'Duration'.
	service
		selectSpecialization: 'Sharpshooter'
		perks: #('sharpshooter.tactician' 'sharpshooter.graphenebattery' 'sharpshooter.carbonfiberframe')
		forVerifiedUser: owner.
	perks := service
			specializationGadgetUpgradePerksForType: tactician
			forVerifiedUser: owner.
	self assert: perks size equals: 2.
	carbon := (perks detect: [ :perk | perk id = 'sharpshooter.carbonfiberframe' ])
			gadgetUpgrade.
	self assert: carbon reportedStatLabel equals: 'Scan Range'.
	self assert: carbon reportedMagnitude equals: 0.20.
	self deny: carbon isResolved.
	self
		assertEmpty: (service
				specializationGadgetUpgradePerksForType: 'gadget.workbook.shield.striker'
				forVerifiedUser: owner).
	self
		assertEmpty: (service
				specializationGadgetUpgradePerksForType: tactician
				forVerifiedUser: 'other-owner')
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testVersionOneInventorySnapshotCanStoreSpecialization [
	| path owner item old new selection |
	path := (directory / 'legacy-selection.ston') fullName.
	owner := 'legacy-owner'.
	item := CIInventoryItemSummary
			item: 'item'
			definition: 'legacy.definition'
			name: 'Legacy item'.
	path asFileReference
		writeStreamDo: [ :stream | 
			STON
				put: {1.
						Dictionary new
							at: owner put: {item};
							yourself.
						nil}
				onStream: stream ].
	old := CIInventorySnapshotStore at: path.
	self assert: (old specializationForOwner: owner) isNil.
	self assert: (old allRowsForOwner: owner) first itemIdentifier equals: 'item'.
	selection := CISpecializationSelection
			specialization: 'Technician'
			perks: #('technician.amped').
	old specialization: selection forOwner: owner.
	new := CIInventorySnapshotStore at: path.
	self assert: (new allRowsForOwner: owner) first itemIdentifier equals: 'item'.
	self
		assert: (new specializationForOwner: owner) perkIdentifiers
		equals: #('technician.amped')
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testWeaponAttachmentUnlocksAndOwnedGearModsPersist [
	| catalogue mods owner path store vest gloves mod unlock reloaded rows values |
	catalogue := CIGameItemTypes buildCatalog.
	mods := catalogue modCatalogue.
	owner := 'mod-test-owner'.
	path := (directory / 'mods.ston') fullName.
	store := CIInventorySnapshotStore at: path.
	vest := 'gear.launch.vossAndVale.chest'.
	gloves := 'gear.launch.vossAndVale.gloves'.
	values := Dictionary new
			at: 'weaponDamage' put: 0.1;
			yourself.
	store
		grantItem: 'vest'
		type: vest
		values: values
		from: catalogue
		forOwner: owner.
	store
		grantItem: 'gloves'
		type: gloves
		values: values
		from: catalogue
		forOwner: owner.
	self
		assert: (mods definitionAt: 'gearMod.criticalHitChance') maximum
		equals: 0.06.
	self
		assert: ((mods definitionAt: 'gearMod.criticalHitChance') maximumAtTier: 2) isNil.
	self
		should: [ store
				grantGearMod: 'bad'
				definition: 'gearMod.criticalHitChance'
				tier: 2
				value: 0.07
				from: catalogue
				forOwner: owner ]
		raise: Error.
	mod := store
			grantGearMod: 'rolled'
			definition: 'gearMod.criticalHitChance'
			tier: 2
			value: 0.04
			from: catalogue
			forOwner: owner.
	store
		installMod: mod itemIdentifier
		on: 'vest'
		socket: 'gearMod'
		from: catalogue
		forOwner: owner.
	self
		should: [ store
				installMod: mod itemIdentifier
				on: 'gloves'
				socket: 'gearMod'
				from: catalogue
				forOwner: owner ]
		raise: Error.
	self
		should: [ store
				installMod: mod itemIdentifier
				on: 'vest'
				socket: 'gearMod'
				from: catalogue
				forOwner: 'other' ]
		raise: Error.
	mods
		registerSocket: (CIItemSocket id: 'optic' interface: #shortOpticsRail)
		forItem: 'weapon.launch.akM'.
	mods
		registerSocket: (CIItemSocket id: 'optic' interface: #longOpticsRail)
		forItem: 'weapon.launch.tacticalMk16'.
	store
		grantItem: 'weapon-a'
		type: 'weapon.launch.akM'
		values: values
		from: catalogue
		forOwner: owner.
	store
		grantItem: 'weapon-b'
		type: 'weapon.launch.akM'
		values: values
		from: catalogue
		forOwner: owner.
	store
		grantItem: 'weapon-c'
		type: 'weapon.launch.tacticalMk16'
		values: values
		from: catalogue
		forOwner: owner.
	unlock := store
			unlockWeaponMod: 'attachment.lowReflexSight'
			from: catalogue
			forOwner: owner.
	self
		assert: (store
				unlockWeaponMod: unlock definitionIdentifier
				from: catalogue
				forOwner: owner) itemIdentifier
		equals: unlock itemIdentifier.
	#('weapon-a' 'weapon-b')
		do: [ :id | 
			store
				installMod: unlock itemIdentifier
				on: id
				socket: 'optic'
				from: catalogue
				forOwner: owner ].
	self
		should: [ store
				installMod: unlock itemIdentifier
				on: 'weapon-c'
				socket: 'optic'
				from: catalogue
				forOwner: owner ]
		raise: Error.
	reloaded := CIInventorySnapshotStore at: path.
	rows := reloaded allRowsForOwner: owner.
	self assert: (rows count: [ :row | row isKindOf: CIWeaponModUnlock ]) equals: 1.
	self
		assert: (rows detect: [ :row | row itemIdentifier = 'rolled' ]) rolledValue
		equals: 0.04.
	self
		assert: (rows detect: [ :row | row itemIdentifier = 'rolled' ]) tierId
		equals: 2.
	self
		assert: (rows detect: [ :row | row itemIdentifier = 'vest' ]) modSlots first
				equippedModIdentifier
		equals: 'rolled'.
	#('weapon-a' 'weapon-b')
		do: [ :id | 
			self
				assert: (rows detect: [ :row | row itemIdentifier = id ]) modSlots first
						equippedModIdentifier
				equals: unlock itemIdentifier ]
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testWeaponMountLayoutsPreserveReportedCountsMissingKindsAndEvidence [
	| catalog ak pp m870 p90 zero blank |
	catalog := CIGameItemTypes buildCatalog.
	ak := catalog weaponMountLayoutForType: 'weapon.launch.akM'.
	self assert: ak reportedSlotCount equals: 3.
	self assert: ak rawNotation equals: '3!'.
	self assert: ak evidence equals: 'Weapons!N4'.
	self assert: ak missingSlotKinds equals: #(muzzle).
	self assert: (ak statusOfSlotKind: #muzzle) equals: #absent.
	self assert: (ak statusOfSlotKind: #optics) equals: #unspecified.
	pp := catalog weaponMountLayoutForType: 'weapon.launch.pp19'.
	self assert: pp reportedSlotCount equals: 2.
	self assert: pp missingSlotKinds asSet equals: #(magazine underbarrel) asSet.
	m870 := catalog weaponMountLayoutForType: 'weapon.launch.m870Express'.
	self assert: m870 longRailReported.
	self assert: (m870 statusOfSlotKind: #optics) equals: #unspecified.
	self assert: (m870 statusOfSlotKind: #underbarrel) equals: #unspecified.
	p90 := catalog weaponMountLayoutForType: 'weapon.launch.chatterbox'.
	self assert: p90 status equals: #notApplicable.
	self assert: p90 reportedSlotCount isNil.
	self assert: (p90 statusOfSlotKind: #magazine) equals: #notApplicable.
	zero := (catalog weaponReferenceAt: 'Weapons!C144') mountLayout.
	self assert: zero reportedSlotCount equals: 0.
	self assert: (zero statusOfSlotKind: #magazine) equals: #absent.
	blank := CIWeaponMountLayout fromNotation: nil evidence: nil.
	self assert: blank reportedSlotCount isNil.
	self assert: (blank statusOfSlotKind: #magazine) equals: #unspecified
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testWeaponMountLayoutsRetainUnknownMarkersAndKeepFactorySocketsDistinct [
	| catalog rpk stoner chatterbox magazine |
	catalog := CIGameItemTypes buildCatalog.
	rpk := catalog weaponMountLayoutForType: 'weapon.launch.classicRpk74'.
	self assert: rpk reportedSlotCount equals: 4.
	self assert: rpk unresolvedMarkers equals: '/'.
	self deny: rpk longRailReported.
	stoner := (catalog weaponReferenceAt: 'Weapons!C63') mountLayout.
	self assert: stoner rawNotation equals: '4*'.
	self assert: stoner unresolvedMarkers equals: '*'.
	self assert: stoner evidence equals: 'Weapons!N63'.
	chatterbox := 'weapon.launch.chatterbox'.
	magazine := catalog modCatalogue socketAt: 'magazine' forItem: chatterbox.
	self assert: magazine fixedModIdentifier notNil.
	self
		assertEmpty: (catalog modCatalogue compatibleModsFor: chatterbox socket: 'magazine').
	self
		assertEmpty: (catalog modCatalogue socketsFor: 'weapon.launch.classicRpk74')
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testWeaponReferencesAndNamedTalentsKeepWorkbookLinks [
	| catalog references splash type store award source archivist |
	catalog := CIGameItemTypes buildCatalog.
	references := catalog weaponReferences.
	self
		assert: (references count: [ :entry | entry kind = #statistics ])
		equals: 316.
	self
		assert: (references count: [ :entry | entry kind ~= #statistics ])
		equals: 141.
	splash := catalog weaponReferenceAt: 'Weapons Named + Exotics!C131'.
	self assert: splash name equals: 'The Chatterbox'.
	self
		assert: (splash evidenceForField: #talentOrAttribute)
		equals: 'Weapons Named + Exotics!E130'.
	self assert: splash itemDefinitionIdentifier equals: 'weapon.launch.chatterbox'.
	self
		assert: (catalog weaponReferencesNamed: 'Shield Splinterer') size
		equals: 2.
	archivist := (catalog weaponReferencesNamed: 'The Archivist') first.
	self assert: archivist itemDefinitionIdentifier isNil.
	type := catalog typeAt: 'weapon.workbook.shieldSplinterer'.
	self assert: type baseMagazineCapacity equals: 30.
	self assert: (type statisticsReference fieldAt: #socketNotation) equals: '3#'.
	self
		assert: (type namedReference evidenceForField: #acquisition)
		equals: 'Weapons Named + Exotics!I8'.
	store := CIInventoryReadStore new.
	award := store
			grantItem: 'named-weapon'
			type: type id
			values: (Dictionary new
					at: 'weaponDamage' put: 0.15;
					yourself)
			from: catalog
			forOwner: 'named-owner'
			using: [ self error: 'Fixed talent must not draw' ].
	self assert: award talentIdentifier equals: 'perfectOptimist'.
	self assertEmpty: award modSlots.
	source := (catalog lootCatalogue poolsForItem: type id) first.
	self assert: source source name equals: 'Ivory Cache / then Cassie Mendoza'.
	self deny: source isComplete.
	self assert: source entries first weight isNil
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testWeaponTalentBoundariesAndPerfectVariants [
	| catalog make optimist perfect ranger repair reload |
	catalog := CIGameItemTypes buildCatalog.
	make := [ :id | CIWeaponTalentEncounter weapon: 'weapon' talent: (catalog talentAt: id) ].
	optimist := make value: 'optimist'.
	perfect := make value: 'perfectOptimist'.
	self
		assert: (optimist weaponDamageBonusForMagazine: 30 remaining: 28)
		equals: 0.
	self
		assert: (optimist weaponDamageBonusForMagazine: 30 remaining: 21)
		closeTo: 0.105.
	self
		assert: (perfect weaponDamageBonusForMagazine: 30 remaining: 21)
		closeTo: 0.135.
	self
		assert: (optimist weaponDamageBonusForMagazine: 30 remaining: 0)
		closeTo: 0.35.
	ranger := make value: 'ranger'.
	self assert: (ranger weaponDamageMultiplierAtDistance: 3.9) equals: 1.
	self assert: (ranger weaponDamageMultiplierAtDistance: 4) equals: 1.02.
	self
		assert: ((make value: 'perfectRanger') weaponDamageMultiplierAtDistance: 6)
		equals: 1.04.
	repair := (make value: 'perfectPreservation')
			armorRepairOnKillFrom: 'weapon'
			headshot: true.
	self assert: repair fraction closeTo: 0.30.
	self assert: repair durationSeconds equals: 5.
	self
		assert: ((make value: 'preservation') armorRepairOnKillFrom: 'another' headshot: true)
				isNil.
	reload := make value: 'perfectFastHands'.
	reload
		recordEnemyHitFrom: 'weapon'
		critical: false
		at: 0.
	reload
		recordEnemyHitFrom: 'another'
		critical: true
		at: 0.
	self assert: reload reloadSpeedBonus equals: 0.
	45
		timesRepeat: [ reload
				recordEnemyHitFrom: 'weapon'
				critical: true
				at: 1 ].
	self assert: reload reloadSpeedBonus equals: 2
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testWorkbookExpertiseScalesByGradeAndPreservesUnresolvedMappings [
	| catalog variants rules pulse scanner achilles striker artificer assault |
	catalog := CIGameItemTypes buildCatalog.
	variants := catalog gadgetFamilies flatCollect: #variants.
	rules := variants collect: #expertiseRule.
	self assert: rules size equals: 43.
	self deny: (rules includes: nil).
	self assert: (rules count: [ :rule | rule targetTrackLabel isNil ]) equals: 1.
	rules do: [ :rule | self assert: (rule contributionAtGrade: 3) closeTo: 0.03 ].
	pulse := catalog gadgetFamilyNamed: 'Pulse'.
	scanner := (pulse variantNamed: 'Scanner') expertiseRule.
	self assert: scanner targetTrackLabel equals: 'Duration'.
	self assert: scanner evidence equals: 'Skill List!M65'.
	self assert: scanner operation isNil.
	self assert: (scanner contributionAtGrade: 0) equals: 0.
	self should: [ scanner contributionAtGrade: -1 ] raise: Error.
	self should: [ scanner contributionAtGrade: 0.5 ] raise: Error.
	achilles := (pulse variantNamed: 'Achilles') expertiseRule.
	self assert: achilles operation equals: #amplifier.
	self assert: achilles targetTrackLabel isNil.
	assault := ((catalog gadgetFamilyNamed: 'Turret') variantNamed: 'Assault')
			expertiseRule.
	self assert: assault operation equals: #additive.
	self assert: assault targetTrackLabel equals: 'Damage'.
	striker := ((catalog gadgetFamilyNamed: 'Shield') variantNamed: 'Striker')
			expertiseRule.
	self assert: striker targetTrackLabel equals: 'Active / Regeneration'.
	self assert: striker reportedStat equals: 'Regeneration'.
	self assert: striker evidence equals: 'Skill List!M277'.
	self assert: striker operation isNil.
	self assert: (striker contributionAtGrade: 20) closeTo: 0.20.
	artificer := ((catalog gadgetFamilyNamed: 'Hive') variantNamed: 'Artificer')
			expertiseRule.
	self assert: artificer targetTrackLabel equals: 'Buff Amount'
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testWorkbookFactoryAttachmentsAreLockedAndPersist [
	| catalog mods owner path store item reloaded attachment magazine |
	catalog := CIGameItemTypes buildCatalog.
	mods := catalog modCatalogue.
	owner := 'factory-attachment-owner'.
	path := (directory / 'factory.ston') fullName.
	store := CIInventorySnapshotStore at: path.
	self assert: CIWorkbookModData weaponAttachments size equals: 94.
	self assert: CIWorkbookModData gearMods size equals: 11.
	self assert: CIWorkbookModData factoryAttachments size equals: 7.
	self
		assert: (mods definitionAt: 'attachment.workbook72') modelRestriction
		equals: 'Stoner only and Dare Only'.
	item := store
			grantItem: 'chatterbox'
			type: 'weapon.launch.chatterbox'
			values: (Dictionary new
					at: 'weaponDamage' put: 0.1;
					yourself)
			from: catalog
			forOwner: owner.
	self assert: item modSlots size equals: 4.
	self assert: (item modSlots allSatisfy: #isLocked).
	magazine := item modSlots detect: [ :slot | slot slotIdentifier = 'magazine' ].
	attachment := mods definitionAt: magazine equippedModIdentifier.
	self assert: attachment effects first equals: #(magazineCapacity flat 10).
	self assert: attachment evidence equals: 'Weapons Named + Exotics!F130'.
	self
		assertEmpty: (mods compatibleModsFor: 'weapon.launch.chatterbox' socket: 'magazine').
	self
		should: [ store
				unlockWeaponMod: attachment id
				from: catalog
				forOwner: owner ]
		raise: Error.
	self
		should: [ store
				removeModFrom: 'chatterbox'
				socket: 'magazine'
				forOwner: owner ]
		raise: Error.
	reloaded := ((CIInventorySnapshotStore at: path) allRowsForOwner: owner) first.
	self assert: (reloaded modSlots allSatisfy: #isLocked).
	self
		assert: (reloaded modSlots collect: #equippedModIdentifier)
		equals: (item modSlots collect: #equippedModIdentifier).
	store
		replaceRows: {(catalog typeAt: 'weapon.launch.chatterbox')
					inventoryItem: 'legacy'
					values: (Dictionary new
							at: 'weaponDamage' put: 0.1;
							yourself)}
		forOwner: owner.
	store restoreFactoryAttachmentsFrom: catalog.
	reloaded := ((CIInventorySnapshotStore at: path) allRowsForOwner: owner) first.
	self assert: reloaded itemIdentifier equals: 'legacy'.
	self assert: reloaded modSlots size equals: 4.
	self assert: (reloaded modSlots allSatisfy: #isLocked)
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testWorkbookFamiliesRetainModeColumnsMultiCoreAndNamedMembership [
	| catalog references core eclipse gila brand store row values evaluated |
	catalog := CIGameItemTypes buildCatalog.
	references := catalog gearFamilyReferences.
	self
		assert: (references count: [ :reference | reference kind = #brand ])
		equals: 37.
	self
		assert: (references count: [ :reference | reference kind = #gearSet ])
		equals: 28.
	core := catalog gearFamilyReferenceAt: 'Core Strength'.
	self
		assert: (core valuesFor: #coreOrSlotRule)
		equals: #('Weapon Damage' 'Skill Tier' 'Armor').
	self
		assert: (core referencesFor: #coreOrSlotRule)
		equals: #('Gearsets!B12' 'Gearsets!B13' 'Gearsets!B14').
	self assert: core runtimeFamilyIdentifier isNil.
	eclipse := catalog gearFamilyReferenceAt: 'Eclipse Protocol'.
	self assert: eclipse runtimeFamilyIdentifier equals: 'jupiterTechnologies'.
	self assert: (eclipse referencesFor: #vestTalent) equals: #('Gearsets!F15').
	gila := catalog gearFamilyReferenceAt: 'Gila Guard'.
	self assert: (gila valuesFor: #pveTwoPiece) equals: #('20% Hazard Protection').
	self assert: (gila valuesFor: #pvpTwoPiece) equals: #('15% Hazard Protection').
	brand := catalog gearFamilyAt: gila runtimeFamilyIdentifier.
	self
		assert: (brand tiers second modifiersForMode: #pvp) first magnitude
		equals: 0.15.
	self
		assert: (brand tiers second modifiersForMode: #pvp) first unit
		equals: #fraction.
	store := CIInventoryReadStore new.
	values := Dictionary new
			at: 'core' put: 50000;
			at: 'minor1'
				put: (CIGearAttributeRoll attribute: 'gear.minor.criticalHitChance' value: 0.05);
			at: 'minor2'
				put: (CIGearAttributeRoll attribute: 'gear.minor.criticalHitDamage' value: 0.10);
			yourself.
	row := store
			grantItem: 'courier'
			type: 'gear.workbook.theCourier'
			values: values
			from: catalog
			forOwner: 'owner'.
	row equippedSlotIdentifier: 'Backpack'.
	evaluated := (CILoadoutFamilyEvaluator new
			evaluateRows: {row}
			catalogue: catalog
			mode: #pve)
			detect: [ :activation | activation family manufacturer = 'Habsburg Guard' ].
	self assert: evaluated equippedCount equals: 1.
	self assert: evaluated modifiers first stat equals: #headshotDamage.
	self assert: evaluated modifiers first magnitude equals: 0.13
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testWorkbookFixedMuzzlesPreserveReportedValueAndCarryForwardEvidence [
	| catalog stoner quietRoar qdc bluescreen |
	catalog := CIGameItemTypes buildCatalog.
	stoner := (catalog weaponReferenceAt: 'Weapons!C63') mountLayout.
	quietRoar := (catalog weaponReferenceAt: 'Weapons!C64') mountLayout.
	{stoner.
		quietRoar}
		do: [ :layout | 
			| mount |
			self assert: layout fixedMounts size equals: 1.
			self assert: (layout statusOfSlotKind: #muzzle) equals: #fixed.
			self assert: (layout statusOfSlotKind: #magazine) equals: #unspecified.
			mount := layout fixedMounts first.
			self assert: mount effects equals: #(#(stability percent 0.30)).
			self assert: mount evidence equals: 'Weapons!P63'.
			self assert: mount attachment isNil ].
	self assert: stoner fixedMounts first inheritedEvidence isNil.
	self
		assert: quietRoar fixedMounts first inheritedEvidence
		equals: 'Weapons!P64'.
	qdc := catalog modCatalogue definitionAt: 'attachment.workbook72'.
	self assert: qdc effects equals: #(#(stability percent 0.20)).
	bluescreen := catalog weaponMountLayoutForType: 'weapon.launch.bluescreen'.
	self assertEmpty: bluescreen fixedMounts
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testWorkbookFixedOpticsRetainCatalogLinkAndInheritedRows [
	| catalog gr9 dare cricket scope |
	catalog := CIGameItemTypes buildCatalog.
	gr9 := (catalog weaponReferenceAt: 'Weapons!C70') mountLayout.
	dare := (catalog weaponReferenceAt: 'Weapons!C71') mountLayout.
	cricket := (catalog weaponReferenceAt: 'Weapons!C72') mountLayout.
	{gr9.
		dare.
		cricket}
		do: [ :layout | 
			| mount |
			self assert: (layout statusOfSlotKind: #optics) equals: #fixed.
			mount := layout fixedMounts first.
			self assert: mount effects equals: #(#(criticalHitChance percent 0.05)).
			self assert: mount evidence equals: 'Weapons!P70' ].
	scope := gr9 fixedMounts first attachment.
	self assert: scope id equals: 'attachment.workbook8'.
	self assert: scope kind equals: #factoryAttachment.
	self assert: scope effects equals: gr9 fixedMounts first effects.
	self assert: dare fixedMounts first inheritedEvidence equals: 'Weapons!P71'.
	self assert: cricket fixedMounts first inheritedEvidence equals: 'Weapons!P72'.
	self
		assertEmpty: (catalog weaponReferenceAt: 'Weapons!C158') mountLayout fixedMounts
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testWorkbookGadgetInventoryKeepsIdentityAndUsesEquippedSkillTier [
	| catalog type store path owner gadget gear equipped restored rows graph |
	catalog := CIGameItemTypes buildCatalog.
	catalog gadgetFamilies
		do: [ :family | 
			family variants
				do: [ :variant | 
					type := catalog typeAt: (CIWorkbookGadgetData identifierFor: variant).
					self assert: type workbookVariantDefinition identicalTo: variant ] ].
	type := catalog typeAt: 'gadget.workbook.pulse.scanner'.
	self assert: (type baseStats at: 'Effect Radius') equals: 100.
	self
		assert: ((catalog typeAt: 'gadget.pulse.scanner') baseStats at: #scanRadiusMetres)
		equals: 20.
	path := (directory / 'gadget.ston') fullName.
	store := CIInventorySnapshotStore at: path.
	owner := 'workbook-gadget-owner'.
	gadget := store
			grantItem: 'scanner'
			type: type id
			values: Dictionary new
			from: catalog
			forOwner: owner.
	gear := store
			grantItem: 'vest'
			type: 'gear.launch.morrowWorks.chest'
			values: (Dictionary new
					at: 'skillTier' put: 1;
					yourself)
			from: catalog
			forOwner: owner.
	self
		assert: (CIInventoryProfileGraph
				workbookGadgetTierForRows: {gadget.
						gear})
		equals: 0.
	equipped := store
			rowsAfterEquipping: #(#('GadgetLeft' 'scanner') #('Chest' 'vest'))
			forOwner: owner
			outfit: false.
	store replaceRows: equipped forOwner: owner.
	restored := CIInventorySnapshotStore at: path.
	rows := restored allRowsForOwner: owner.
	self assert: rows first definitionIdentifier equals: type id.
	self assert: rows first equippedSlotIdentifier equals: 'GadgetLeft'.
	self
		assert: (CIInventoryProfileGraph workbookGadgetTierForRows: rows)
		equals: 1.
	graph := CIInventoryProfileGraph
			forVerifiedUser: owner
			rows: rows
			savedSets: Dictionary new
			catalog: catalog.
	self assert: ((STON toString: graph) includesSubstring: '9.200 s').
	self assert: ((STON toString: graph) includesSubstring: '100 m')
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testWorkbookGadgetTiersKeepMissingAndOverchargeSeparate [
	| catalog pulse scanner tactician track repair cooldown |
	catalog := CIGameItemTypes buildCatalog.
	self assert: catalog gadgetFamilies size equals: 12.
	self
		assert: (catalog gadgetFamilies sum: [ :family | family variants size ])
		equals: 43.
	self
		assert: (catalog gadgetFamilies
				sum: [ :family | family variants sum: [ :variant | variant tracks size ] ])
		equals: 270.
	pulse := catalog gadgetFamilyNamed: 'Pulse'.
	scanner := pulse variantNamed: 'Scanner'.
	self assert: ((scanner knownStatsAtTier: 0) at: 'Effect Radius') equals: 100.
	self
		assert: (((scanner knownStatsAtTier: 6) at: 'Duration') - 15.2) abs < 0.001.
	self
		assert: ((scanner knownStatsAtTier: #overcharge) at: 'Duration')
		equals: 24.
	self assert: (scanner overchargeEffects first includesSubstring: '15%').
	self assert: (scanner expertiseScaling first includesSubstring: '+1% Duration').
	cooldown := scanner trackNamed: 'Cooldown'.
	self assert: (cooldown rawValueAtTier: 1) equals: '-'.
	self assert: (cooldown magnitudeAtTier: 1) equals: 20.
	tactician := (catalog gadgetFamilyNamed: 'Drone') variantNamed: 'Tactician'.
	track := tactician trackNamed: 'Scan Range'.
	self assert: track unit equals: #metres.
	self assert: track evidence equals: 'Skill List!C260:M260'.
	self assert: (track magnitudeAtTier: 6) equals: 80.
	self assert: (track magnitudeAtTier: #overcharge) equals: 90.
	repair := ((catalog gadgetFamilyNamed: 'Chem Launcher')
			variantNamed: 'Reinforcer') trackNamed: 'Repair Over Time'.
	self assert: (repair rawValueAtTier: 1) isNil.
	self assert: (repair magnitudeAtTier: 1) isNil.
	self should: [ scanner knownStatsAtTier: 7 ] raise: Error
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testWorkbookGrenadeProfilesResolveEffectsOnlyForEligibleTargets [
	| catalog effect emp riot fragment cluster |
	catalog := CIGameItemTypes buildCatalog.
	effect := [ :key | (catalog typeAt: 'grenade.specialization.' , key) effectProfile ].
	self
		assert: ((effect value: 'sharpshooter.flashbanggrenade')
				statusesForTargetKind: #ally
				withinAffectedArea: true)
		equals: #(blind).
	self
		assert: ((effect value: 'survivalist.incendiarygrenade')
				statusesForTargetKind: #enemy
				withinAffectedArea: true)
		equals: #(burn).
	emp := effect value: 'technician.empgrenade'.
	self
		assert: (emp statusesForTargetKind: #electricalAbility withinAffectedArea: true)
		equals: #(disrupt).
	self assertEmpty: (emp statusesForTargetKind: #enemy withinAffectedArea: true).
	self
		assertEmpty: (emp statusesForTargetKind: #electricalAbility withinAffectedArea: false).
	self
		assert: (emp statusesForTargetKind: #electricalAbility atDistance: 2) isNil.
	riot := effect value: 'gunner.riotfoamgrenade'.
	self
		assert: (riot statusesForTargetKind: #enemy atDistance: 3)
		equals: #(ensnare).
	self assertEmpty: (riot statusesForTargetKind: #enemy atDistance: 3.01).
	self assertEmpty: (riot statusesForTargetKind: #ally atDistance: 2).
	self assert: (riot radiusEvidence includesSubstring: 'episode-1-patch-notes').
	fragment := effect value: 'demolitionist.fragmentationgrenade'.
	self assert: fragment dealsDamage.
	self
		assert: (fragment statusesForTargetKind: #enemy withinAffectedArea: true)
		equals: #(bleed).
	cluster := effect value: 'firewall.clustergrenade'.
	self assert: cluster delivery equals: #secondaryDetonations.
	self assert: cluster radiusMetres isNil
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testWorkbookLootSourcesKeepUnknownOdds [
	| catalog loot pools entry |
	catalog := CIGameItemTypes buildCatalog.
	loot := catalog lootCatalogue.
	pools := loot poolsForItem: 'weapon.launch.chatterbox'.
	self
		assert: (pools collect: #id)
		equals: #('chatterbox' 'exoticCaches' 'targetedLoot').
	entry := ((loot poolAt: 'exoticCaches')
			entriesForItem: 'weapon.launch.chatterbox') first.
	self assert: entry requirement equals: #blueprintAcquired.
	self assert: entry evidence equals: 'Weapons Named + Exotics!I130'.
	self assert: entry weight isNil.
	self
		should: [ (loot poolAt: 'exoticCaches') selectUsing: 0.5 satisfying: [ :each | true ] ]
		raise: Error
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testWorkbookOverchargeRulesResolveOnlyForDocumentedVariantsAndTier [
	| catalog variants scanner serum |
	catalog := CIGameItemTypes buildCatalog.
	variants := catalog gadgetFamilies flatCollect: #variants.
	self
		assert: (variants
				count: [ :variant | (variant overchargeRuleAtTier: #overcharge) notNil ])
		equals: 9.
	variants
		do: [ :variant | self assert: (variant overchargeRuleAtTier: 6) isNil ].
	scanner := ((catalog gadgetFamilyNamed: 'Pulse') variantNamed: 'Scanner')
			overchargeRuleAtTier: #overcharge.
	self assert: scanner evidence equals: 'Skill List!L65'.
	self
		assert: (scanner damageAmplificationForPulsedTarget: true recipientIsAgentOrAlly: true)
		equals: 0.15.
	self
		assert: (scanner damageAmplificationForPulsedTarget: false recipientIsAgentOrAlly: true)
		equals: 0.
	self
		assert: (scanner damageAmplificationForPulsedTarget: true recipientIsAgentOrAlly: false)
		equals: 0.
	(catalog gadgetFamilyNamed: 'Shield') variants
		do: [ :variant | self assert: (variant overchargeRuleAtTier: #overcharge) shieldIsInvulnerable ].
	serum := ((catalog gadgetFamilyNamed: 'Trap') variantNamed: 'Healing')
			overchargeRuleAtTier: #overcharge.
	self assert: serum statusImmunitySecondsOnTrapContact equals: 10.
	self assert: serum evidence equals: 'Skill List!L49'
]

{ #category : 'tests' }
CIThatGameLaunchInventoryTest >> testWorkbookTalentReferencesPreserveScopesAndExecutableLinks [
	| catalog reference repeated |
	catalog := CIGameItemTypes buildCatalog.
	self
		assert: (catalog talentReferences
				count: [ :each | each id beginsWith: 'Weapon Talents!' ])
		equals: 67.
	self
		assert: (catalog talentReferences count: [ :each | each id beginsWith: 'Gear Talents!' ])
		equals: 46.
	reference := (catalog talentReferencesNamed: 'Perfect Optimist') first.
	self assert: reference scope equals: #weapon.
	self assert: reference talentIdentifier equals: 'optimist'.
	self assert: reference perfectTalentIdentifier equals: 'perfectOptimist'.
	self
		assert: ((catalog talentAt: reference perfectTalentIdentifier) parameters
				at: #damagePerStep)
		equals: 0.045.
	self
		assert: (reference evidenceForField: #description)
		equals: 'Weapon Talents!D5'.
	repeated := catalog talentReferencesNamed: 'Back and Forth'.
	self assert: repeated size equals: 6.
	self
		assert: (repeated collect: #scope) asSet
		equals: #(rifle assaultRifle marksmanRifle smg lmg shotgun) asSet.
	reference := catalog talentReferenceAt: 'Gear Talents!D14'.
	self assert: (reference fieldAt: #pvpModifier) notNil.
	self assert: (reference fieldAt: #dzPvpDescription) notNil.
	self
		assert: (reference evidenceForField: #dzPvpDescription)
		equals: 'Gear Talents!K14'.
	reference := catalog talentReferenceAt: 'Gear Talents!D24'.
	self
		assert: ((reference fieldAt: #eligibilityNotes) includesSubstring: 'backpack').
	reference := (catalog talentReferencesNamed: 'Perpetuation') first.
	self assert: reference talentIdentifier isNil.
	self assert: (catalog talentAt: 'perpetuation' ifAbsent: [ nil ]) isNil
]
