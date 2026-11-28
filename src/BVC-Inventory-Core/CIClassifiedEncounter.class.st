Class {
	#name : 'CIClassifiedEncounter',
	#superclass : 'Object',
	#instVars : [
		'redLotus',
		'jupiter'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIClassifiedEncounter class >> forActivations: activations [
	^ self new updateFromActivations: activations
]

{ #category : 'combat' }
CIClassifiedEncounter >> decayTick [
	^ redLotus decayTick
]

{ #category : 'initialization' }
CIClassifiedEncounter >> initialize [
	super initialize.
	redLotus := CIRedLotusEncounterState new.
	jupiter := CIJupiterTransmission new
]

{ #category : 'accessing' }
CIClassifiedEncounter >> jupiterDamageMultiplierForStatusAffected: affected [
	^ jupiter damageMultiplierForStatusAffected: affected
]

{ #category : 'combat' }
CIClassifiedEncounter >> recordWeaponHit [
	^ redLotus recordWeaponHit
]

{ #category : 'accessing' }
CIClassifiedEncounter >> redLotusDamageMultiplier [
	^ redLotus damageMultiplier
]

{ #category : 'combat' }
CIClassifiedEncounter >> spreadOnKillOf: defeatedIdentifier statuses: statuses targetsAtDistances: distances [
	^ jupiter
		spreadOnKillOf: defeatedIdentifier
		statuses: statuses
		targetsAtDistances: distances
]

{ #category : 'combat' }
CIClassifiedEncounter >> updateFromActivations: activations [
	| redActivation jupiterActivation |
	redActivation := activations
			detect: [ :activation | activation family id = 'redLotusAssault' ].
	jupiterActivation := activations
			detect: [ :activation | activation family id = 'jupiterTechnologies' ].
	redLotus updateFromActivation: redActivation.
	jupiter updateFromActivation: jupiterActivation.
	^ self
]
