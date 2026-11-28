Class {
	#name : 'CILootSource',
	#superclass : 'Object',
	#instVars : [
		'id',
		'name',
		'kind'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CILootSource class >> id: identifier name: label kind: sourceKind [
	^ self new
		initializeId: identifier
		name: label
		kind: sourceKind
]

{ #category : 'accessing' }
CILootSource >> id [
	^ id copy
]

{ #category : 'initialization' }
CILootSource >> initializeId: identifier name: label kind: sourceKind [
	id := identifier copy.
	name := label copy.
	kind := sourceKind.
	^ self
]

{ #category : 'accessing' }
CILootSource >> kind [
	^ kind
]

{ #category : 'accessing' }
CILootSource >> name [
	^ name copy
]
