Class {
	#name : 'CIScannerPulseType',
	#superclass : 'CIPulseType',
	#category : 'BVC-Inventory-TypeCatalog',
	#package : 'BVC-Inventory-TypeCatalog'
}

{ #category : 'accessing' }
CIScannerPulseType >> activationLabel [
	^ 'Scan'
]

{ #category : 'accessing' }
CIScannerPulseType >> baseStats [
	^ Dictionary
		newFrom: {#cooldownSeconds -> 20.
				#revealSeconds -> 8.
				#scanRadiusMetres -> 20}
]

{ #category : 'accessing' }
CIScannerPulseType >> statsAtUtilityTier: aTier [
	| stats |
	stats := super statsAtUtilityTier: aTier.
	stats
		at: #revealSeconds
		put: (stats at: #revealSeconds) * (1 + (3 / 20 * aTier)).
	^ stats
]
