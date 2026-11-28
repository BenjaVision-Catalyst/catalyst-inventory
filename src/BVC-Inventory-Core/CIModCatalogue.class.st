Class {
	#name : 'CIModCatalogue',
	#superclass : 'Object',
	#instVars : [
		'definitions',
		'socketsByItem'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'compatibility' }
CIModCatalogue >> compatibleModsFor: itemDefinitionId socket: socketId [
	| sockets socket |
	sockets := socketsByItem at: itemDefinitionId ifAbsent: [ ^ #() ].
	socket := sockets at: socketId ifAbsent: [ ^ #() ].
	^ ((definitions values
		select: [ :mod | mod fitsSocket: socket on: itemDefinitionId ])
		sorted: [ :a :b | a id < b id ]) asArray
]

{ #category : 'accessing' }
CIModCatalogue >> definitionAt: identifier [
	^ definitions at: identifier
]

{ #category : 'initialization' }
CIModCatalogue >> initialize [
	super initialize.
	definitions := Dictionary new.
	socketsByItem := Dictionary new
]

{ #category : 'registration' }
CIModCatalogue >> register: modDefinition [
	(definitions includesKey: modDefinition id)
		ifTrue: [ self error: 'Duplicate mod definition' ].
	definitions at: modDefinition id put: modDefinition.
	^ modDefinition
]

{ #category : 'registration' }
CIModCatalogue >> registerSocket: aSocket forItem: itemDefinitionId [
	| sockets |
	sockets := socketsByItem at: itemDefinitionId ifAbsentPut: [ Dictionary new ].
	(sockets includesKey: aSocket id)
		ifTrue: [ self error: 'Duplicate item socket' ].
	sockets at: aSocket id put: aSocket
]

{ #category : 'accessing' }
CIModCatalogue >> socketsFor: itemDefinitionId [
	| sockets |
	sockets := socketsByItem at: itemDefinitionId ifAbsent: [ ^ #() ].
	^ (sockets values sorted: [ :a :b | a id < b id ]) asArray
]
