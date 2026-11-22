Class {
	#name : 'CIGearModifier',
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
CIGearModifier class >> stat: aStat operation: anOperation magnitude: aMagnitude targetClass: aTarget duration: aDuration [
	^ self new
		initializeStat: aStat
		operation: anOperation
		magnitude: aMagnitude
		targetClass: aTarget
		duration: aDuration
]

{ #category : 'accessing' }
CIGearModifier >> appliesTo: aTargetClass [
	^ targetClass isNil or: [ targetClass = aTargetClass ]
]

{ #category : 'accessing' }
CIGearModifier >> duration [
	^ duration
]

{ #category : 'accessing' }
CIGearModifier >> initializeStat: aStat operation: anOperation magnitude: aMagnitude targetClass: aTarget duration: aDuration [
	stat := aStat.
	operation := anOperation.
	magnitude := aMagnitude.
	targetClass := aTarget.
	duration := aDuration
]

{ #category : 'accessing' }
CIGearModifier >> magnitude [
	^ magnitude
]

{ #category : 'accessing' }
CIGearModifier >> operation [
	^ operation
]

{ #category : 'accessing' }
CIGearModifier >> stat [
	^ stat
]

{ #category : 'accessing' }
CIGearModifier >> targetClass [
	^ targetClass
]
