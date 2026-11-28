"
Source-backed interpretation of the Weapons sheet's Mod Slots cell. Slot counts and missing categories do not establish the interface of any available mount. The long-rail marker preserves the workbook wording without assigning it to an optics or underbarrel socket.
"
Class {
	#name : 'CIWeaponMountLayout',
	#superclass : 'Object',
	#instVars : [
		'rawNotation',
		'evidence',
		'status',
		'reportedSlotCount',
		'missingSlotKinds',
		'longRailReported',
		'unresolvedMarkers'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIWeaponMountLayout class >> fromNotation: text evidence: source [
	^ self new initializeFromNotation: text evidence: source
]

{ #category : 'accessing' }
CIWeaponMountLayout >> evidence [
	^ evidence ifNotNil: #copy
]

{ #category : 'initialization' }
CIWeaponMountLayout >> initializeFromNotation: text evidence: source [
	| notation stream digits markers |
	rawNotation := text ifNotNil: #copy.
	evidence := source ifNotNil: #copy.
	status := #unspecified.
	missingSlotKinds := #().
	longRailReported := false.
	unresolvedMarkers := ''.
	notation := text ifNil: [ '' ] ifNotNil: #trimBoth.
	notation isEmpty ifTrue: [ ^ self ].
	notation asUppercase = 'N/A'
		ifTrue: [ status := #notApplicable.
			^ self ].
	stream := notation readStream.
	digits := String
			streamContents: [ :count | 
				[ stream atEnd not and: [ stream peek isDigit ] ]
					whileTrue: [ count nextPut: stream next ] ].
	markers := stream upToEnd.
	(markers beginsWith: '.0') ifTrue: [ markers := markers allButFirst: 2 ].
	(digits isEmpty or: [ markers beginsWith: '.' ])
		ifTrue: [ unresolvedMarkers := notation copy.
			^ self ].
	status := #reported.
	reportedSlotCount := digits asInteger.
	missingSlotKinds := (#(#('!' muzzle) #('#' underbarrel) #('$' magazine) #('&' optics))
			select: [ :mapping | markers includes: mapping first first ])
			collect: #second.
	longRailReported := markers includes: $\.
	unresolvedMarkers := markers reject: [ :marker | '!#$&\' includes: marker ].
	^ self
]

{ #category : 'accessing' }
CIWeaponMountLayout >> longRailReported [
	^ longRailReported
]

{ #category : 'accessing' }
CIWeaponMountLayout >> missingSlotKinds [
	^ missingSlotKinds copy
]

{ #category : 'accessing' }
CIWeaponMountLayout >> rawNotation [
	^ rawNotation ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponMountLayout >> reportedSlotCount [
	^ reportedSlotCount
]

{ #category : 'accessing' }
CIWeaponMountLayout >> status [
	^ status
]

{ #category : 'testing' }
CIWeaponMountLayout >> statusOfSlotKind: aSlotKind [
	status = #notApplicable ifTrue: [ ^ #notApplicable ].
	(reportedSlotCount = 0 or: [ missingSlotKinds includes: aSlotKind ])
		ifTrue: [ ^ #absent ].
	^ #unspecified
]

{ #category : 'accessing' }
CIWeaponMountLayout >> unresolvedMarkers [
	^ unresolvedMarkers copy
]
