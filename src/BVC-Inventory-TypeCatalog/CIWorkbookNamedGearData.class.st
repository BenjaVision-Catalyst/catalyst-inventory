Class {
	#name : 'CIWorkbookNamedGearData',
	#superclass : 'Object',
	#category : 'BVC-Inventory-TypeCatalog',
	#package : 'BVC-Inventory-TypeCatalog'
}

{ #category : 'registration' }
CIWorkbookNamedGearData class >> basicMinorSlotsIn: catalog [
	^ #('minor1' 'minor2')
		collect: [ :id | 
			CIGearAttributeSlot
				id: id
				role: #minor
				choices: (catalog attributeCatalogue definitionsIn: #gearMinor)
				fixed: nil
				minimum: nil
				maximum: nil ]
]

{ #category : 'registration' }
CIWorkbookNamedGearData class >> coreSlotFor: reference in: catalog [
	| attributeData text definition |
	text := reference fieldAt: #core.
	attributeData := #(#('Weapon damage / 1.5% - 15%' 'gear.core.weaponDamage' nil 0.015 0.15) #('Armour / 16,594 - 170.000' 'gear.core.armor' nil 16594 170000) #('>+1< / Skill tier' 'gear.core.skillTier' 1 nil nil))
			detect: [ :spec | spec first = text ]
			ifNone: [ self error: 'Unresolved named gear core: ' , reference name ].
	definition := catalog attributeCatalogue definitionAt: attributeData second.
	^ CIGearAttributeSlot
		id: 'core'
		role: #core
		choices: {definition}
		fixed: attributeData third
		minimum: attributeData fourth
		maximum: attributeData fifth
]

{ #category : 'registration' }
CIWorkbookNamedGearData class >> register: identifier name: name in: catalog slots: statSlots sockets: sockets information: info [
	catalog
		register: (CIWorkbookNamedGearType
				id: identifier
				name: name
				layout: (CIGearGenerationLayout
						slots: statSlots
						evidence: (info at: #layoutEvidence))
				sockets: sockets
				information: info).
	sockets
		do: [ :socket | 
			catalog modCatalogue
				registerSocket: (CIItemSocket id: socket interface: #gearMod)
				forItem: identifier ]
]

{ #category : 'registration' }
CIWorkbookNamedGearData class >> registerAdditionalIn: catalog [
	#(#('The Courier' 'perfectCreepingDeath') #('Force Multiplier' 'perfectCombinedArms') #('Bulldog' 'perfectComposure') #('Zero F’s' 'perfectUnbreakable') #('Ferocious Calm' 'perfectOverwatch') #('Equalizer' 'perfectObliterate'))
		do: [ :spec | 
			| reference |
			reference := catalog namedGearReferenceAt: spec first.
			self
				registerReference: reference
				minorSlots: (self basicMinorSlotsIn: catalog)
				sockets: #('gearMod1')
				talent: spec second
				in: catalog ].
	#(#('Eagles Grasp' 'gear.minor.weaponHandling' 0.15) #('Firm Handshake' 'gear.minor.statusEffects' 0.16))
		do: [ :spec | 
			| attribute reference |
			reference := catalog namedGearReferenceAt: spec first.
			attribute := catalog attributeCatalogue definitionAt: spec second.
			self
				registerReference: reference
				minorSlots: {CIGearAttributeSlot
							id: 'minor1'
							role: #minor
							choices: {attribute}
							fixed: spec third
							minimum: nil
							maximum: nil.
						CIGearAttributeSlot
							id: 'minor2'
							role: #minor
							choices: ((catalog attributeCatalogue definitionsIn: #gearMinor)
									reject: [ :each | each id = attribute id ])
							fixed: nil
							minimum: nil
							maximum: nil}
				sockets: #()
				talent: nil
				in: catalog ]
]

{ #category : 'registration' }
CIWorkbookNamedGearData class >> registerIn: catalog [
	| attributes minor headshot |
	attributes := catalog attributeCatalogue.
	minor := attributes definitionsIn: #gearMinor.
	headshot := attributes definitionAt: 'gear.minor.headshotDamage'.
	self
		register: 'gear.workbook.punchDrunk'
		name: 'Punch Drunk'
		in: catalog
		slots: {CIGearAttributeSlot
					id: 'core'
					role: #core
					choices: {attributes definitionAt: 'gear.core.weaponDamage'}
					fixed: nil
					minimum: 0.015
					maximum: 0.15.
				CIGearAttributeSlot
					id: 'minor1'
					role: #minor
					choices: {headshot}
					fixed: 0.20
					minimum: nil
					maximum: nil.
				CIGearAttributeSlot
					id: 'minor2'
					role: #minor
					choices: (minor reject: [ :attribute | attribute id = headshot id ])
					fixed: nil
					minimum: nil
					maximum: nil}
		sockets: #('gearMod1')
		information: {#brand -> 'Douglas & Harding'.
				#description -> 'Extra Headshot Damage'.
				#acquisition -> 'LZ'.
				#flavour
					-> 'If the first shot doesn''t drop ''em, the second one will. Or the third, third''s usually good.'.
				#evidence -> 'Gear Named + Exotics!C2:N2'.
				#layoutEvidence -> 'Gear Named + Exotics!H2:K2, Attribute Info!A66'}
				asDictionary.
	self
		register: 'gear.workbook.chillOut'
		name: 'Chill Out'
		in: catalog
		slots: {CIGearAttributeSlot
					id: 'core'
					role: #core
					choices: {attributes definitionAt: 'gear.core.armor'}
					fixed: nil
					minimum: 16594
					maximum: 170000.
				CIGearAttributeSlot
					id: 'minor1'
					role: #minor
					choices: minor
					fixed: nil
					minimum: nil
					maximum: nil}
		sockets: #('gearMod1' 'gearMod2')
		information: {#brand -> 'Gila Guard'.
				#description -> 'Has 2 Mod Slots and only 1 Minor Stat'.
				#acquisition -> 'Special Event Hoarder'.
				#flavour -> 'Revenge is a dish best served cold.'.
				#note -> 'Someone who remembers you'.
				#evidence -> 'Gear Named + Exotics!C4:N4'.
				#layoutEvidence -> 'Gear Named + Exotics!H4:K4, Attribute Info!E23'}
				asDictionary
]

{ #category : 'registration' }
CIWorkbookNamedGearData class >> registerReference: reference minorSlots: minorSlots sockets: sockets talent: talentId in: catalog [
	| identifier information layout |
	identifier := reference itemDefinitionIdentifier.
	information := Dictionary new.
	#(brand description acquisition flavour release)
		do: [ :key | (reference fieldAt: key) ifNotNil: [ :value | information at: key put: value ] ].
	layout := CIGearGenerationLayout
			slots: {self coreSlotFor: reference in: catalog} , minorSlots
			evidence: (reference evidenceForField: #core).
	catalog
		register: (CIWorkbookNamedGearType
				id: identifier
				name: reference name
				slot: reference slot
				layout: layout
				sockets: sockets
				information: information).
	sockets
		do: [ :socket | 
			catalog modCatalogue
				registerSocket: (CIItemSocket id: socket interface: #gearMod)
				forItem: identifier ].
	talentId ifNotNil: [ catalog talentPool: {talentId} for: identifier ]
]
