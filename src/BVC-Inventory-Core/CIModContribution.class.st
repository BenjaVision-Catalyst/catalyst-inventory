Class {
	#name : 'CIModContribution',
	#superclass : 'Object',
	#instVars : [
		'itemIdentifier',
		'socketIdentifier',
		'modIdentifier',
		'stat',
		'operation',
		'value',
		'evidence'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIModContribution class >> item: itemId socket: socketId definition: definition stat: statId operation: effectOperation value: magnitude [
	^ self new
		initializeItem: itemId
		socket: socketId
		definition: definition
		stat: statId
		operation: effectOperation
		value: magnitude
]

{ #category : 'accessing' }
CIModContribution >> evidence [
	^ evidence copy
]

{ #category : 'initialization' }
CIModContribution >> initializeItem: itemId socket: socketId definition: definition stat: statId operation: effectOperation value: magnitude [
	itemIdentifier := itemId copy.
	socketIdentifier := socketId copy.
	modIdentifier := definition id.
	evidence := definition evidence.
	stat := statId.
	operation := effectOperation.
	value := magnitude.
	^ self
]

{ #category : 'accessing' }
CIModContribution >> itemIdentifier [
	^ itemIdentifier copy
]

{ #category : 'accessing' }
CIModContribution >> modIdentifier [
	^ modIdentifier copy
]

{ #category : 'accessing' }
CIModContribution >> operation [
	^ operation
]

{ #category : 'accessing' }
CIModContribution >> socketIdentifier [
	^ socketIdentifier copy
]

{ #category : 'accessing' }
CIModContribution >> stat [
	^ stat
]

{ #category : 'accessing' }
CIModContribution >> value [
	^ operation = #referenceText ifTrue: [ value copy ] ifFalse: [ value ]
]
