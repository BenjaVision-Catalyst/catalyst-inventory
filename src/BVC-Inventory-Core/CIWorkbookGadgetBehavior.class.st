"
Workbook targeting and effect rules for a gadget variant. The caller supplies resolved geometry and the variant's effective tier stats.
"
Class {
	#name : 'CIWorkbookGadgetBehavior',
	#superclass : 'Object',
	#instVars : [
		'targetKind',
		'delivery',
		'coverIgnored',
		'effects',
		'holsteredOwnerOnly',
		'statLabels',
		'evidence',
		'compatibleSignatureWeaponIdentifier'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIWorkbookGadgetBehavior class >> fromWorkbookRow: row evidence: source [
	^ self new initializeFromWorkbookRow: row evidence: source
]

{ #category : 'testing' }
CIWorkbookGadgetBehavior >> allowsSignatureWeapon: identifier [
	^ compatibleSignatureWeaponIdentifier notNil
		and: [ compatibleSignatureWeaponIdentifier = identifier ]
]

{ #category : 'evaluating' }
CIWorkbookGadgetBehavior >> damageBonusForEnemiesInFront: enemyCount recipientIsOwner: owner allyBehind: allyBehind stats: effectiveStats [
	(enemyCount isInteger and: [ enemyCount >= 0 ])
		ifFalse: [ self error: 'Invalid enemy count' ].
	((effects includes: #damageBonusPerEnemy) and: [ owner or: [ allyBehind ] ])
		ifFalse: [ ^ 0 ].
	enemyCount = 0 ifTrue: [ ^ 0 ].
	^ effectiveStats
		at: 'Damage bonus / (per enemy)'
		ifPresent: [ :amount | amount * enemyCount ]
		ifAbsent: [ nil ]
]

{ #category : 'accessing' }
CIWorkbookGadgetBehavior >> delivery [
	^ delivery
]

{ #category : 'accessing' }
CIWorkbookGadgetBehavior >> effects [
	^ effects copy
]

{ #category : 'evaluating' }
CIWorkbookGadgetBehavior >> effectsForTargetKind: actualKind ownedByAgent: ownedByAgent holstered: holstered withinAffectedArea: withinArea stats: effectiveStats [
	| knownStats |
	(withinArea and: [ actualKind = targetKind ]) ifFalse: [ ^ Dictionary new ].
	(holstered and: [ (holsteredOwnerOnly and: [ ownedByAgent ]) not ])
		ifTrue: [ ^ Dictionary new ].
	knownStats := Dictionary new.
	statLabels
		do: [ :label | 
			effectiveStats
				at: label
				ifPresent: [ :value | knownStats at: label copy put: value ] ].
	^ {#effects -> effects copy.
		#stats -> knownStats} asDictionary
]

{ #category : 'accessing' }
CIWorkbookGadgetBehavior >> evidence [
	^ evidence copy
]

{ #category : 'accessing' }
CIWorkbookGadgetBehavior >> ignoresCover [
	^ coverIgnored
]

{ #category : 'initialization' }
CIWorkbookGadgetBehavior >> initializeFromWorkbookRow: row evidence: source [
	targetKind := row first.
	delivery := row second.
	coverIgnored := row third.
	effects := row fourth copy.
	holsteredOwnerOnly := row fifth.
	statLabels := row sixth collect: #copy.
	compatibleSignatureWeaponIdentifier := row seventh.
	evidence := source copy
]

{ #category : 'accessing' }
CIWorkbookGadgetBehavior >> targetKind [
	^ targetKind
]
