"
Encounter state shared by a player's Unwavering weapons so swapping away can lock out the talent across the whole loadout.
"
Class {
	#name : 'CIUnwaveringSwapState',
	#superclass : 'Object',
	#instVars : [
		'profilesByWeapon',
		'activeWeapon',
		'buffUntil',
		'lockoutUntil',
		'lastTime'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'private' }
CIUnwaveringSwapState >> advanceTo: seconds [
	(seconds isNumber
		and: [ seconds >= 0 and: [ lastTime isNil or: [ seconds >= lastTime ] ] ])
		ifFalse: [ self error: 'Weapon swap time must advance monotonically' ].
	lastTime := seconds
]

{ #category : 'combat' }
CIUnwaveringSwapState >> handlingBonusFor: itemId at: seconds [
	self advanceTo: seconds.
	(activeWeapon = itemId and: [ buffUntil notNil and: [ seconds < buffUntil ] ])
		ifFalse: [ ^ 0 ].
	^ (profilesByWeapon at: itemId) at: #weaponHandling
]

{ #category : 'initialization' }
CIUnwaveringSwapState >> initialize [
	super initialize.
	profilesByWeapon := Dictionary new
]

{ #category : 'combat' }
CIUnwaveringSwapState >> recordKillFrom: itemId at: seconds [
	self advanceTo: seconds.
	(activeWeapon = itemId and: [ buffUntil notNil and: [ seconds < buffUntil ] ])
		ifTrue: [ | profile |
			profile := profilesByWeapon at: itemId.
			(profile at: #killsRefresh)
				ifTrue: [ buffUntil := seconds + (profile at: #durationSeconds) ] ]
]

{ #category : 'combat' }
CIUnwaveringSwapState >> recordSwapFrom: previous to: next at: seconds [
	| outgoing incoming |
	self advanceTo: seconds.
	previous = next ifTrue: [ ^ self ].
	outgoing := profilesByWeapon at: previous ifAbsent: [ nil ].
	outgoing
		ifNotNil: [ lockoutUntil := seconds + (outgoing at: #swapAwayLockoutSeconds) ].
	activeWeapon := nil.
	buffUntil := nil.
	(lockoutUntil notNil and: [ seconds < lockoutUntil ]) ifTrue: [ ^ self ].
	incoming := profilesByWeapon at: next ifAbsent: [ ^ self ].
	activeWeapon := next copy.
	buffUntil := seconds + (incoming at: #durationSeconds)
]

{ #category : 'initialization' }
CIUnwaveringSwapState >> registerWeapon: itemId parameters: profile [
	profilesByWeapon at: itemId copy put: profile copy
]
