Class {
	#name : 'CIExoticWeaponEncounter',
	#superclass : 'Object',
	#instVars : [
		'weaponIdentifier',
		'mechanic',
		'parameters',
		'evidence',
		'magazineCapacity',
		'reloadStacks',
		'hitStacks',
		'lastHitAt',
		'appliedDecayTicks',
		'lastTime',
		'markedTargets',
		'markExpiryByTarget',
		'venomExpiriesByTarget'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIExoticWeaponEncounter class >> weapon: itemId talent: talent magazineCapacity: capacity [
	^ self new
		initializeWeapon: itemId
		talent: talent
		magazineCapacity: capacity
]

{ #category : 'private' }
CIExoticWeaponEncounter >> advanceTo: seconds [
	| elapsedTicks |
	(seconds isNumber
		and: [ seconds >= 0 and: [ lastTime isNil or: [ seconds >= lastTime ] ] ])
		ifFalse: [ self error: 'Exotic encounter time must advance monotonically' ].
	lastTime := seconds.
	(mechanic = #capacitor and: [ lastHitAt notNil ]) ifFalse: [ ^ self ].
	elapsedTicks := (seconds - lastHitAt - (parameters at: #decayDelaySeconds)
			max: 0) floor.
	hitStacks := hitStacks
			- ((elapsedTicks - appliedDecayTicks) * (parameters at: #decayStacksPerSecond))
			max: 0.
	appliedDecayTicks := elapsedTicks
]

{ #category : 'combat' }
CIExoticWeaponEncounter >> bluescreenApplicationsOnDeployingShield: shield nearbyByMarkedTarget: distances [
	mechanic = #bluescreen ifFalse: [ ^ #() ].
	(shield and: [ (parameters at: #shieldDeploymentTriggers) not ])
		ifTrue: [ ^ #() ].
	^ self dischargeBluescreenNear: distances excluding: nil
]

{ #category : 'combat' }
CIExoticWeaponEncounter >> bluescreenApplicationsOnKillOf: targetId nearbyByMarkedTarget: distances [
	| result |
	(mechanic = #bluescreen and: [ markedTargets includes: targetId ])
		ifFalse: [ ^ #() ].
	result := (parameters at: #markedKillTriggers)
			ifTrue: [ self dischargeBluescreenNear: distances excluding: targetId ]
			ifFalse: [ #() ].
	self expireBluescreenMarkOn: targetId.
	^ result
]

{ #category : 'accessing' }
CIExoticWeaponEncounter >> capacitorSkillDamageBonusAt: seconds [
	self advanceTo: seconds.
	mechanic = #capacitor ifFalse: [ ^ 0 ].
	^ hitStacks * (parameters at: #skillDamagePerHitStack)
]

{ #category : 'accessing' }
CIExoticWeaponEncounter >> capacitorWeaponDamageBonusAtSkillTier: tier [
	mechanic = #capacitor ifFalse: [ ^ 0 ].
	(tier isInteger and: [ tier between: 0 and: 6 ])
		ifFalse: [ self error: 'Invalid skill tier' ].
	^ tier * (parameters at: #weaponDamagePerSkillTier)
]

{ #category : 'combat' }
CIExoticWeaponEncounter >> consumeLibertyStacksOnHeadshotFrom: itemId [
	| fraction |
	(mechanic = #liberty and: [ itemId = weaponIdentifier ]) ifFalse: [ ^ 0 ].
	fraction := hitStacks * (parameters at: #shieldRepairPerStackOnHeadshot).
	hitStacks := 0.
	^ fraction
]

{ #category : 'private' }
CIExoticWeaponEncounter >> crossed: threshold from: previous to: count [
	^ previous < threshold and: [ count >= threshold ]
]

{ #category : 'combat' }
CIExoticWeaponEncounter >> damageMultiplierForResolvedNemesisCharge: aDamageFraction [
	| bounds |
	bounds := self nemesisChargeDamageBounds.
	bounds ifNil: [ ^ nil ].
	(aDamageFraction isNumber
		and: [ aDamageFraction between: bounds first and: bounds second ])
		ifFalse: [ self error: 'Nemesis charge damage is outside the documented bounds' ].
	^ aDamageFraction
]

{ #category : 'private' }
CIExoticWeaponEncounter >> dischargeBluescreenNear: distances excluding: defeatedId [
	| statuses targets result |
	hitStacks = 0 ifTrue: [ ^ #() ].
	statuses := OrderedCollection new.
	#(pulseStacks disruptStacks disorientStacks)
		with: #(pulse disrupt disorient)
		do: [ :key :status | hitStacks >= (parameters at: key) ifTrue: [ statuses add: status ] ].
	targets := markedTargets copy.
	hitStacks >= (parameters at: #areaStacks)
		ifTrue: [ markedTargets
				do: [ :marked | 
					(distances
						at: marked
						ifAbsent: [ self error: 'Missing nearby targets for marked enemy' ])
						keysAndValuesDo: [ :target :distance | 
							(distance isNumber and: [ distance >= 0 ])
								ifFalse: [ self error: 'Invalid nearby target distance' ].
							distance <= (parameters at: #radiusMetres)
								ifTrue: [ targets add: target ] ] ] ].
	defeatedId ifNotNil: [ targets remove: defeatedId ifAbsent: [  ] ].
	result := targets sorted
			flatCollect: [ :target | 
				statuses
					collect: [ :status | 
						CICombatStatusApplication
							status: status
							target: target
							durationSeconds: (parameters at: #durationSeconds) ] ].
	hitStacks := 0.
	^ result asArray
]

{ #category : 'combat' }
CIExoticWeaponEncounter >> doctorHomePickupOnKillOf: targetId at: seconds [
	| expiry |
	self advanceTo: seconds.
	mechanic = #doctorHome ifFalse: [ ^ nil ].
	expiry := markExpiryByTarget removeKey: targetId ifAbsent: [ ^ nil ].
	seconds >= expiry ifTrue: [ ^ nil ].
	^ CIPartyArmorRepairPickup
		fraction: (parameters at: #groupArmorRepairOnMarkedKill)
		grantsBonusArmor: (parameters at: #grantsBonusArmor)
]

{ #category : 'accessing' }
CIExoticWeaponEncounter >> evidence [
	^ evidence copy
]

{ #category : 'combat' }
CIExoticWeaponEncounter >> expireBluescreenMarkOn: targetId [
	mechanic = #bluescreen
		ifTrue: [ markedTargets remove: targetId ifAbsent: [  ] ]
]

{ #category : 'initialization' }
CIExoticWeaponEncounter >> initializeWeapon: itemId talent: talent magazineCapacity: capacity [
	| rule |
	rule := #(#(chatterbox 'incessantChatter' 'Weapons Named + Exotics!E130') #(capacitor 'capacitance' 'Weapons Named + Exotics!E112') #(liberty 'libertyOrDeath' 'Weapons Named + Exotics!E173') #(doctorHome 'doctorHome' 'Weapons Named + Exotics!E156') #(nemesis 'electromagneticAccelerator' 'Weapons Named + Exotics!E167') #(scorpio 'septicShock' 'Weapons Named + Exotics!E148') #(bluescreen 'disruptorRounds' 'Weapons Named + Exotics!E120'))
			detect: [ :spec | spec second = talent id ]
			ifNone: [ self error: 'Unsupported exotic weapon talent' ].
	weaponIdentifier := itemId copy.
	mechanic := rule first.
	evidence := rule third.
	parameters := talent parameters.
	(capacity isNil or: [ capacity isInteger and: [ capacity > 0 ] ])
		ifFalse: [ self error: 'Invalid effective magazine capacity' ].
	magazineCapacity := capacity.
	reloadStacks := 0.
	hitStacks := 0.
	appliedDecayTicks := 0.
	markedTargets := Set new.
	markExpiryByTarget := Dictionary new.
	venomExpiriesByTarget := Dictionary new.
	^ self
]

{ #category : 'accessing' }
CIExoticWeaponEncounter >> libertyWeaponDamageBonus [
	mechanic = #liberty ifFalse: [ ^ 0 ].
	^ hitStacks * (parameters at: #weaponDamagePerHitStack)
]

{ #category : 'combat' }
CIExoticWeaponEncounter >> magazineRefillOnKillFrom: itemId remaining: remaining [
	| rounds |
	(mechanic = #chatterbox and: [ itemId = weaponIdentifier ]) ifFalse: [ ^ 0 ].
	magazineCapacity ifNil: [ ^ nil ].
	(remaining isInteger and: [ remaining between: 0 and: magazineCapacity ])
		ifFalse: [ self error: 'Invalid remaining rounds' ].
	rounds := magazineCapacity * (parameters at: #magazineRefillOnKill).
	rounds := rounds min: magazineCapacity - remaining.
	rounds = rounds rounded ifFalse: [ ^ nil ].
	^ rounds rounded
]

{ #category : 'accessing' }
CIExoticWeaponEncounter >> nemesisChargeDamageBounds [
	mechanic = #nemesis ifFalse: [ ^ nil ].
	^ {parameters at: #minimumChargedDamage.
		parameters at: #maximumChargedDamage}
]

{ #category : 'accessing' }
CIExoticWeaponEncounter >> rateOfFireBonus [
	mechanic = #chatterbox ifFalse: [ ^ 0 ].
	^ reloadStacks * (parameters at: #rateOfFirePerEnemyOnReload)
]

{ #category : 'combat' }
CIExoticWeaponEncounter >> recordBluescreenHitFrom: itemId on: targetId [
	(mechanic = #bluescreen and: [ itemId = weaponIdentifier ])
		ifFalse: [ ^ false ].
	markedTargets add: targetId copy.
	hitStacks := hitStacks + 1 min: (parameters at: #maxStacks).
	^ true
]

{ #category : 'combat' }
CIExoticWeaponEncounter >> recordDoctorHomeHitFrom: itemId on: targetId at: seconds [
	self advanceTo: seconds.
	(mechanic = #doctorHome and: [ itemId = weaponIdentifier ])
		ifFalse: [ ^ false ].
	markExpiryByTarget
		at: targetId copy
		put: seconds + (parameters at: #markSeconds).
	^ true
]

{ #category : 'combat' }
CIExoticWeaponEncounter >> recordEnemyHitFrom: itemId at: seconds [
	self advanceTo: seconds.
	(itemId = weaponIdentifier and: [ #(capacitor liberty) includes: mechanic ])
		ifFalse: [ ^ false ].
	hitStacks := hitStacks + 1 min: (parameters at: #maxStacks).
	mechanic = #capacitor
		ifTrue: [ lastHitAt := seconds.
			appliedDecayTicks := 0 ].
	^ true
]

{ #category : 'combat' }
CIExoticWeaponEncounter >> recordMagazineEndedFrom: itemId [
	(mechanic = #chatterbox and: [ itemId = weaponIdentifier ])
		ifTrue: [ reloadStacks := 0 ]
]

{ #category : 'combat' }
CIExoticWeaponEncounter >> recordReloadFrom: itemId enemiesAtDistances: distances [
	| radius nearby |
	(mechanic = #chatterbox and: [ itemId = weaponIdentifier ])
		ifFalse: [ ^ false ].
	radius := parameters at: #radiusMetres.
	nearby := distances values
			count: [ :distance | 
				(distance isNumber and: [ distance >= 0 ])
					ifFalse: [ self error: 'Invalid enemy distance' ].
				distance <= radius ].
	reloadStacks := nearby min: (parameters at: #maxStacks).
	^ true
]

{ #category : 'combat' }
CIExoticWeaponEncounter >> recordScorpioHitFrom: itemId on: targetId venomStacks: gained pelletHitFraction: fraction at: seconds [
	| expiries previous count statuses starts refreshes |
	self advanceTo: seconds.
	(mechanic = #scorpio and: [ itemId = weaponIdentifier ]) ifFalse: [ ^ nil ].
	(gained isInteger
		and: [ gained > 0
				and: [ fraction isNumber and: [ fraction > 0 and: [ fraction <= 1 ] ] ] ])
		ifFalse: [ self error: 'Invalid Scorpio hit' ].
	expiries := venomExpiriesByTarget
			at: targetId
			ifAbsentPut: [ OrderedCollection new ].
	expiries := expiries select: [ :expiry | expiry > seconds ].
	previous := expiries size.
	count := previous + gained min: (parameters at: #maxStacks).
	count - previous
		timesRepeat: [ expiries add: seconds + (parameters at: #venomDurationSeconds) ].
	venomExpiriesByTarget at: targetId copy put: expiries.
	statuses := OrderedCollection new.
	#(poisonStacks disorientStacks shockStacks)
		with: #(poison disorient shock)
		do: [ :key :status | 
			(self
				crossed: (parameters at: key)
				from: previous
				to: count) ifTrue: [ statuses add: status ] ].
	starts := self
			crossed: (parameters at: #damageTakenStacks)
			from: previous
			to: count.
	refreshes := self
			crossed: (parameters at: #maxStacks)
			from: previous
			to: count.
	^ CIVenomHitOutcome
		target: targetId
		stacks: count
		statuses: statuses
		pelletHitFraction: fraction
		damageMultiplier: ((starts or: [ refreshes ])
				ifTrue: [ 1 + (parameters at: #additionalDamageTaken) ])
		refreshesDamageDebuff: refreshes
]
