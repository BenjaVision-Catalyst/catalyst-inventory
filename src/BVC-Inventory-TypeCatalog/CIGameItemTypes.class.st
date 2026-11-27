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
	^ catalog
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
