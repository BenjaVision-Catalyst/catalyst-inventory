Class {
	#name : 'CIWorkbookNamedWeaponType',
	#superclass : 'CIWeaponType',
	#instVars : [
		'statisticsReference',
		'namedReference'
	],
	#category : 'BVC-Inventory-TypeCatalog',
	#package : 'BVC-Inventory-TypeCatalog'
}

{ #category : 'instance creation' }
CIWorkbookNamedWeaponType class >> statistics: stats named: named [
	| slot weapon |
	slot := stats weaponClass = #pistol
			ifTrue: [ 'LeftHandWeapon' ]
			ifFalse: [ 'RangedWeapon' ].
	weapon := self
			id: named itemDefinitionIdentifier
			name: named name
			slot: slot
			core: {{'Damage per hit'.
						(stats fieldAt: #level40Damage) asNumber}.
					{'Fire rate'.
						(stats fieldAt: #rpm) asNumber asInteger asString , ' RPM'}.
					{'Magazine'.
						(stats fieldAt: #baseMagazine) asNumber asInteger asString , ' rounds'}.
					{'Optimal range'.
						(stats fieldAt: #optimalRangeMetres) asNumber}.
					{'Reload time'.
						(stats fieldAt: #emptyReloadSeconds) , ' s'}}
			handling: #()
			sockets: #().
	^ weapon initializeStatistics: stats named: named
]

{ #category : 'initialization' }
CIWorkbookNamedWeaponType >> initializeStatistics: stats named: named [
	statisticsReference := stats.
	namedReference := named.
	self
		inspectorIdentity: (Dictionary new
				at: 'inspectorCategory' put: stats weaponClass asString;
				yourself).
	^ self
]

{ #category : 'accessing' }
CIWorkbookNamedWeaponType >> namedReference [
	^ namedReference
]

{ #category : 'accessing' }
CIWorkbookNamedWeaponType >> statisticsReference [
	^ statisticsReference
]
