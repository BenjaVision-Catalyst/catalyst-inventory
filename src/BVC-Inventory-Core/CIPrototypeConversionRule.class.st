"
The documented requirements for converting an item to Prototype quality. Conversion eligibility can remain unknown for an individual item in a supported quality.
"
Class {
	#name : 'CIPrototypeConversionRule',
	#superclass : 'CIAttributeRule',
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'evaluating' }
CIPrototypeConversionRule >> eligibilityForQuality: quality itemLevel: level itemGrade: grade itemEligible: itemEligible [
	"Answer nil when the documented gates pass but some eligibility data is unknown."

	(quality notNil
		and: [ ((parameters at: #sourceQualities) includes: quality) not ])
		ifTrue: [ ^ false ].
	(level notNil and: [ level ~= self requiredItemLevel ]) ifTrue: [ ^ false ].
	(grade notNil and: [ grade ~= self requiredItemGrade ]) ifTrue: [ ^ false ].
	itemEligible == false ifTrue: [ ^ false ].
	(quality isNil or: [ level isNil or: [ grade isNil ] ]) ifTrue: [ ^ nil ].
	^ itemEligible
]

{ #category : 'accessing' }
CIPrototypeConversionRule >> requiredItemGrade [
	^ parameters at: #requiredItemGrade
]

{ #category : 'accessing' }
CIPrototypeConversionRule >> requiredItemLevel [
	^ parameters at: #requiredItemLevel
]

{ #category : 'accessing' }
CIPrototypeConversionRule >> requiredPrototypeCores [
	^ parameters at: #requiredPrototypeCores
]

{ #category : 'accessing' }
CIPrototypeConversionRule >> sourceQualities [
	^ (parameters at: #sourceQualities) copy
]
