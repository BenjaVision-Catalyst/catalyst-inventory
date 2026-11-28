Class {
	#name : 'CISpecializationDefinition',
	#superclass : 'Object',
	#instVars : [
		'name',
		'perks'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CISpecializationDefinition class >> name: label perks: entries [
	^ self new initializeName: label perks: entries
]

{ #category : 'initialization' }
CISpecializationDefinition >> initializeName: label perks: entries [
	name := label copy.
	perks := Dictionary new.
	entries
		do: [ :perk | 
			(perks includesKey: perk id)
				ifTrue: [ self error: 'Duplicate specialization perk' ].
			perks at: perk id put: perk ].
	^ self
]

{ #category : 'accessing' }
CISpecializationDefinition >> name [
	^ name copy
]

{ #category : 'accessing' }
CISpecializationDefinition >> perkAt: identifier [
	^ perks at: identifier ifAbsent: [ nil ]
]

{ #category : 'accessing' }
CISpecializationDefinition >> perks [
	^ (perks values sorted: [ :a :b | a id < b id ]) asArray
]
