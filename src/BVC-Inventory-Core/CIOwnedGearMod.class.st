Class {
	#name : 'CIOwnedGearMod',
	#superclass : 'CIInventoryModItemSummary',
	#instVars : [
		'rolledValue'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIOwnedGearMod class >> item: identifier fromMod: definition tier: tier value: value [
	definition validateRoll: value tier: tier.
	^ (self
		item: identifier
		definition: definition id
		name: definition name) initializeTier: tier value: value
]

{ #category : 'initialization' }
CIOwnedGearMod >> initializeTier: tier value: value [
	tierId := tier.
	rolledValue := value.
	^ self
]

{ #category : 'accessing' }
CIOwnedGearMod >> rolledValue [
	^ rolledValue
]
