Class {
	#name : 'CIGearAttributeSlot',
	#superclass : 'Object',
	#instVars : [
		'id',
		'role',
		'choices',
		'fixedValue',
		'minimum',
		'maximum'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIGearAttributeSlot class >> id: identifier role: slotRole choices: definitions fixed: amount minimum: minimumValue maximum: maximumValue [
	^ self new
		initializeId: identifier
		role: slotRole
		choices: definitions
		fixed: amount
		minimum: minimumValue
		maximum: maximumValue
]

{ #category : 'accessing' }
CIGearAttributeSlot >> eligibleAttributeIds [
	^ choices keys sorted
]

{ #category : 'accessing' }
CIGearAttributeSlot >> fixedValue [
	^ fixedValue
]

{ #category : 'accessing' }
CIGearAttributeSlot >> id [
	^ id copy
]

{ #category : 'initialization' }
CIGearAttributeSlot >> initializeId: identifier role: slotRole choices: definitions fixed: amount minimum: minimumValue maximum: maximumValue [
	id := identifier copy.
	role := slotRole.
	choices := Dictionary new.
	definitions do: [ :each | choices at: each id put: each ].
	choices ifEmpty: [ self error: 'Gear slot has no eligible attributes' ].
	(amount notNil and: [ choices size ~= 1 ])
		ifTrue: [ self error: 'Fixed slot must identify one attribute' ].
	fixedValue := amount.
	minimum := minimumValue.
	maximum := maximumValue.
	^ self
]

{ #category : 'accessing' }
CIGearAttributeSlot >> maximum [
	^ maximum
]

{ #category : 'accessing' }
CIGearAttributeSlot >> maximumFor: definition [
	| documented |
	fixedValue ifNotNil: [ ^ fixedValue ].
	maximum ifNotNil: [ ^ maximum ].
	documented := definition valueFor: #standardMaximum.
	^ documented ifNotNil: #magnitude
]

{ #category : 'accessing' }
CIGearAttributeSlot >> minimum [
	^ minimum
]

{ #category : 'generating' }
CIGearAttributeSlot >> resolve: supplied [
	| roll definition limit |
	roll := supplied.
	roll
		ifNil: [ fixedValue
				ifNil: [ self error: 'Missing generation rule or supplied roll for: ' , id ].
			roll := fixedValue ].
	(roll isNumber and: [ choices size = 1 ])
		ifTrue: [ roll := CIGearAttributeRoll attribute: choices keys anyOne value: roll ].
	(roll isKindOf: CIGearAttributeRoll)
		ifFalse: [ self error: 'An attribute ID and value are required for: ' , id ].
	definition := choices
			at: roll attributeIdentifier
			ifAbsent: [ self error: 'Attribute is ineligible for: ' , id ].
	limit := self maximumFor: definition.
	((fixedValue isNil or: [ roll value = fixedValue ])
		and: [ (minimum isNil or: [ roll value >= minimum ])
				and: [ limit isNil or: [ roll value <= limit ] ] ])
		ifFalse: [ self error: 'Value violates the documented constraints for: ' , id ].
	^ roll
]

{ #category : 'accessing' }
CIGearAttributeSlot >> role [
	^ role
]

{ #category : 'generating' }
CIGearAttributeSlot >> summaryFor: roll [
	| definition unit category summary |
	definition := choices at: roll attributeIdentifier.
	unit := (definition valueFor: #standardMaximum) unit.
	category := (definition group includesSubstring: 'Offensive')
			ifTrue: [ 'offensive' ]
			ifFalse: [ (definition group includesSubstring: 'Skill')
					ifTrue: [ 'utility' ]
					ifFalse: [ (role = #core and: [ unit = #fraction ])
							ifTrue: [ 'offensive' ]
							ifFalse: [ 'defensive' ] ] ].
	summary := CIInventoryGearAttributeSummary
			identifier: (definition id findTokens: '.') last
			label: definition label
			type: category
			value: roll value
			format: (unit = #fraction
					ifTrue: [ 'signedPercent' ]
					ifFalse: [ 'signedNumber' ])
			hasMaximum: roll value = (self maximumFor: definition).
	summary generationSlotIdentifier: id.
	^ summary
]
