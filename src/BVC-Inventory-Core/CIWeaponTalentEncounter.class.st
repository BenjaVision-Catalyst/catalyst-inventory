Class {
	#name : 'CIWeaponTalentEncounter',
	#superclass : 'Object',
	#instVars : [
		'weaponIdentifier',
		'talent',
		'mechanic',
		'parameters',
		'criticalStacks',
		'skillDamageUntil',
		'weaponDamageUntil',
		'lastTime',
		'sadistKills',
		'unwaveringSwapState'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIWeaponTalentEncounter class >> weapon: itemId talent: aTalent [
	^ self new initializeWeapon: itemId talent: aTalent
]

{ #category : 'private' }
CIWeaponTalentEncounter >> advanceTo: seconds [
	(seconds isNumber
		and: [ seconds >= 0 and: [ lastTime isNil or: [ seconds >= lastTime ] ] ])
		ifFalse: [ self error: 'Weapon talent time must advance monotonically' ].
	lastTime := seconds
]

{ #category : 'combat' }
CIWeaponTalentEncounter >> armorRepairOnKillFrom: itemId headshot: headshot [
	| fraction |
	(mechanic = #preservation and: [ itemId = weaponIdentifier ])
		ifFalse: [ ^ nil ].
	fraction := (parameters at: #armorRepairOnKill)
			+ (headshot
					ifTrue: [ parameters at: #extraArmorRepairOnHeadshotKill ]
					ifFalse: [ 0 ]).
	^ CIArmorRepairEffect
		fraction: fraction
		durationSeconds: (parameters at: #repairSeconds)
		talent: talent id
]

{ #category : 'combat' }
CIWeaponTalentEncounter >> burnResistanceReductionOnEnemyDamageFrom: itemId [
	(mechanic = #primerRounds and: [ itemId = weaponIdentifier ])
		ifFalse: [ ^ nil ].
	^ CICombatStatReduction
		stat: #burnResistance
		fraction: (parameters at: #burnResistanceReduction)
		durationSeconds: (parameters at: #durationSeconds)
]

{ #category : 'combat' }
CIWeaponTalentEncounter >> consumeStatusOnEnemyHitFrom: itemId at: seconds [
	self advanceTo: seconds.
	(mechanic = #sadist
		and: [ itemId = weaponIdentifier
				and: [ sadistKills = (parameters at: #killThreshold) ] ]) ifFalse: [ ^ nil ].
	sadistKills := 0.
	^ parameters at: #status
]

{ #category : 'accessing' }
CIWeaponTalentEncounter >> damageBonusesAt: seconds [
	| weaponBonus skillBonus scale |
	self advanceTo: seconds.
	weaponBonus := 0.
	skillBonus := 0.
	mechanic = #inSync
		ifTrue: [ (weaponDamageUntil notNil and: [ seconds < weaponDamageUntil ])
				ifTrue: [ weaponBonus := parameters at: #weaponDamageOnSkillUseOrHit ].
			(skillDamageUntil notNil and: [ seconds < skillDamageUntil ])
				ifTrue: [ skillBonus := parameters at: #skillDamageOnWeaponHit ] ].
	(mechanic = #spike
		and: [ skillDamageUntil notNil and: [ seconds < skillDamageUntil ] ])
		ifTrue: [ skillBonus := parameters at: #gadgetDamage ].
	scale := (weaponBonus > 0 and: [ skillBonus > 0 ])
			ifTrue: [ parameters at: #dualBuffMultiplier ]
			ifFalse: [ 1 ].
	^ {#weaponDamage -> (weaponBonus * scale).
		#skillDamage -> (skillBonus * scale)} asDictionary
]

{ #category : 'accessing' }
CIWeaponTalentEncounter >> evidence [
	^ (parameters at: #evidence) copy
]

{ #category : 'initialization' }
CIWeaponTalentEncounter >> initializeWeapon: itemId talent: aTalent [
	| rule |
	rule := #(#(optimist 'optimist' 'perfectOptimist' 'Weapon Talents!B5:D5') #(ranger 'ranger' 'perfectRanger' 'Weapon Talents!B13:D13') #(preservation 'preservation' 'perfectPreservation' 'Weapon Talents!B4:D4') #(fastHands 'fastHands' 'perfectFastHands' 'Weapon Talents!B8:D8') #(inSync 'inSync' 'perfectInSync' 'Weapon Talents!B22:D22') #(optimist 'perfectOptimist.dicerosSpecial' 'perfectOptimist.dicerosSpecial' 'Weapons Named + Exotics!E99') #(preservation 'perfectPreservation.p320XCompact' 'perfectPreservation.p320XCompact' 'Weapons Named + Exotics!E95') #(unwavering 'unwavering' 'unwavering' 'Weapon Talents!B54:D54') #(unwavering 'perfectUnwavering.swapChain' 'perfectUnwavering.swapChain' 'Weapons Named + Exotics!E42') #(unwavering 'perfectUnwavering.sharpshooter93r' 'perfectUnwavering.sharpshooter93r' 'Weapons Named + Exotics!E90') #(sadist 'perfectSadist.survivalistD50' 'perfectSadist.survivalistD50' 'Weapons Named + Exotics!E91') #(spike 'perfectSpike.maxim9' 'perfectSpike.maxim9' 'Weapons Named + Exotics!E94') #(primerRounds 'primerRounds.firestarter' 'primerRounds.firestarter' 'Weapons Named + Exotics!E60'))
			detect: [ :spec | aTalent id = spec second or: [ aTalent id = spec third ] ]
			ifNone: [ self error: 'Unsupported weapon talent' ].
	weaponIdentifier := itemId copy.
	talent := aTalent.
	mechanic := rule first.
	parameters := aTalent parameters.
	parameters at: #evidence put: rule fourth.
	criticalStacks := 0.
	sadistKills := 0.
	mechanic = #unwavering
		ifTrue: [ self useUnwaveringSwapState: CIUnwaveringSwapState new ].
	^ self
]

{ #category : 'combat' }
CIWeaponTalentEncounter >> recordEnemyHitFrom: itemId critical: critical at: seconds [
	^ self
		recordEnemyHitFrom: itemId
		critical: critical
		headshot: false
		at: seconds
]

{ #category : 'combat' }
CIWeaponTalentEncounter >> recordEnemyHitFrom: itemId critical: critical headshot: headshot at: seconds [
	self advanceTo: seconds.
	itemId = weaponIdentifier ifFalse: [ ^ self ].
	(mechanic = #fastHands and: [ critical ])
		ifTrue: [ criticalStacks := criticalStacks + 1 min: (parameters at: #maxStacks) ].
	mechanic = #inSync
		ifTrue: [ skillDamageUntil := seconds + (parameters at: #durationSeconds) ].
	(mechanic = #spike and: [ headshot ])
		ifTrue: [ skillDamageUntil := seconds + (parameters at: #durationSeconds) ]
]

{ #category : 'combat' }
CIWeaponTalentEncounter >> recordEnemyKillFrom: itemId at: seconds [
	self advanceTo: seconds.
	itemId = weaponIdentifier ifFalse: [ ^ self ].
	mechanic = #sadist
		ifTrue: [ sadistKills := sadistKills + 1 min: (parameters at: #killThreshold) ].
	unwaveringSwapState
		ifNotNil: [ unwaveringSwapState recordKillFrom: itemId at: seconds ]
]

{ #category : 'combat' }
CIWeaponTalentEncounter >> recordGadgetUseOrDamageAt: seconds [
	self advanceTo: seconds.
	mechanic = #inSync
		ifTrue: [ weaponDamageUntil := seconds + (parameters at: #durationSeconds) ]
]

{ #category : 'combat' }
CIWeaponTalentEncounter >> recordWeaponSwapFrom: previous to: next at: seconds [
	self advanceTo: seconds.
	unwaveringSwapState
		ifNotNil: [ unwaveringSwapState
				recordSwapFrom: previous
				to: next
				at: seconds ]
]

{ #category : 'accessing' }
CIWeaponTalentEncounter >> reloadSpeedBonus [
	mechanic = #fastHands ifFalse: [ ^ 0 ].
	^ criticalStacks * (parameters at: #reloadSpeedPerCriticalHit)
]

{ #category : 'initialization' }
CIWeaponTalentEncounter >> useUnwaveringSwapState: state [
	mechanic = #unwavering
		ifFalse: [ self error: 'This talent does not use Unwavering swap state' ].
	unwaveringSwapState := state.
	state registerWeapon: weaponIdentifier parameters: parameters
]

{ #category : 'combat' }
CIWeaponTalentEncounter >> weaponDamageBonusAgainstBleeding: bleeding [
	(mechanic = #sadist and: [ bleeding ]) ifFalse: [ ^ 0 ].
	^ parameters at: #damageAgainstBleeding
]

{ #category : 'combat' }
CIWeaponTalentEncounter >> weaponDamageBonusForMagazine: capacity remaining: remaining [
	| stepPercent steps |
	mechanic = #optimist ifFalse: [ ^ 0 ].
	(capacity isInteger
		and: [ capacity > 0
				and: [ remaining isInteger and: [ remaining between: 0 and: capacity ] ] ])
		ifFalse: [ self error: 'Invalid magazine state' ].
	stepPercent := ((parameters at: #magazineStep) * 100) rounded.
	steps := (capacity - remaining) * 100 // (capacity * stepPercent).
	^ steps * (parameters at: #damagePerStep)
]

{ #category : 'combat' }
CIWeaponTalentEncounter >> weaponDamageMultiplierAtDistance: metres [
	| intervals |
	mechanic = #ranger ifFalse: [ ^ 1 ].
	(metres isNumber and: [ metres >= 0 ])
		ifFalse: [ self error: 'Invalid target distance' ].
	intervals := (metres / (parameters at: #distanceStepMetres)) floor.
	^ 1 + (intervals * (parameters at: #damageAmplificationPerStep))
]

{ #category : 'combat' }
CIWeaponTalentEncounter >> weaponHandlingBonusAt: seconds [
	self advanceTo: seconds.
	^ unwaveringSwapState
		ifNil: [ 0 ]
		ifNotNil: [ unwaveringSwapState handlingBonusFor: weaponIdentifier at: seconds ]
]
