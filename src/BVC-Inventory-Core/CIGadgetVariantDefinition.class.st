Class {
	#name : 'CIGadgetVariantDefinition',
	#superclass : 'Object',
	#instVars : [
		'familyName',
		'name',
		'tracks',
		'overchargeEffects',
		'expertiseScaling',
		'behaviorProfile'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIGadgetVariantDefinition class >> family: family variant: label tracks: stats overcharge: effects expertise: expertise [
	^ self new
		initializeFamily: family
		variant: label
		tracks: stats
		overcharge: effects
		expertise: expertise
]

{ #category : 'accessing' }
CIGadgetVariantDefinition >> behaviorProfile [
	^ behaviorProfile
]

{ #category : 'initialization' }
CIGadgetVariantDefinition >> behaviorProfile: profile [
	behaviorProfile := profile
]

{ #category : 'accessing' }
CIGadgetVariantDefinition >> expertiseScaling [
	^ expertiseScaling collect: #copy
]

{ #category : 'accessing' }
CIGadgetVariantDefinition >> familyName [
	^ familyName copy
]

{ #category : 'initialization' }
CIGadgetVariantDefinition >> initializeFamily: family variant: label tracks: stats overcharge: effects expertise: expertise [
	familyName := family copy.
	name := label copy.
	tracks := stats asArray copy.
	overchargeEffects := effects collect: #copy.
	expertiseScaling := expertise collect: #copy.
	^ self
]

{ #category : 'evaluating' }
CIGadgetVariantDefinition >> knownStatsAtTier: aTier [
	^ self knownStatsAtTier: aTier withSpecializationUpgrades: #()
]

{ #category : 'accessing' }
CIGadgetVariantDefinition >> knownStatsAtTier: aTier withSpecializationUpgrades: upgrades [
	| result |
	result := Dictionary new.
	tracks
		do: [ :track | 
			track label
				ifNotNil: [ :label | 
					(track magnitudeAtTier: aTier withSpecializationUpgrades: upgrades)
						ifNotNil: [ :value | result at: label put: value ] ] ].
	^ result
]

{ #category : 'accessing' }
CIGadgetVariantDefinition >> name [
	^ name copy
]

{ #category : 'accessing' }
CIGadgetVariantDefinition >> overchargeEffects [
	^ overchargeEffects collect: #copy
]

{ #category : 'accessing' }
CIGadgetVariantDefinition >> trackNamed: label [
	^ tracks
		detect: [ :track | track label = label ]
		ifNone: [ self error: 'Unknown gadget stat: ' , label ]
]

{ #category : 'accessing' }
CIGadgetVariantDefinition >> tracks [
	^ tracks copy
]

{ #category : 'evaluating' }
CIGadgetVariantDefinition >> unresolvedTracksAtTier: aTier [
	^ tracks select: [ :track | (track magnitudeAtTier: aTier) isNil ]
]
