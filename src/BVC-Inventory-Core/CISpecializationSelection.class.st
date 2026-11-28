Class {
	#name : 'CISpecializationSelection',
	#superclass : 'Object',
	#instVars : [
		'specializationName',
		'perkIdentifiers'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CISpecializationSelection class >> specialization: label perks: identifiers [
	^ self new initializeSpecialization: label perks: identifiers
]

{ #category : 'initialization' }
CISpecializationSelection >> initializeSpecialization: label perks: identifiers [
	(label isString
		and: [ label notEmpty
				and: [ identifiers allSatisfy: [ :id | id isString and: [ id notEmpty ] ] ] ])
		ifFalse: [ self error: 'Invalid specialization selection' ].
	specializationName := label copy.
	perkIdentifiers := (identifiers asSet sorted collect: #copy) asArray.
	^ self
]

{ #category : 'accessing' }
CISpecializationSelection >> perkIdentifiers [
	^ perkIdentifiers collect: #copy
]

{ #category : 'resolving' }
CISpecializationSelection >> resolveIn: catalogue [
	^ catalogue
		specializationLoadoutNamed: specializationName
		selected: perkIdentifiers
]

{ #category : 'accessing' }
CISpecializationSelection >> specializationName [
	^ specializationName copy
]
