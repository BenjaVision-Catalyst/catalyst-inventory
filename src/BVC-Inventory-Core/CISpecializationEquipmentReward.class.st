"
Equipment described by a specialization perk. The owning perk holds the name, description and original evidence. Weapon references and grenade statuses are recorded only where the workbook supplies them.
"
Class {
	#name : 'CISpecializationEquipmentReward',
	#superclass : 'Object',
	#instVars : [
		'kind',
		'weaponStatistics',
		'namedWeaponReference',
		'appliedStatuses'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CISpecializationEquipmentReward class >> kind: type statistics: statistics namedWeapon: namedWeapon statuses: statuses [
	^ self new
		initializeKind: type
		statistics: statistics
		namedWeapon: namedWeapon
		statuses: statuses
]

{ #category : 'accessing' }
CISpecializationEquipmentReward >> appliedStatuses [
	^ appliedStatuses copy
]

{ #category : 'initialization' }
CISpecializationEquipmentReward >> initializeKind: type statistics: statistics namedWeapon: namedWeapon statuses: statuses [
	kind := type.
	weaponStatistics := statistics.
	namedWeaponReference := namedWeapon.
	appliedStatuses := statuses asArray copy
]

{ #category : 'accessing' }
CISpecializationEquipmentReward >> kind [
	^ kind
]

{ #category : 'accessing' }
CISpecializationEquipmentReward >> namedWeaponReference [
	^ namedWeaponReference
]

{ #category : 'accessing' }
CISpecializationEquipmentReward >> weaponStatistics [
	^ weaponStatistics
]
