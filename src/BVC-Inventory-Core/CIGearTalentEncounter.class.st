Class {
	#name : 'CIGearTalentEncounter',
	#superclass : 'Object',
	#instVars : [
		'mechanic',
		'parameters',
		'evidence',
		'lastTime',
		'criticalExpiries',
		'coverState',
		'coverSince',
		'overwatchPrimed',
		'buffUntil',
		'cooldownUntil'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIGearTalentEncounter class >> talent: aTalent [
	^ self new initializeTalent: aTalent
]

{ #category : 'private' }
CIGearTalentEncounter >> advanceTo: seconds [
	(seconds isNumber
		and: [ seconds >= 0 and: [ lastTime isNil or: [ seconds >= lastTime ] ] ])
		ifFalse: [ self error: 'Gear talent time must advance monotonically' ].
	lastTime := seconds.
	mechanic = #obliterate
		ifTrue: [ criticalExpiries := criticalExpiries select: [ :expiry | expiry > seconds ] ]
]

{ #category : 'combat' }
CIGearTalentEncounter >> armorRepairFractionOnDepletionAt: seconds [
	self advanceTo: seconds.
	(mechanic = #unbreakable and: [ self beginCooldownAt: seconds ])
		ifTrue: [ ^ parameters at: #armorRepairOnDepletion ].
	^ 0
]

{ #category : 'private' }
CIGearTalentEncounter >> beginCooldownAt: seconds [
	(cooldownUntil notNil and: [ seconds < cooldownUntil ]) ifTrue: [ ^ false ].
	cooldownUntil := seconds + (parameters at: #cooldownSeconds).
	^ true
]

{ #category : 'combat' }
CIGearTalentEncounter >> coverState: state at: seconds [
	(#(inCover coverMove exposed) includes: state)
		ifFalse: [ self error: 'Invalid cover state' ].
	self advanceTo: seconds.
	state = coverState ifTrue: [ ^ self ].
	overwatchPrimed := mechanic = #overwatch
			and: [ state ~= #exposed and: [ self overwatchActiveAtCurrentTime ] ].
	coverSince := state = #inCover ifTrue: [ seconds ].
	coverState := state
]

{ #category : 'accessing' }
CIGearTalentEncounter >> evidence [
	^ evidence copy
]

{ #category : 'initialization' }
CIGearTalentEncounter >> initializeTalent: aTalent [
	| rule |
	rule := #(#(obliterate 'obliterate' 'perfectObliterate' 'Gear Talents!D7:F7') #(unbreakable 'unbreakable' 'perfectUnbreakable' 'Gear Talents!D14:F14') #(overwatch 'overwatch' 'perfectOverwatch' 'Gear Talents!D11:F11') #(composure 'composure' 'perfectComposure' 'Gear Talents!D33:F33, Gear Named + Exotics!F25:G25') #(combinedArms 'combinedArms' 'perfectCombinedArms' 'Gear Talents!D26:F26') #(creepingDeath 'creepingDeath' 'perfectCreepingDeath' 'Gear Talents!D47:F47'))
			detect: [ :spec | aTalent id = spec second or: [ aTalent id = spec third ] ]
			ifNone: [ self error: 'Unsupported gear talent' ].
	mechanic := rule first.
	evidence := rule fourth.
	parameters := aTalent parameters.
	criticalExpiries := OrderedCollection new.
	coverState := #exposed.
	overwatchPrimed := false.
	^ self
]

{ #category : 'private' }
CIGearTalentEncounter >> overwatchActiveAtCurrentTime [
	^ overwatchPrimed
		or: [ coverState = #inCover
				and: [ lastTime - coverSince >= (parameters at: #coverSeconds) ] ]
]

{ #category : 'combat' }
CIGearTalentEncounter >> recordEnemyShotCritical: isCritical at: seconds [
	self advanceTo: seconds.
	(mechanic = #obliterate and: [ isCritical ])
		ifTrue: [ criticalExpiries size < (parameters at: #maxStacks)
				ifTrue: [ criticalExpiries add: seconds + (parameters at: #durationSeconds) ] ].
	mechanic = #combinedArms
		ifTrue: [ buffUntil := seconds + (parameters at: #durationSeconds) ]
]

{ #category : 'combat' }
CIGearTalentEncounter >> spreadStatus: application targetsAtDistances: distanceByTarget at: seconds [
	| result radius |
	self advanceTo: seconds.
	mechanic = #creepingDeath ifFalse: [ ^ #() ].
	radius := parameters at: #statusSpreadRadiusMetres.
	result := OrderedCollection new.
	distanceByTarget
		keysAndValuesDo: [ :target :distance | 
			(distance isNumber and: [ distance >= 0 ])
				ifFalse: [ self error: 'Invalid target distance' ].
			(target ~= application targetIdentifier and: [ distance <= radius ])
				ifTrue: [ result
						add: (CICombatStatusApplication
								status: application statusIdentifier
								target: target
								durationSeconds: application durationSeconds) ] ].
	(self beginCooldownAt: seconds) ifFalse: [ ^ #() ].
	^ result asArray
]

{ #category : 'accessing' }
CIGearTalentEncounter >> squadDamageBonusesAt: seconds [
	| active |
	self advanceTo: seconds.
	active := mechanic = #overwatch and: [ self overwatchActiveAtCurrentTime ].
	^ {#weaponDamage
			-> (active ifTrue: [ parameters at: #squadWeaponDamage ] ifFalse: [ 0 ]).
		#skillDamage
			-> (active ifTrue: [ parameters at: #squadSkillDamage ] ifFalse: [ 0 ])}
		asDictionary
]

{ #category : 'accessing' }
CIGearTalentEncounter >> totalSkillDamageBonusAt: seconds [
	self advanceTo: seconds.
	(mechanic = #combinedArms
		and: [ buffUntil notNil and: [ seconds < buffUntil ] ])
		ifTrue: [ ^ parameters at: #skillDamageOnWeaponHit ].
	^ 0
]

{ #category : 'accessing' }
CIGearTalentEncounter >> totalWeaponDamageBonusAt: seconds [
	self advanceTo: seconds.
	mechanic = #obliterate
		ifTrue: [ ^ criticalExpiries size * (parameters at: #weaponDamagePerCriticalHit) ].
	(mechanic = #composure and: [ coverState = #inCover ])
		ifTrue: [ ^ parameters at: #inCoverWeaponDamage ].
	^ 0
]
