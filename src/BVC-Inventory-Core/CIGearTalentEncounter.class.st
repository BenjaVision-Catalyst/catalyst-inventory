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
		'cooldownUntil',
		'markedEnemyIdentifier',
		'bankedGadgetReset',
		'tamperProofReadyAt'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIGearTalentEncounter class >> talent: aTalent [
	^ self new initializeTalent: aTalent
]

{ #category : 'instance creation' }
CIGearTalentEncounter class >> talent: aTalent mode: mode [
	^ (self talent: aTalent) configureTalent: aTalent mode: mode
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

{ #category : 'initialization' }
CIGearTalentEncounter >> configureTalent: aTalent mode: mode [
	| profile resolved |
	(#(pve pvp) includes: mode) ifFalse: [ self error: 'Unknown talent mode' ].
	mode = #pve ifTrue: [ ^ self ].
	profile := aTalent modeProfileFor: mode.
	resolved := aTalent parametersForMode: mode.
	resolved
		ifNil: [ self
				error: 'Unresolved PvP gear talent: '
						, (profile ifNil: [ 'unspecified' ] ifNotNil: [ profile status asString ]) ].
	parameters := resolved.
	evidence := ', ' join: profile sources keys sorted.
	^ self
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

{ #category : 'combat' }
CIGearTalentEncounter >> gadgetCooldownOnStart: duration at: seconds [
	"Apply a banked Skilled reset to the Gadget starting a cooldown."

	self advanceTo: seconds.
	(mechanic = #skilled and: [ bankedGadgetReset and: [ duration > 0 ] ])
		ifFalse: [ ^ duration ].
	bankedGadgetReset := false.
	^ 0
]

{ #category : 'combat' }
CIGearTalentEncounter >> gadgetCooldownReductionFractionOnEnemyKillAt: seconds [
	"Answers the documented reduction fraction. The cooldown basis is unspecified."

	self advanceTo: seconds.
	^ (mechanic = #calculated and: [ coverState = #inCover ])
		ifTrue: [ parameters at: #cooldownReductionFraction ]
		ifFalse: [ 0 ]
]

{ #category : 'initialization' }
CIGearTalentEncounter >> initializeTalent: aTalent [
	| rule |
	rule := #(#(obliterate 'obliterate' 'perfectObliterate' 'Gear Talents!D7:F7') #(unbreakable 'unbreakable' 'perfectUnbreakable' 'Gear Talents!D14:F14') #(overwatch 'overwatch' 'perfectOverwatch' 'Gear Talents!D11:F11') #(composure 'composure' 'perfectComposure' 'Gear Talents!D33:F33, Gear Named + Exotics!F25:G25') #(combinedArms 'combinedArms' 'perfectCombinedArms' 'Gear Talents!D26:F26') #(calculated 'calculated' 'perfectlyCalculated' 'Gear Talents!D45:F45, Gear Named + Exotics!F19:G19') #(techSupport 'techSupport' 'perfectTechSupport' 'Gear Talents!D27:F27, Gear Named + Exotics!F16:G16') #(skilled 'skilled' 'perfectlySkilled' 'Gear Talents!D21:F21, Gear Named + Exotics!F38:G38') #(tamperProof 'tamperProof' 'perfectlyTamperProof' 'Gear Talents!D24:I24, Gear Named + Exotics!F22:G22') #(tagTeam 'tagTeam' 'tagTeam' 'Gear Talents!D22:F22') #(creepingDeath 'creepingDeath' 'perfectCreepingDeath' 'Gear Talents!D47:F47'))
			detect: [ :spec | aTalent id = spec second or: [ aTalent id = spec third ] ]
			ifNone: [ self error: 'Unsupported gear talent' ].
	mechanic := rule first.
	evidence := rule fourth.
	parameters := aTalent parameters.
	criticalExpiries := OrderedCollection new.
	coverState := #exposed.
	overwatchPrimed := false.
	bankedGadgetReset := false.
	mechanic = #tamperProof ifTrue: [ tamperProofReadyAt := Dictionary new ].
	^ self
]

{ #category : 'accessing' }
CIGearTalentEncounter >> markedEnemyIdentifier [
	^ markedEnemyIdentifier ifNotNil: #copy
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
CIGearTalentEncounter >> recordGadgetDamageToEnemy: enemyIdentifier at: seconds [
	self advanceTo: seconds.
	mechanic = #tagTeam ifFalse: [ ^ self ].
	(cooldownUntil isNil or: [ seconds >= cooldownUntil ])
		ifTrue: [ markedEnemyIdentifier := enemyIdentifier copy ]
]

{ #category : 'combat' }
CIGearTalentEncounter >> recordGadgetDeployment: deploymentIdentifier variant: aVariant at: seconds [
	"Register an owned Gadget deployment. The identifier refers to this deployment instance."

	| family eligible |
	self advanceTo: seconds.
	mechanic = #tamperProof ifFalse: [ ^ self ].
	family := aVariant familyName.
	eligible := (#('Hive' 'Turret') includes: family)
			or: [ (family = 'Pulse' and: [ aVariant name = 'Remote' ])
					or: [ family = 'Decoy' and: [ parameters at: #allowsDecoy ] ] ].
	eligible
		ifTrue: [ tamperProofReadyAt
				at: deploymentIdentifier
				ifAbsentPut: [ seconds + (parameters at: #armSeconds) ] ]
]

{ #category : 'combat' }
CIGearTalentEncounter >> recordGadgetDeploymentEnded: deploymentIdentifier at: seconds [
	self advanceTo: seconds.
	mechanic = #tamperProof
		ifTrue: [ tamperProofReadyAt removeKey: deploymentIdentifier ifAbsent: [  ] ]
]

{ #category : 'combat' }
CIGearTalentEncounter >> recordGadgetKillAt: seconds [
	self advanceTo: seconds.
	mechanic = #techSupport
		ifTrue: [ buffUntil := seconds + (parameters at: #durationSeconds) ]
]

{ #category : 'combat' }
CIGearTalentEncounter >> recordGadgetKillAt: seconds roll: roll remainingGadgetCooldowns: remaining [
	"Roll is a caller-supplied fraction in [0, 1). Remaining cooldowns are in seconds."

	| result |
	self advanceTo: seconds.
	result := remaining copy.
	mechanic = #skilled ifFalse: [ ^ result ].
	(roll isNumber and: [ roll >= 0 and: [ roll < 1 ] ])
		ifFalse: [ self error: 'Gadget cooldown reset roll must be in [0, 1)' ].
	roll < (parameters at: #gadgetCooldownResetChance) ifFalse: [ ^ result ].
	(remaining values anySatisfy: [ :duration | duration > 0 ])
		ifFalse: [ bankedGadgetReset := true.
			^ result ].
	remaining
		keysAndValuesDo: [ :gadget :duration | duration > 0 ifTrue: [ result at: gadget put: 0 ] ].
	^ result
]

{ #category : 'combat' }
CIGearTalentEncounter >> recordWeaponDamageToEnemy: enemyIdentifier at: seconds remainingGadgetCooldowns: remaining [
	| result reduction |
	self advanceTo: seconds.
	result := remaining copy.
	(mechanic = #tagTeam
		and: [ markedEnemyIdentifier notNil and: [ markedEnemyIdentifier = enemyIdentifier ] ])
		ifFalse: [ ^ result ].
	(remaining values anySatisfy: [ :duration | duration > 0 ])
		ifFalse: [ ^ result ].
	(self beginCooldownAt: seconds) ifFalse: [ ^ result ].
	markedEnemyIdentifier := nil.
	reduction := parameters at: #cooldownReductionSeconds.
	remaining
		keysAndValuesDo: [ :gadget :duration | result at: gadget put: (duration - reduction max: 0) ].
	^ result
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

{ #category : 'combat' }
CIGearTalentEncounter >> statusOnEnemyEnteringRangeOfGadget: deploymentIdentifier at: seconds distanceMetres: distance [
	"Answer the status applied to the entering enemy, or nil. The Shock duration is unspecified."

	| readyAt |
	self advanceTo: seconds.
	mechanic = #tamperProof ifFalse: [ ^ nil ].
	(distance isNumber and: [ distance >= 0 ])
		ifFalse: [ self error: 'Invalid Gadget distance' ].
	readyAt := tamperProofReadyAt at: deploymentIdentifier ifAbsent: [ ^ nil ].
	(seconds < readyAt or: [ distance > (parameters at: #shockRadiusMetres) ])
		ifTrue: [ ^ nil ].
	tamperProofReadyAt
		at: deploymentIdentifier
		put: seconds + (parameters at: #cooldownSeconds).
	^ #shock
]

{ #category : 'accessing' }
CIGearTalentEncounter >> totalSkillDamageBonusAt: seconds [
	self advanceTo: seconds.
	(mechanic = #combinedArms
		and: [ buffUntil notNil and: [ seconds < buffUntil ] ])
		ifTrue: [ ^ parameters at: #skillDamageOnWeaponHit ].
	(mechanic = #techSupport and: [ buffUntil notNil and: [ seconds < buffUntil ] ])
		ifTrue: [ ^ parameters at: #skillDamageOnGadgetKill ].
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
