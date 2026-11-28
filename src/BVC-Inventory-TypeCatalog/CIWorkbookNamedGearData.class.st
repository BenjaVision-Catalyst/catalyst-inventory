Class {
	#name : 'CIWorkbookNamedGearData',
	#superclass : 'Object',
	#category : 'BVC-Inventory-TypeCatalog',
	#package : 'BVC-Inventory-TypeCatalog'
}

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
