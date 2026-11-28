Class {
	#name : 'CISpecializationEncounter',
	#superclass : 'Object',
	#instVars : [
		'loadout',
		'mode',
		'perksById',
		'startedAt',
		'lastTime',
		'barrageUntil',
		'reloadCount',
		'supplyTicks',
		'explosionReadyAt'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CISpecializationEncounter class >> forLoadout: selectedLoadout mode: gameMode startedAt: seconds [
	^ self new
		initializeLoadout: selectedLoadout
		mode: gameMode
		startedAt: seconds
]

{ #category : 'private' }
CISpecializationEncounter >> advanceTo: seconds [
	(seconds isNumber
		and: [ seconds >= 0 and: [ lastTime isNil or: [ seconds >= lastTime ] ] ])
		ifFalse: [ self error: 'Specialization encounter time must advance monotonically' ].
	lastTime := seconds
]

{ #category : 'combat' }
CISpecializationEncounter >> blocksExplosionAt: seconds [
	| parameters |
	self advanceTo: seconds.
	parameters := self parametersFor: 'demolitionist.bracedforimpact'.
	(parameters isNil
		or: [ explosionReadyAt notNil and: [ seconds < explosionReadyAt ] ])
		ifTrue: [ ^ false ].
	explosionReadyAt := seconds + (parameters at: #cooldownSeconds).
	^ true
]

{ #category : 'combat' }
CISpecializationEncounter >> damageBonusForAlly: isAlly targetDistanceFromOwner: metres [
	| parameters |
	parameters := self parametersFor: 'firewall.firewalltacticallink'.
	(parameters isNil or: [ isAlly not ]) ifTrue: [ ^ 0 ].
	(self isValidDistance: metres)
		ifFalse: [ self error: 'Invalid enemy distance' ].
	metres <= (parameters at: #radiusMetres) ifFalse: [ ^ 0 ].
	^ parameters at: #damage
]

{ #category : 'combat' }
CISpecializationEncounter >> damageBonusForGroupMember: isGroupMember targetHasStatusEffect: hasStatusEffect [
	| parameters |
	parameters := self parametersFor: 'survivalist.survivalisttacticallink'.
	(parameters isNil or: [ (isGroupMember and: [ hasStatusEffect ]) not ])
		ifTrue: [ ^ 0 ].
	^ parameters at: #damage
]

{ #category : 'combat' }
CISpecializationEncounter >> damageBonusForGroupMember: isGroupMember targetOutOfCover: outOfCover [
	| parameters |
	parameters := self parametersFor: 'demolitionist.demolitionisttacticallink'.
	(parameters isNil or: [ (isGroupMember and: [ outOfCover ]) not ])
		ifTrue: [ ^ 0 ].
	^ parameters at: #damage
]

{ #category : 'combat' }
CISpecializationEncounter >> faradayImmunitiesAtDistance: metres deployed: deployed disrupted: disrupted [
	| parameters |
	parameters := self parametersFor: 'technician.faradayfield'.
	(parameters isNil or: [ deployed not or: [ disrupted ] ]) ifTrue: [ ^ #() ].
	(metres isNumber and: [ metres >= 0 ])
		ifFalse: [ self error: 'Invalid skill distance' ].
	metres <= (parameters at: #radiusMetres)
		ifTrue: [ ^ (parameters at: #immunities) copy ].
	^ #()
]

{ #category : 'combat' }
CISpecializationEncounter >> faradayImmunitiesForPartyMember: partyMember atDistance: metres deployed: deployed disrupted: disrupted [
	partyMember ifFalse: [ ^ #() ].
	^ self
		faradayImmunitiesAtDistance: metres
		deployed: deployed
		disrupted: disrupted
]

{ #category : 'combat' }
CISpecializationEncounter >> fieryResponseBurnTargetsOnArmorBreak: enemyDistances at: seconds [
	| parameters targets |
	self advanceTo: seconds.
	parameters := self parametersFor: 'firewall.fieryresponse'.
	(parameters isNil or: [ mode = #pvp and: [ parameters at: #disabledInPvP ] ])
		ifTrue: [ ^ #() ].
	targets := OrderedCollection new.
	enemyDistances
		keysAndValuesDo: [ :id :metres | 
			(metres isNumber and: [ metres >= 0 ])
				ifFalse: [ self error: 'Invalid enemy distance' ].
			metres <= (parameters at: #radiusMetres) ifTrue: [ targets add: id copy ] ].
	^ targets sorted asArray
]

{ #category : 'combat' }
CISpecializationEncounter >> headshotDamageBonusForGroupMember: isGroupMember attackerDistance: attackerMetres ownerDistance: ownerMetres [
	| parameters |
	parameters := self parametersFor: 'sharpshooter.sharpshootertacticallink'.
	(parameters isNil or: [ isGroupMember not ]) ifTrue: [ ^ 0 ].
	(self isValidDistance: attackerMetres) & (self isValidDistance: ownerMetres)
		ifFalse: [ self error: 'Invalid enemy distance' ].
	attackerMetres < ownerMetres ifFalse: [ ^ 0 ].
	^ parameters at: #headshotDamage
]

{ #category : 'initialization' }
CISpecializationEncounter >> initializeLoadout: selectedLoadout mode: gameMode startedAt: seconds [
	(#(pve pvp) includes: gameMode)
		ifFalse: [ self error: 'Unknown encounter mode' ].
	loadout := selectedLoadout.
	mode := gameMode.
	self advanceTo: seconds.
	startedAt := seconds.
	reloadCount := 0.
	supplyTicks := 0.
	perksById := Dictionary new.
	loadout selectedPerks do: [ :perk | perksById at: perk id put: perk ].
	^ self
]

{ #category : 'private' }
CISpecializationEncounter >> isValidDistance: metres [
	^ metres isNumber and: [ metres >= 0 ]
]

{ #category : 'accessing' }
CISpecializationEncounter >> loadout [
	^ loadout
]

{ #category : 'private' }
CISpecializationEncounter >> parametersFor: perkId [
	^ (perksById at: perkId ifAbsent: [ nil ]) ifNotNil: #eventParameters
]

{ #category : 'accessing' }
CISpecializationEncounter >> rateOfFireBonusAt: seconds [
	self advanceTo: seconds.
	(barrageUntil isNil or: [ seconds >= barrageUntil ]) ifTrue: [ ^ 0 ].
	^ (self parametersFor: 'gunner.barrage') at: #rateOfFire
]

{ #category : 'combat' }
CISpecializationEncounter >> recordEnemyKillAt: seconds [
	| parameters |
	self advanceTo: seconds.
	parameters := self parametersFor: 'gunner.barrage'.
	parameters
		ifNotNil: [ barrageUntil := seconds + (parameters at: #durationSeconds) ]
]

{ #category : 'combat' }
CISpecializationEncounter >> reloadSpeedBonusForNextReloadAt: seconds [
	| parameters interval |
	self advanceTo: seconds.
	parameters := self parametersFor: 'gunner.coupler'.
	parameters ifNil: [ ^ 0 ].
	reloadCount := reloadCount + 1.
	interval := parameters at: #reloadInterval.
	reloadCount \\ interval = 0 ifTrue: [ ^ parameters at: #reloadSpeed ].
	^ 0
]

{ #category : 'combat' }
CISpecializationEncounter >> supplyLineGrantsThrough: seconds [
	| parameters total newlyDue |
	self advanceTo: seconds.
	parameters := self parametersFor: 'gunner.supplyline'.
	parameters ifNil: [ ^ nil ].
	total := (seconds - startedAt) // (parameters at: #intervalSeconds).
	newlyDue := total - supplyTicks.
	newlyDue = 0 ifTrue: [ ^ nil ].
	supplyTicks := total.
	^ CISpecializationAmmoGrant
		ticks: newlyDue
		personal: (parameters at: #personalFraction)
		party: (parameters at: #partyFraction)
]
