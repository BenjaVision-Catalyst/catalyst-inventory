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
		'lastTime'
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

{ #category : 'accessing' }
CIExoticWeaponEncounter >> evidence [
	^ evidence copy
]

{ #category : 'initialization' }
CIExoticWeaponEncounter >> initializeWeapon: itemId talent: talent magazineCapacity: capacity [
	| rule |
	rule := #(#(chatterbox 'incessantChatter' 'Weapons Named + Exotics!E130') #(capacitor 'capacitance' 'Weapons Named + Exotics!E112') #(liberty 'libertyOrDeath' 'Weapons Named + Exotics!E173'))
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
CIExoticWeaponEncounter >> rateOfFireBonus [
	mechanic = #chatterbox ifFalse: [ ^ 0 ].
	^ reloadStacks * (parameters at: #rateOfFirePerEnemyOnReload)
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
