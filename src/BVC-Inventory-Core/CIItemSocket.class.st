Class {
	#name : 'CIItemSocket',
	#superclass : 'Object',
	#instVars : [
		'id',
		'interface'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIItemSocket class >> id: identifier interface: mount [
	^ self new initializeId: identifier interface: mount
]

{ #category : 'accessing' }
CIItemSocket >> id [
	^ id copy
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
