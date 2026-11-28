Class {
	#name : 'CICombatStatusApplication',
	#superclass : 'Object',
	#instVars : [
		'statusIdentifier',
		'targetIdentifier',
		'durationSeconds'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CICombatStatusApplication class >> status: statusId target: targetId durationSeconds: seconds [
	^ self new
		initializeStatus: statusId
		target: targetId
		durationSeconds: seconds
]

{ #category : 'accessing' }
CICombatStatusApplication >> durationSeconds [
	^ durationSeconds
]

{ #category : 'initialization' }
CICombatStatusApplication >> initializeStatus: statusId target: targetId durationSeconds: seconds [
	(seconds isNumber and: [ seconds >= 0 ])
		ifFalse: [ self error: 'Invalid status duration' ].
	statusIdentifier := statusId copy.
	targetIdentifier := targetId copy.
	durationSeconds := seconds.
	^ self
]

{ #category : 'accessing' }
CICombatStatusApplication >> statusIdentifier [
	^ statusIdentifier copy
]

{ #category : 'accessing' }
CICombatStatusApplication >> targetIdentifier [
	^ targetIdentifier copy
]
