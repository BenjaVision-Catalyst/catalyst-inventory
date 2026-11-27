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
	^ catalog
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
