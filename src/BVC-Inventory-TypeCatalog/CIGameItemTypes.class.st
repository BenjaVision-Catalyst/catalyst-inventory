Class {
	#name : 'CIGameItemTypes',
	#superclass : 'Object',
	#category : 'BVC-Inventory-TypeCatalog',
	#package : 'BVC-Inventory-TypeCatalog'
}

{ #category : 'catalog' }
CIGameItemTypes class >> buildCatalog [
	| catalog |
	catalog := CIItemTypeCatalog new.
	catalog register: self scoutDrone.
	catalog register: self scannerPulse.
	catalog register: self responseAidVest.
	catalog register: self traversalPack.
	catalog register: self fieldKneePads.
	catalog register: self fieldBlade.
	catalog register: self relaySidearm.
	catalog register: self pathfinderCarbine.
	^ catalog
]

{ #category : 'catalog' }
CIGameItemTypes class >> fieldBlade [
	^ CIWeaponType
		id: 'weapon.melee.fieldBlade'
		name: 'Field Blade'
		slot: 'MeleeWeapon'
		core: #(#('Damage per hit' 48) #('Reach' '2 m'))
		handling: #()
		sockets: #()
]

{ #category : 'catalog' }
CIGameItemTypes class >> fieldKneePads [
	^ CIGearType
		id: 'gear.field.kneePads'
		name: 'Field Knee Pads'
		slot: 'KneePads'
		attributes: #(#('armor' 'Armor' 'defensive' 'signedNumber' 30 60) #('hazard' 'Hazard resistance' 'defensive' 'signedPercent' 0.02 0.08))
		sockets: #()
]

{ #category : 'catalog' }
CIGameItemTypes class >> pathfinderCarbine [
	^ (CIWeaponType
		id: 'weapon.ranged.pathfinder'
		name: 'Pathfinder Carbine'
		slot: 'RangedWeapon'
		core: #(#('Damage per hit' 25) #('Fire rate' '600 RPM') #('Magazine' '30 rounds') #('Optimal range' 32) #('Reload time' '2.1 s'))
		handling: #(#('Accuracy' 82) #('Stability' 68))
		sockets: #('optic' 'magazine' 'muzzle'))
		damageFalloff: #(#(72 65) #(100 65));
		yourself
]

{ #category : 'catalog' }
CIGameItemTypes class >> relaySidearm [
	^ (CIWeaponType
		id: 'weapon.sidearm.relay'
		name: 'Relay Sidearm'
		slot: 'LeftHandWeapon'
		core: #(#('Damage per hit' 32) #('Fire rate' '360 RPM') #('Magazine' '12 rounds') #('Optimal range' 18) #('Reload time' '1.5 s'))
		handling: #(#('Accuracy' 72) #('Stability' 76))
		sockets: #('magazine' 'muzzle'))
		damageFalloff: #(#(42 55) #(60 55));
		yourself
]

{ #category : 'catalog' }
CIGameItemTypes class >> responseAidVest [
	^ CIGearType
		id: 'gear.response.aidVest'
		name: 'Response Aid Vest'
		slot: 'Chest'
		attributes: #(#('utilityTier' 'Utility Tier' 'utility' 'signedNumber' 1 1) #('repair' 'Repair strength' 'utility' 'signedPercent' 0.04 0.12) #('haste' 'Gadget haste' 'utility' 'signedPercent' 0.03 0.10))
		sockets: #('utility')
]

{ #category : 'catalog' }
CIGameItemTypes class >> scannerPulse [
	^ CIScannerPulseType
		id: 'gadget.pulse.scanner'
		name: 'Scanner Pulse'
		icon: 'scannerPulse'
]

{ #category : 'catalog' }
CIGameItemTypes class >> scoutDrone [
	^ CIScoutDroneType
		id: 'gadget.drone.scout'
		name: 'Scout Drone'
		icon: 'scoutDrone'
]

{ #category : 'catalog' }
CIGameItemTypes class >> traversalPack [
	^ CIGearType
		id: 'gear.traversal.pack'
		name: 'Traversal Pack'
		slot: 'Backpack'
		attributes: #(#('armor' 'Armor' 'defensive' 'signedNumber' 60 100) #('hazard' 'Hazard resistance' 'defensive' 'signedPercent' 0.04 0.12) #('reload' 'Reload speed' 'offensive' 'signedPercent' 0.03 0.10))
		sockets: #('defensive' 'utility')
]
