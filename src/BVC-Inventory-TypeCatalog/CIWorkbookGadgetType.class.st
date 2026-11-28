Class {
	#name : 'CIWorkbookGadgetType',
	#superclass : 'CIGadgetType',
	#instVars : [
		'variantDefinition'
	],
	#category : 'BVC-Inventory-TypeCatalog',
	#package : 'BVC-Inventory-TypeCatalog'
}

{ #category : 'instance creation' }
CIWorkbookGadgetType class >> id: anId variant: variant [
	^ (self
		id: anId
		name: variant name
		icon: nil) initializeVariant: variant
]

{ #category : 'accessing' }
CIWorkbookGadgetType >> activationLabel [
	^ variantDefinition name
]

{ #category : 'accessing' }
CIWorkbookGadgetType >> baseStats [
	^ variantDefinition knownStatsAtTier: 0
]

{ #category : 'private' }
CIWorkbookGadgetType >> displayValue: value unit: unit [
	| number |
	number := value rounded = value
			ifTrue: [ value rounded asString ]
			ifFalse: [ value asFloat printShowingDecimalPlaces: 3 ].
	unit = #seconds ifTrue: [ ^ number , ' s' ].
	unit = #metres ifTrue: [ ^ number , ' m' ].
	unit = #multiplier ifTrue: [ ^ number , 'x' ].
	unit = #fraction ifTrue: [ ^ (value * 100) asString , '%' ].
	^ number
]

{ #category : 'initialization' }
CIWorkbookGadgetType >> initializeVariant: variant [
	variantDefinition := variant.
	^ self
]

{ #category : 'descriptions' }
CIWorkbookGadgetType >> inspectorIdentityFor: item [
	^ Dictionary new
		at: 'inspectorCategory' put: variantDefinition familyName;
		yourself
]

{ #category : 'descriptions' }
CIWorkbookGadgetType >> inspectorSectionsAtUtilityTier: tier item: item [
	| supported rows |
	supported := tier isInteger and: [ tier between: 0 and: 6 ].
	rows := supported
			ifTrue: [ (variantDefinition tracks select: [ :track | track label notNil ])
					collect: [ :track | 
						| value |
						value := track magnitudeAtTier: tier.
						{track label.
							value
								ifNil: [ (track rawValueAtTier: tier) ifNil: [ 'Unspecified' ] ]
								ifNotNil: [ self displayValue: value unit: track unit ]} ] ]
			ifFalse: [ #() ].
	^ {{'stats'.
			'Stats'.
			rows}.
		{'tier'.
			'Utility Tier'.
			{{'Current tier'.
					tier asString}}}}
]

{ #category : 'accessing' }
CIWorkbookGadgetType >> modSocketIdentifiers [
	^ #()
]

{ #category : 'accessing' }
CIWorkbookGadgetType >> statsAtUtilityTier: aTier [
	^ variantDefinition knownStatsAtTier: aTier
]

{ #category : 'accessing' }
CIWorkbookGadgetType >> workbookVariantDefinition [
	^ variantDefinition
]
