Class {
	#name : 'CIInventoryService',
	#superclass : 'CRWorkerService',
	#instVars : [
		'readStore',
		'savedSetsByOwner',
		'savedSetsLock',
		'itemTypeCatalog'
	],
	#category : 'BVC-Inventory-Runtime',
	#package : 'BVC-Inventory-Runtime'
}

{ #category : 'configuration' }
CIInventoryService class >> configurationClass [
	^ CIInventoryConfiguration
]

{ #category : 'private' }
CIInventoryService >> applySavedSet: savedSet forOwner: identity outfit: isOutfit sets: ownerSets [
	| rows reply |
	rows := readStore
			rowsAfterEquipping: (savedSet at: 'slots')
			forOwner: identity
			outfit: isOutfit.
	reply := CIInventoryProfileGraph
			encodeReply: (CIInventoryProfileGraph
					forVerifiedUser: identity
					rows: rows
					savedSets: ownerSets
					catalog: itemTypeCatalog
					modStorageAllowance: (readStore modStorageAllowanceForOwner: identity)
					specialization: (self resolvedSpecializationFor: identity)).
	reply ifNotNil: [ readStore replaceRows: rows forOwner: identity ].
	^ reply
]

{ #category : 'reading' }
CIInventoryService >> classifiedEncounterForVerifiedUser: identity mode: mode [
	^ CIClassifiedEncounter
		forActivations: (self familyEvaluationForVerifiedUser: identity mode: mode)
]

{ #category : 'writing' }
CIInventoryService >> clearSpecializationForVerifiedUser: identity [
	^ savedSetsLock critical: [ readStore specialization: nil forOwner: identity ]
]

{ #category : 'writing' }
CIInventoryService >> createSavedSetFor: identity outfit: isOutfit [
	^ savedSetsLock
		critical: [ self newSavedSetReplyFor: identity outfit: isOutfit ]
]

{ #category : 'writing' }
CIInventoryService >> deleteSavedSet: setIdentifier forVerifiedUser: identity [
	^ self
		withSavedSet: setIdentifier
		forVerifiedUser: identity
		do: [ :entry :section :sets | 
			self
				replaceSavedSets: ((sets at: section) reject: [ :each | each == entry ])
				in: section
				of: sets
				forOwner: identity ]
]

{ #category : 'writing' }
CIInventoryService >> equipSavedSet: setIdentifier forVerifiedUser: identity [
	^ self
		withSavedSet: setIdentifier
		forVerifiedUser: identity
		do: [ :entry :section :sets | 
			self
				applySavedSet: entry
				forOwner: identity
				outfit: section = 'apparel'
				sets: sets ]
]

{ #category : 'reading' }
CIInventoryService >> exoticWeaponEncounterFor: weaponId forVerifiedUser: identity [
	^ savedSetsLock
		critical: [ | rows weapon talent type mods capacity |
			rows := readStore allRowsForOwner: identity.
			weapon := rows
					detect: [ :row | row itemIdentifier = weaponId ]
					ifNone: [ self error: 'Weapon is not owned' ].
			((weapon isKindOf: CIInventoryWeaponToolSummary)
				and: [ weapon equippedSlotIdentifier notNil ])
				ifFalse: [ self error: 'An exotic weapon must be equipped' ].
			talent := weapon talentIdentifier
					ifNil: [ self error: 'The equipped weapon has no talent' ]
					ifNotNil: [ :id | itemTypeCatalog talentAt: id ].
			type := itemTypeCatalog typeAt: weapon definitionIdentifier.
			mods := CIEquipmentModEvaluator new
					evaluateEquipment: {weapon}
					owned: rows
					catalogue: itemTypeCatalog modCatalogue.
			capacity := mods magazineCapacityFor: weapon base: type baseMagazineCapacity.
			CIExoticWeaponEncounter
				weapon: weapon itemIdentifier
				talent: talent
				magazineCapacity: capacity ]
]

{ #category : 'reading' }
CIInventoryService >> familyEvaluationForVerifiedUser: identity mode: mode [
	^ savedSetsLock
		critical: [ CILoadoutFamilyEvaluator new
				evaluateRows: (readStore allRowsForOwner: identity)
				catalogue: itemTypeCatalog
				mode: mode ]
]

{ #category : 'reading' }
CIInventoryService >> gadgetEncounterFor: gadgetId weapon: weaponId forVerifiedUser: identity [
	^ savedSetsLock
		critical: [ | rows gadget weapon type activeTalent tier |
			rows := readStore allRowsForOwner: identity.
			gadget := rows
					detect: [ :row | row itemIdentifier = gadgetId ]
					ifNone: [ self error: 'Gadget is not owned' ].
			weapon := rows
					detect: [ :row | row itemIdentifier = weaponId ]
					ifNone: [ self error: 'Weapon is not owned' ].
			type := itemTypeCatalog typeAt: gadget definitionIdentifier.
			((type respondsTo: #workbookVariantDefinition)
				and: [ gadget equippedSlotIdentifier notNil ])
				ifFalse: [ self error: 'A workbook gadget must be equipped' ].
			((weapon isKindOf: CIInventoryWeaponToolSummary)
				and: [ weapon equippedSlotIdentifier notNil ])
				ifFalse: [ self error: 'An eligible weapon must be equipped' ].
			activeTalent := weapon talentIdentifier
					ifNil: [ self error: 'The equipped weapon has no talent' ]
					ifNotNil: [ :id | itemTypeCatalog talentAt: id ].
			tier := CIInventoryProfileGraph
					workbookGadgetTierForRows: rows
					specialization: (self resolvedSpecializationFor: identity).
			CIGadgetEncounter
				variant: type workbookVariantDefinition
				baseTier: tier
				weapon: weapon itemIdentifier
				talent: activeTalent ]
]

{ #category : 'reading' }
CIInventoryService >> gadgetStatsForFamily: familyName variant: variantName tier: tier [
	| variant |
	variant := (itemTypeCatalog gadgetFamilyNamed: familyName)
			variantNamed: variantName.
	^ variant knownStatsAtTier: tier
]

{ #category : 'reading' }
CIInventoryService >> gearTalentEncounterFor: itemId forVerifiedUser: identity mode: mode [
	^ savedSetsLock
		critical: [ | item talent slot |
			item := (readStore allRowsForOwner: identity)
					detect: [ :row | row itemIdentifier = itemId ]
					ifNone: [ self error: 'Gear item is not owned' ].
			(item isKindOf: CIInventoryGearSummary)
				ifFalse: [ self error: 'Expected a gear item' ].
			slot := item equippedSlotIdentifier.
			(#('Chest' 'Backpack') includes: slot)
				ifFalse: [ self error: 'A vest or backpack must be equipped' ].
			talent := item talentIdentifier
					ifNil: [ self error: 'The gear item has no talent' ]
					ifNotNil: [ :id | itemTypeCatalog talentAt: id ].
			talent eligibility = slot asSymbol
				ifFalse: [ self error: 'Talent is ineligible for this gear slot' ].
			CIGearTalentEncounter talent: talent mode: mode ]
]

{ #category : 'writing' }
CIInventoryService >> grantGearMod: itemId definition: modId tier: tier value: value forVerifiedUser: identity [
	^ savedSetsLock
		critical: [ readStore
				grantGearMod: itemId
				definition: modId
				tier: tier
				value: value
				from: itemTypeCatalog
				forOwner: identity ]
]

{ #category : 'writing' }
CIInventoryService >> grantItem: itemIdentifier type: typeIdentifier values: values forVerifiedUser: identity [
	^ savedSetsLock
		critical: [ readStore
				grantItem: itemIdentifier
				type: typeIdentifier
				values: values
				from: itemTypeCatalog
				forOwner: identity ]
]

{ #category : 'writing' }
CIInventoryService >> grantLoot: itemIdentifier pool: poolIdentifier valuesFrom: valuesProvider satisfying: eligibility forVerifiedUser: identity [
	^ savedSetsLock
		critical: [ readStore
				grantLoot: itemIdentifier
				pool: poolIdentifier
				valuesFrom: valuesProvider
				satisfying: eligibility
				from: itemTypeCatalog
				forOwner: identity
				using: [ Random new next ] ]
]

{ #category : 'writing' }
CIInventoryService >> installMod: modItemId on: equipmentId socket: socketId forVerifiedUser: identity [
	^ savedSetsLock
		critical: [ readStore
				installMod: modItemId
				on: equipmentId
				socket: socketId
				from: itemTypeCatalog
				forOwner: identity ]
]

{ #category : 'reading' }
CIInventoryService >> modEvaluationFor: itemIdentifiers forVerifiedUser: identity [
	^ savedSetsLock
		critical: [ | rows items |
			rows := readStore allRowsForOwner: identity.
			items := itemIdentifiers asSet
					collect: [ :id | 
						rows
							detect: [ :row | row itemIdentifier = id and: [ row isKindOf: CIInventoryEquipmentSummary ] ]
							ifNone: [ self error: 'Equipment is not owned' ] ].
			CIEquipmentModEvaluator new
				evaluateEquipment: items
				owned: rows
				catalogue: itemTypeCatalog modCatalogue ]
]

{ #category : 'writing' }
CIInventoryService >> modStorageAllowance: allowance forVerifiedUser: identity [
	^ savedSetsLock
		critical: [ readStore modStorageAllowance: allowance forOwner: identity ]
]

{ #category : 'private' }
CIInventoryService >> newSavedSetReplyFor: identity outfit: isOutfit [
	| section ownerSets entries name prefix number entry reply |
	section := isOutfit ifTrue: [ 'apparel' ] ifFalse: [ 'gear' ].
	ownerSets := (savedSetsByOwner at: identity ifAbsent: [ Dictionary new ]) copy.
	entries := ownerSets at: section ifAbsent: [ #() ].
	entries size >= 32 ifTrue: [ ^ nil ].
	prefix := isOutfit ifTrue: [ 'Outfit ' ] ifFalse: [ 'Gear Set ' ].
	number := 1.
	[ name := prefix , number asString.
	entries anySatisfy: [ :existing | (existing at: 'displayName') sameAs: name ] ]
		whileTrue: [ number := number + 1 ].
	entry := Dictionary new
			at: 'itemIdentifier' put: UUID new asString;
			at: 'displayName' put: name;
			at: 'slots'
				put: (readStore equippedSlotsForOwner: identity outfit: isOutfit);
			yourself.
	ownerSets at: section put: (entries copyWith: entry).
	reply := CIInventoryProfileGraph
			encodeReply: (CIInventoryProfileGraph
					forVerifiedUser: identity
					rows: (readStore allRowsForOwner: identity)
					savedSets: ownerSets
					catalog: itemTypeCatalog
					modStorageAllowance: (readStore modStorageAllowanceForOwner: identity)
					specialization: (self resolvedSpecializationFor: identity)).
	reply ifNotNil: [ savedSetsByOwner at: identity copy put: ownerSets ].
	^ reply
]

{ #category : 'writing' }
CIInventoryService >> overwriteSavedSet: setIdentifier forVerifiedUser: identity [
	^ self
		withSavedSet: setIdentifier
		forVerifiedUser: identity
		do: [ :entry :section :sets | 
			| entries |
			entries := (sets at: section) copy.
			entries
				at: (entries indexOf: entry)
				put: (entry copy
						at: 'slots'
							put: (readStore equippedSlotsForOwner: identity outfit: section = 'apparel');
						yourself).
			self
				replaceSavedSets: entries
				in: section
				of: sets
				forOwner: identity ]
]

{ #category : 'accessing' }
CIInventoryService >> profileGraphForVerifiedUser: identity [
	^ savedSetsLock
		critical: [ CIInventoryProfileGraph
				forVerifiedUser: identity
				rows: (readStore allRowsForOwner: identity)
				savedSets: (savedSetsByOwner at: identity ifAbsent: [ Dictionary new ])
				catalog: itemTypeCatalog
				modStorageAllowance: (readStore modStorageAllowanceForOwner: identity)
				specialization: (self resolvedSpecializationFor: identity) ]
]

{ #category : 'writing' }
CIInventoryService >> provisionLaunchInventoryForVerifiedUser: identity [
	^ savedSetsLock
		critical: [ | staging oldRows knownDefinitions newRows |
			oldRows := readStore allRowsForOwner: identity.
			knownDefinitions := (oldRows collect: #definitionIdentifier) asSet.
			staging := CIInventoryReadStore new.
			staging replaceRows: oldRows forOwner: identity.
			CIThatGameLaunchCatalog spawnSpecs
				do: [ :spec | 
					(knownDefinitions includes: spec key)
						ifFalse: [ staging
								grantItem: UUID new asString
								type: spec key
								values: spec value
								from: itemTypeCatalog
								forOwner: identity ] ].
			newRows := staging allRowsForOwner: identity.
			newRows size > oldRows size
				ifTrue: [ readStore replaceRows: newRows forOwner: identity ].
			newRows size - oldRows size ]
]

{ #category : 'writing' }
CIInventoryService >> provisionStarterGadgetsForVerifiedUser: identity [
	^ savedSetsLock
		critical: [ readStore provisionStarterGadgetsFrom: itemTypeCatalog forOwner: identity ]
]

{ #category : 'reading' }
CIInventoryService >> pveGearTalentEncounterFor: itemId forVerifiedUser: identity [
	^ self
		gearTalentEncounterFor: itemId
		forVerifiedUser: identity
		mode: #pve
]

{ #category : 'writing' }
CIInventoryService >> removeModFrom: equipmentId socket: socketId forVerifiedUser: identity [
	^ savedSetsLock
		critical: [ readStore
				removeModFrom: equipmentId
				socket: socketId
				forOwner: identity ]
]

{ #category : 'writing' }
CIInventoryService >> renameSavedSet: setIdentifier to: proposedName forVerifiedUser: identity [
	| name units |
	name := proposedName trimBoth.
	units := name size + (name count: [ :character | character codePoint > 65535 ]).
	((units between: 1 and: 48)
		and: [ name noneSatisfy: [ :character | #(0 10 13) includes: character codePoint ] ])
		ifFalse: [ ^ nil ].
	^ self
		withSavedSet: setIdentifier
		forVerifiedUser: identity
		do: [ :entry :section :sets | 
			| entries |
			entries := sets at: section.
			(entries
				anySatisfy: [ :each | each ~~ entry and: [ (each at: 'displayName') sameAs: name ] ])
				ifTrue: [ ^ nil ].
			entries := entries copy.
			entries
				at: (entries indexOf: entry)
				put: (entry copy
						at: 'displayName' put: name;
						yourself).
			self
				replaceSavedSets: entries
				in: section
				of: sets
				forOwner: identity ]
]

{ #category : 'reading' }
CIInventoryService >> replaceReadRows: rows forOwner: identity [
	savedSetsLock critical: [ readStore replaceRows: rows forOwner: identity ]
]

{ #category : 'private' }
CIInventoryService >> replaceSavedSets: entries in: section of: sets forOwner: identity [
	| updated reply |
	updated := sets copy
			at: section put: entries;
			yourself.
	reply := CIInventoryProfileGraph
			encodeReply: (CIInventoryProfileGraph
					forVerifiedUser: identity
					rows: (readStore allRowsForOwner: identity)
					savedSets: updated
					catalog: itemTypeCatalog
					modStorageAllowance: (readStore modStorageAllowanceForOwner: identity)
					specialization: (self resolvedSpecializationFor: identity)).
	reply ifNotNil: [ savedSetsByOwner at: identity copy put: updated ].
	^ reply
]

{ #category : 'private' }
CIInventoryService >> resolvedSpecializationFor: identity [
	^ (readStore specializationForOwner: identity)
		ifNotNil: [ :selection | selection resolveIn: itemTypeCatalog ]
]

{ #category : 'reading' }
CIInventoryService >> rowsForVerifiedUser: anIdentifier offset: anOffset limit: aLimit [
	^ savedSetsLock
		critical: [ readStore
				rowsForOwner: anIdentifier
				offset: anOffset
				limit: aLimit ]
]

{ #category : 'writing' }
CIInventoryService >> selectSpecialization: label perks: identifiers forVerifiedUser: identity [
	^ savedSetsLock
		critical: [ | selection loadout |
			selection := CISpecializationSelection
					specialization: label
					perks: identifiers.
			loadout := selection resolveIn: itemTypeCatalog.
			readStore specialization: selection forOwner: identity.
			loadout ]
]

{ #category : 'reading' }
CIInventoryService >> specializationLoadoutForVerifiedUser: identity [
	^ savedSetsLock critical: [ self resolvedSpecializationFor: identity ]
]

{ #category : 'lifecycle' }
CIInventoryService >> start [
	| snapshotPath |
	snapshotPath := self configuration
			ifNotNil: [ :settings | settings inventorySnapshotPath ].
	readStore := snapshotPath
			ifNil: [ CIInventoryReadStore new ]
			ifNotNil: [ CIInventorySnapshotStore at: snapshotPath ].
	itemTypeCatalog := CIGameItemTypes buildCatalog.
	readStore restoreFactoryAttachmentsFrom: itemTypeCatalog.
	savedSetsByOwner := Dictionary new.
	savedSetsLock := Semaphore forMutualExclusion.
	super start
]

{ #category : 'lifecycle' }
CIInventoryService >> stop [
	savedSetsByOwner := nil.
	savedSetsLock := nil.
	readStore := nil.
	itemTypeCatalog := nil.
	super stop
]

{ #category : 'writing' }
CIInventoryService >> unlockWeaponMod: modId forVerifiedUser: identity [
	^ savedSetsLock
		critical: [ readStore
				unlockWeaponMod: modId
				from: itemTypeCatalog
				forOwner: identity ]
]

{ #category : 'reading' }
CIInventoryService >> updateClassifiedEncounter: encounter forVerifiedUser: identity mode: mode [
	^ encounter
		updateFromActivations: (self familyEvaluationForVerifiedUser: identity mode: mode)
]

{ #category : 'reading' }
CIInventoryService >> weaponTalentEncounterFor: weaponId forVerifiedUser: identity [
	^ savedSetsLock
		critical: [ | weapon talent |
			weapon := (readStore allRowsForOwner: identity)
					detect: [ :row | row itemIdentifier = weaponId ]
					ifNone: [ self error: 'Weapon is not owned' ].
			((weapon isKindOf: CIInventoryWeaponToolSummary)
				and: [ weapon equippedSlotIdentifier notNil ])
				ifFalse: [ self error: 'A weapon must be equipped' ].
			talent := weapon talentIdentifier
					ifNil: [ self error: 'The equipped weapon has no talent' ]
					ifNotNil: [ :id | itemTypeCatalog talentAt: id ].
			CIWeaponTalentEncounter weapon: weapon itemIdentifier talent: talent ]
]

{ #category : 'private' }
CIInventoryService >> withSavedSet: setIdentifier forVerifiedUser: identity do: action [
	^ savedSetsLock
		critical: [ | sets |
			sets := savedSetsByOwner at: identity ifAbsent: [ ^ nil ].
			#('gear' 'apparel')
				do: [ :section | 
					| entry |
					entry := (sets at: section ifAbsent: [ #() ])
							detect: [ :each | (each at: 'itemIdentifier') = setIdentifier ]
							ifNone: [ nil ].
					entry
						ifNotNil: [ ^ action
								value: entry
								value: section
								value: sets ] ].
			nil ]
]

{ #category : 'reading' }
CIInventoryService >> workbookGadgetStatsFor: itemIdentifier forVerifiedUser: identity [
	^ savedSetsLock
		critical: [ | rows gadget type tier |
			rows := readStore allRowsForOwner: identity.
			gadget := rows
					detect: [ :row | row itemIdentifier = itemIdentifier ]
					ifNone: [ self error: 'Gadget is not owned' ].
			type := itemTypeCatalog typeAt: gadget definitionIdentifier.
			(type respondsTo: #workbookVariantDefinition)
				ifFalse: [ self error: 'This item is not a workbook gadget' ].
			tier := CIInventoryProfileGraph
					workbookGadgetTierForRows: rows
					specialization: (self resolvedSpecializationFor: identity).
			type statsAtUtilityTier: tier ]
]
