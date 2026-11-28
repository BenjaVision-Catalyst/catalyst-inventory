Class {
	#name : 'CIGadgetEncounter',
	#superclass : 'Object',
	#instVars : [
		'variant',
		'baseTier',
		'talent',
		'weaponIdentifier',
		'stackExpiries',
		'overchargeUntil',
		'cooldownUntil',
		'lastTime',
		'specializationUpgrades'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIGadgetEncounter class >> variant: aVariant baseTier: aTier weapon: itemId talent: aTalent [
	^ self new
		initializeVariant: aVariant
		baseTier: aTier
		weapon: itemId
		talent: aTalent
]

{ #category : 'instance creation' }
CIGadgetEncounter class >> variant: aVariant baseTier: aTier weapon: itemId talent: aTalent specializationUpgrades: upgrades [
	^ (self
		variant: aVariant
		baseTier: aTier
		weapon: itemId
		talent: aTalent)
		specializationUpgrades: upgrades;
		yourself
]

{ #category : 'combat' }
CIGadgetEncounter >> activeOverchargeRuleAt: seconds [
	^ variant overchargeRuleAtTier: (self effectiveTierAt: seconds)
]

{ #category : 'private' }
CIGadgetEncounter >> advanceTo: seconds [
	(seconds isNumber
		and: [ seconds >= 0 and: [ lastTime isNil or: [ seconds >= lastTime ] ] ])
		ifFalse: [ self error: 'Gadget encounter time must advance monotonically' ].
	lastTime := seconds.
	stackExpiries := stackExpiries select: [ :expiry | expiry > seconds ]
]

{ #category : 'combat' }
CIGadgetEncounter >> effectiveTierAt: seconds [
	self advanceTo: seconds.
	(overchargeUntil notNil and: [ seconds < overchargeUntil ])
		ifTrue: [ ^ #overcharge ].
	^ self normalTier
]

{ #category : 'initialization' }
CIGadgetEncounter >> initializeVariant: aVariant baseTier: aTier weapon: itemId talent: aTalent [
	(aTier isInteger and: [ aTier between: 0 and: 6 ])
		ifFalse: [ self error: 'Invalid gadget tier' ].
	(#('futurePerfect' 'futurePerfection') includes: aTalent id)
		ifFalse: [ self error: 'Unsupported gadget encounter talent' ].
	variant := aVariant.
	baseTier := aTier.
	weaponIdentifier := itemId copy.
	talent := aTalent parameters.
	stackExpiries := OrderedCollection new.
	^ self
]

{ #category : 'private' }
CIGadgetEncounter >> normalTier [
	^ baseTier + stackExpiries size min: (talent at: #overchargeRequiredTier)
]

{ #category : 'accessing' }
CIGadgetEncounter >> overchargeEffectsAt: seconds [
	^ (self effectiveTierAt: seconds) = #overcharge
		ifTrue: [ variant overchargeEffects ]
		ifFalse: [ #() ]
]

{ #category : 'combat' }
CIGadgetEncounter >> recordWeaponKillFrom: itemIdentifier at: seconds [
	self advanceTo: seconds.
	itemIdentifier = weaponIdentifier ifFalse: [ ^ false ].
	self normalTier = (talent at: #overchargeRequiredTier)
		ifTrue: [ (cooldownUntil isNil or: [ seconds >= cooldownUntil ]) ifFalse: [ ^ false ].
			overchargeUntil := seconds + (talent at: #overchargeSeconds).
			cooldownUntil := seconds + (talent at: #overchargeCooldownSeconds).
			^ true ].
	stackExpiries size < (talent at: #maxTierStacks) ifFalse: [ ^ false ].
	stackExpiries add: seconds + (talent at: #tierDurationSeconds).
	^ true
]

{ #category : 'initialization' }
CIGadgetEncounter >> specializationUpgrades: upgrades [
	specializationUpgrades := upgrades asArray copy
]

{ #category : 'accessing' }
CIGadgetEncounter >> statsAt: seconds [
	^ variant
		knownStatsAtTier: (self effectiveTierAt: seconds)
		withSpecializationUpgrades: (specializationUpgrades ifNil: [ #() ])
]
