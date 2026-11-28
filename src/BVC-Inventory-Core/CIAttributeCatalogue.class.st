Class {
	#name : 'CIAttributeCatalogue',
	#superclass : 'Object',
	#instVars : [
		'definitions',
		'rules'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'accessing' }
CIAttributeCatalogue >> definitionAt: identifier [
	^ definitions at: identifier
]

{ #category : 'querying' }
CIAttributeCatalogue >> definitionsIn: aContext [
	^ ((definitions values select: [ :definition | definition context = aContext ])
		sorted: [ :a :b | a id < b id ]) asArray
]

{ #category : 'initialization' }
CIAttributeCatalogue >> initialize [
	super initialize.
	definitions := Dictionary new.
	rules := Dictionary new
]

{ #category : 'registration' }
CIAttributeCatalogue >> register: aDefinition [
	(definitions includesKey: aDefinition id)
		ifTrue: [ self error: 'Duplicate attribute definition' ].
	definitions at: aDefinition id put: aDefinition.
	^ aDefinition
]

{ #category : 'registration' }
CIAttributeCatalogue >> registerRule: rule [
	(rules includesKey: rule id) ifTrue: [ self error: 'Duplicate attribute rule' ].
	rules at: rule id put: rule.
	^ rule
]

{ #category : 'accessing' }
CIAttributeCatalogue >> ruleAt: identifier [
	^ rules at: identifier
]
