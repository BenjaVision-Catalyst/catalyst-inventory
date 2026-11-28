"
A timed reduction to a target stat. The combat event supplies the affected target.
"
Class {
	#name : 'CICombatStatReduction',
	#superclass : 'Object',
	#instVars : [
		'stat',
		'fraction',
		'durationSeconds'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CICombatStatReduction class >> stat: statName fraction: reduction durationSeconds: seconds [
	^ self new
		initializeStat: statName
		fraction: reduction
		durationSeconds: seconds
]

{ #category : 'accessing' }
CICombatStatReduction >> durationSeconds [
	^ durationSeconds
]

{ #category : 'accessing' }
CICombatStatReduction >> fraction [
	^ fraction
]

{ #category : 'initialization' }
CICombatStatReduction >> initializeStat: statName fraction: reduction durationSeconds: seconds [
	stat := statName.
	fraction := reduction.
	durationSeconds := seconds
]

{ #category : 'accessing' }
CICombatStatReduction >> stat [
	^ stat
]
