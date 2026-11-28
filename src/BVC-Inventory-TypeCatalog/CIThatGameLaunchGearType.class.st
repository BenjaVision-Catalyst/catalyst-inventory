Class {
	#name : 'CIThatGameLaunchGearType',
	#superclass : 'CIGearType',
	#instVars : [
		'familyId',
		'familyName'
	],
	#category : 'BVC-Inventory-TypeCatalog',
	#package : 'BVC-Inventory-TypeCatalog'
}

{ #category : 'accessing' }
CIThatGameLaunchGearType >> familyId: anIdentifier name: aName [
	familyId := anIdentifier.
	familyName := aName
]

{ #category : 'accessing' }
CIThatGameLaunchGearType >> gearFamilyIdentifier [
	^ familyId copy
]

{ #category : 'spawning' }
CIThatGameLaunchGearType >> inventoryFamilyMetadata [
	^ super inventoryFamilyMetadata
		at: #brandIdentifier put: familyId;
		at: #brandName put: familyName;
		yourself
]
