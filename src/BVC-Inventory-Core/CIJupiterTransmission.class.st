Class {
	#name : 'CIJupiterTransmission',
	#superclass : 'Object',
	#instVars : [
		'parameters'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIJupiterTransmission class >> forActivation: activation [
	^ self new updateFromActivation: activation
]

{ #category : 'accessing' }
CIJupiterTransmission >> damageMultiplierForStatusAffected: isAffected [
	(parameters isNil or: [ isAffected not ]) ifTrue: [ ^ 1 ].
	^ 1 + (parameters at: #damageAmplificationToStatusTargets ifAbsent: [ 0 ])
]

{ #category : 'combat' }
CIJupiterTransmission >> spreadOnKillOf: defeatedIdentifier statuses: applications targetsAtDistances: distanceByTarget [
	| sourceStatuses radius fraction result |
	parameters ifNil: [ ^ #() ].
	sourceStatuses := applications
			select: [ :status | status targetIdentifier = defeatedIdentifier and: [ status durationSeconds > 0 ] ].
	radius := parameters at: #spreadRadiusMetres.
	fraction := parameters at: #durationRefreshFraction.
	result := OrderedCollection new.
	distanceByTarget
		keysAndValuesDo: [ :target :distance | 
			(distance isNumber and: [ distance >= 0 ])
				ifFalse: [ self error: 'Invalid target distance' ].
			(target ~= defeatedIdentifier and: [ distance <= radius ])
				ifTrue: [ sourceStatuses
						do: [ :status | 
							result
								add: (CICombatStatusApplication
										status: status statusIdentifier
										target: target
										durationSeconds: status durationSeconds * fraction) ] ] ].
	^ result asArray
]

{ #category : 'combat' }
CIJupiterTransmission >> updateFromActivation: activation [
	activation family id = 'jupiterTechnologies'
		ifFalse: [ self error: 'Expected a Jupiter activation' ].
	parameters := activation effectiveSetParameters.
	^ self
]
