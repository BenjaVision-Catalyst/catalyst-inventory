Class {
	#name : 'BVCGearModifier',
	#superclass : 'Object',
	#instVars : [
		'stat',
		'operation',
		'magnitude',
		'targetClass',
		'duration'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'accessing' }
BVCGearModifier class >> stat: aStat operation: anOperation magnitude: aMagnitude targetClass: aTarget duration: aDuration [
	^ self new
		initializeStat: aStat
		operation: anOperation
		magnitude: aMagnitude
		targetClass: aTarget
		duration: aDuration
]

{ #category : 'accessing' }
BVCGearModifier >> appliesTo: aTargetClass [
	^ targetClass isNil or: [ targetClass = aTargetClass ]
]

{ #category : 'accessing' }
BVCGearModifier >> duration [
	^ duration
]

{ #category : 'accessing' }
BVCGearModifier >> initializeStat: aStat operation: anOperation magnitude: aMagnitude targetClass: aTarget duration: aDuration [
	stat := aStat.
	operation := anOperation.
	magnitude := aMagnitude.
	targetClass := aTarget.
	duration := aDuration
]

{ #category : 'accessing' }
BVCGearModifier >> magnitude [
	^ magnitude
]

{ #category : 'accessing' }
BVCGearModifier >> operation [
	^ operation
]

{ #category : 'accessing' }
BVCGearModifier >> stat [
	^ stat
]

{ #category : 'accessing' }
BVCGearModifier >> targetClass [
	^ targetClass
]
