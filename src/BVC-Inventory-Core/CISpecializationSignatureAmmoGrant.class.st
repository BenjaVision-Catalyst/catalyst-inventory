"
Signature ammo bar points awarded by selected specialization perks for a resolved combat event. Group member points apply to each eligible recipient. Supply Line awards ordinary ammo and uses a separate model.
"
Class {
	#name : 'CISpecializationSignatureAmmoGrant',
	#superclass : 'Object',
	#instVars : [
		'personalPoints',
		'groupMemberPoints'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CISpecializationSignatureAmmoGrant class >> personalPoints: personal groupMemberPoints: group [
	^ self new initializePersonalPoints: personal groupMemberPoints: group
]

{ #category : 'accessing' }
CISpecializationSignatureAmmoGrant >> groupMemberPoints [
	^ groupMemberPoints
]

{ #category : 'initialization' }
CISpecializationSignatureAmmoGrant >> initializePersonalPoints: personal groupMemberPoints: group [
	personalPoints := personal.
	groupMemberPoints := group
]

{ #category : 'accessing' }
CISpecializationSignatureAmmoGrant >> personalPoints [
	^ personalPoints
]
