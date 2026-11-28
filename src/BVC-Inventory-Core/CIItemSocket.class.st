Class {
	#name : 'CIItemSocket',
	#superclass : 'Object',
	#instVars : [
		'id',
		'interface',
		'fixedModIdentifier'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIItemSocket class >> id: identifier interface: mount [
	^ self new initializeId: identifier interface: mount
]

{ #category : 'instance creation' }
CIItemSocket class >> id: identifier interface: mount fixedMod: modId [
	^ (self id: identifier interface: mount) initializeFixedMod: modId
]

{ #category : 'accessing' }
CIItemSocket >> fixedModIdentifier [
	^ fixedModIdentifier ifNotNil: #copy
]

{ #category : 'accessing' }
CIItemSocket >> id [
	^ id copy
]

{ #category : 'initialization' }
CIItemSocket >> initializeFixedMod: modId [
	fixedModIdentifier := modId copy.
	^ self
]

{ #category : 'initialization' }
CIItemSocket >> initializeId: identifier interface: mount [
	id := identifier copy.
	interface := mount.
	^ self
]

{ #category : 'accessing' }
CIItemSocket >> interface [
	^ interface
]
