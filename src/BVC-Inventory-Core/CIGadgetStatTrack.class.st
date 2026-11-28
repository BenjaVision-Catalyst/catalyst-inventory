Class {
	#name : 'CIGadgetStatTrack',
	#superclass : 'Object',
	#instVars : [
		'label',
		'baseText',
		'baseMagnitude',
		'unit',
		'tierCells',
		'operations',
		'evidence'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIGadgetStatTrack class >> fromWorkbookRow: record [
	^ self new initializeWorkbookRow: record
]

{ #category : 'accessing' }
CIGadgetStatTrack >> baseMagnitude [
	^ baseMagnitude
]

{ #category : 'accessing' }
CIGadgetStatTrack >> baseText [
	^ baseText ifNotNil: #copy
]

{ #category : 'accessing' }
CIGadgetStatTrack >> evidence [
	^ evidence ifNotNil: #copy
]

{ #category : 'private' }
CIGadgetStatTrack >> hasteOperationFor: cell [
	| amount |
	(unit = #seconds and: [ #('Cooldown' 'Refill Speed') includes: label ])
		ifFalse: [ ^ nil ].
	(cell notNil
		and: [ (cell includes: $+) and: [ cell trimBoth endsWith: '% Skill Haste' ] ])
		ifFalse: [ ^ nil ].
	amount := ((cell copyAfter: $+) copyUpTo: $%) trimBoth.
	(amount notEmpty and: [ amount allSatisfy: [ :character | character isDigit ] ])
		ifFalse: [ ^ nil ].
	^ {#haste.
		amount asInteger / 100}
]

{ #category : 'private' }
CIGadgetStatTrack >> indexForTier: aTier [
	aTier = #overcharge ifTrue: [ ^ 7 ].
	(aTier isInteger and: [ aTier between: 1 and: 6 ])
		ifFalse: [ self error: 'Invalid gadget tier' ].
	^ aTier
]

{ #category : 'initialization' }
CIGadgetStatTrack >> initializeWorkbookRow: record [
	evidence := 'Skill List!C' , record first asString , ':M'
			, record first asString.
	label := record second ifNotNil: #copy.
	baseText := record third ifNotNil: #copy.
	baseMagnitude := record fourth.
	unit := record fifth.
	tierCells := (record at: 6) collect: [ :cell | cell ifNotNil: #copy ].
	operations := (record at: 7)
			withIndexCollect: [ :entry :index | entry ifNil: [ self hasteOperationFor: (tierCells at: index) ] ifNotNil: #copy ].
	^ self
]

{ #category : 'accessing' }
CIGadgetStatTrack >> label [
	^ label ifNotNil: #copy
]

{ #category : 'evaluating' }
CIGadgetStatTrack >> magnitudeAtTier: aTier [
	| index cell operation |
	aTier == 0 ifTrue: [ ^ baseMagnitude ].
	index := self indexForTier: aTier.
	baseMagnitude ifNil: [ ^ nil ].
	cell := tierCells at: index.
	cell = '-' ifTrue: [ ^ baseMagnitude ].
	operation := operations at: index.
	operation ifNil: [ ^ nil ].
	operation first = #haste
		ifTrue: [ ^ CISkillHasteRule secondsFromBase: baseMagnitude withHaste: operation second ].
	^ operation first = #relative
		ifTrue: [ baseMagnitude * (1 + operation second) ]
		ifFalse: [ baseMagnitude + operation second ]
]

{ #category : 'accessing' }
CIGadgetStatTrack >> magnitudeAtTier: aTier withSpecializationUpgrades: upgrades [
	| value adjustment |
	value := self magnitudeAtTier: aTier.
	value ifNil: [ ^ nil ].
	adjustment := 0.
	upgrades
		do: [ :upgrade | 
			upgrade resolvedTrack == self
				ifTrue: [ adjustment := adjustment
							+ (upgrade unit = #fraction
									ifTrue: [ value * upgrade reportedMagnitude ]
									ifFalse: [ upgrade reportedMagnitude ]) ] ].
	^ value + adjustment
]

{ #category : 'accessing' }
CIGadgetStatTrack >> rawValueAtTier: aTier [
	aTier == 0 ifTrue: [ ^ self baseText ].
	^ (tierCells at: (self indexForTier: aTier)) ifNotNil: #copy
]

{ #category : 'accessing' }
CIGadgetStatTrack >> unit [
	^ unit
]
