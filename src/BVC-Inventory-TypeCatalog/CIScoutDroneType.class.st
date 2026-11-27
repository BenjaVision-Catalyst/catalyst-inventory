Class {
	#name : 'CIScoutDroneType',
	#superclass : 'CIDroneType',
	#category : 'BVC-Inventory-TypeCatalog',
	#package : 'BVC-Inventory-TypeCatalog'
}

{ #category : 'accessing' }
CIScoutDroneType >> baseStats [
	^ Dictionary
		newFrom: {#cooldownSeconds -> 20.
				#durationSeconds -> 30.
				#scanRadiusMetres -> 25}
]

{ #category : 'accessing' }
CIScoutDroneType >> statsAtUtilityTier: aTier [
	| stats |
	stats := super statsAtUtilityTier: aTier.
	stats at: #scanRadiusMetres put: (stats at: #scanRadiusMetres) + (5 * aTier).
	^ stats
]
