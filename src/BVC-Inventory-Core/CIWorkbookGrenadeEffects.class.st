"
Documented targeting and effects of a specialization grenade. A nil radius or damage flag means the workbook and cited sources supply no resolved value.
"
Class {
	#name : 'CIWorkbookGrenadeEffects',
	#superclass : 'Object',
	#instVars : [
		'targetKind',
		'delivery',
		'statuses',
		'dealsDamage',
		'radiusMetres',
		'radiusEvidence'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIWorkbookGrenadeEffects class >> fromWorkbookRow: row statuses: statuses [
	^ self new initializeFromWorkbookRow: row statuses: statuses
]

{ #category : 'accessing' }
CIWorkbookGrenadeEffects >> dealsDamage [
	^ dealsDamage
]

{ #category : 'accessing' }
CIWorkbookGrenadeEffects >> delivery [
	^ delivery
]

{ #category : 'testing' }
CIWorkbookGrenadeEffects >> includesDistance: metres [
	(metres isNumber and: [ metres >= 0 ])
		ifFalse: [ self error: 'Invalid effect distance' ].
	^ radiusMetres ifNotNil: [ metres <= radiusMetres ]
]

{ #category : 'initialization' }
CIWorkbookGrenadeEffects >> initializeFromWorkbookRow: row statuses: statusIds [
	targetKind := row first.
	delivery := row second.
	dealsDamage := row third.
	radiusMetres := row fourth.
	radiusEvidence := row fifth.
	statuses := statusIds asArray copy
]

{ #category : 'accessing' }
CIWorkbookGrenadeEffects >> radiusEvidence [
	^ radiusEvidence ifNotNil: #copy
]

{ #category : 'accessing' }
CIWorkbookGrenadeEffects >> radiusMetres [
	^ radiusMetres
]

{ #category : 'evaluating' }
CIWorkbookGrenadeEffects >> statusesForTargetKind: actualKind atDistance: metres [
	^ (self includesDistance: metres)
		ifNotNil: [ :withinArea | self statusesForTargetKind: actualKind withinAffectedArea: withinArea ]
]

{ #category : 'evaluating' }
CIWorkbookGrenadeEffects >> statusesForTargetKind: actualKind withinAffectedArea: withinArea [
	(withinArea and: [ targetKind = #anyTarget or: [ targetKind = actualKind ] ])
		ifFalse: [ ^ #() ].
	^ statuses copy
]

{ #category : 'accessing' }
CIWorkbookGrenadeEffects >> targetKind [
	^ targetKind
]
