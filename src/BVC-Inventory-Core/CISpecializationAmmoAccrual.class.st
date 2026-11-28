"
Workbook rule for ordinary ammunition gained in fixed amounts. The qualifying state must hold continuously. Once active, the caller supplies elapsed accrual time and the last accounted time. The current-weapon target is resolved by the gameplay caller.
"
Class {
	#name : 'CISpecializationAmmoAccrual',
	#superclass : 'Object',
	#instVars : [
		'condition',
		'qualificationSeconds',
		'intervalSeconds',
		'roundsByTarget'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CISpecializationAmmoAccrual class >> condition: conditionKind qualificationSeconds: delay intervalSeconds: interval roundsByTarget: rounds [
	^ self new
		initializeCondition: conditionKind
		qualificationSeconds: delay
		intervalSeconds: interval
		roundsByTarget: rounds
]

{ #category : 'accessing' }
CISpecializationAmmoAccrual >> condition [
	^ condition
]

{ #category : 'initialization' }
CISpecializationAmmoAccrual >> initializeCondition: conditionKind qualificationSeconds: delay intervalSeconds: interval roundsByTarget: rounds [
	condition := conditionKind.
	qualificationSeconds := delay.
	intervalSeconds := interval.
	roundsByTarget := rounds copy
]

{ #category : 'accessing' }
CISpecializationAmmoAccrual >> intervalSeconds [
	^ intervalSeconds
]

{ #category : 'accessing' }
CISpecializationAmmoAccrual >> qualificationSeconds [
	^ qualificationSeconds
]

{ #category : 'testing' }
CISpecializationAmmoAccrual >> qualifiesAfterSeconds: seconds [
	(seconds isNumber and: [ seconds >= 0 ])
		ifFalse: [ self error: 'Invalid qualifying duration' ].
	^ seconds >= qualificationSeconds
]

{ #category : 'calculating' }
CISpecializationAmmoAccrual >> roundsAccruedFromActiveSeconds: previous through: current [
	"Active time starts after qualification. Count only completed intervals after the previous accounting point."

	| intervals rounds |
	((previous isNumber and: [ previous >= 0 ])
		and: [ current isNumber and: [ current >= previous ] ])
		ifFalse: [ self error: 'Invalid ammunition accrual window' ].
	intervals := current // intervalSeconds - (previous // intervalSeconds).
	rounds := Dictionary new.
	intervals = 0 ifTrue: [ ^ rounds ].
	roundsByTarget
		keysAndValuesDo: [ :target :count | rounds at: target put: count * intervals ].
	^ rounds
]

{ #category : 'accessing' }
CISpecializationAmmoAccrual >> roundsByTarget [
	^ roundsByTarget copy
]
