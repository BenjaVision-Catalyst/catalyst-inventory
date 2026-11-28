"
One workbook-defined modification to using an armor kit. Each effect declares its recipient and any range, magnitude, timing or status restrictions. A nil fraction or duration means the workbook supplies no value for that field.
"
Class {
	#name : 'CISpecializationArmorKitEffect',
	#superclass : 'Object',
	#instVars : [
		'kind',
		'recipient',
		'timing',
		'fraction',
		'durationSeconds',
		'radiusMetres',
		'statuses'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CISpecializationArmorKitEffect class >> fromWorkbookRow: row [
	^ self new initializeFromWorkbookRow: row
]

{ #category : 'testing' }
CISpecializationArmorKitEffect >> appliesToRecipient: recipientKind atDistance: metres [
	^ recipient = recipientKind
		and: [ radiusMetres isNil or: [ metres notNil and: [ metres <= radiusMetres ] ] ]
]

{ #category : 'accessing' }
CISpecializationArmorKitEffect >> durationSeconds [
	^ durationSeconds
]

{ #category : 'accessing' }
CISpecializationArmorKitEffect >> fraction [
	^ fraction
]

{ #category : 'initialization' }
CISpecializationArmorKitEffect >> initializeFromWorkbookRow: row [
	kind := row first.
	recipient := row second.
	timing := row third.
	fraction := row fourth.
	durationSeconds := row fifth.
	radiusMetres := row sixth.
	statuses := row seventh asArray copy
]

{ #category : 'accessing' }
CISpecializationArmorKitEffect >> kind [
	^ kind
]

{ #category : 'accessing' }
CISpecializationArmorKitEffect >> radiusMetres [
	^ radiusMetres
]

{ #category : 'accessing' }
CISpecializationArmorKitEffect >> recipient [
	^ recipient
]

{ #category : 'accessing' }
CISpecializationArmorKitEffect >> statuses [
	^ statuses copy
]

{ #category : 'accessing' }
CISpecializationArmorKitEffect >> timing [
	^ timing
]
