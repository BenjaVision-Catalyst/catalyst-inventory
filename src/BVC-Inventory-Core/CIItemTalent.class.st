Class {
	#name : 'CIItemTalent',
	#superclass : 'Object',
	#instVars : [
		'id',
		'displayName',
		'eligibility',
		'parameters',
		'comment',
		'modeProfiles'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIItemTalent class >> id: anId name: aName eligibility: aKind parameters: aDictionary [
	^ self new
		initializeId: anId
		name: aName
		eligibility: aKind
		parameters: aDictionary
]

{ #category : 'instance creation' }
CIItemTalent class >> id: anId name: aName eligibility: aKind parameters: aDictionary comment: aString [
	^ (self
		id: anId
		name: aName
		eligibility: aKind
		parameters: aDictionary)
		initializeComment: aString;
		yourself
]

{ #category : 'accessing' }
CIItemTalent >> comment [
	^ comment ifNil: [ '' ] ifNotNil: [ comment copy ]
]

{ #category : 'accessing' }
CIItemTalent >> displayName [
	^ displayName copy
]

{ #category : 'accessing' }
CIItemTalent >> eligibility [
	^ eligibility
]

{ #category : 'accessing' }
CIItemTalent >> eligibilityText [
	^ self eligibility asString
]

{ #category : 'gt' }
CIItemTalent >> gtParametersFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Parameters';
		priority: 20;
		items: [ self parameters associations sorted: [ :left :right | left key < right key ] ];
		column: 'Parameter' text: #key;
		column: 'Value' text: #value;
		send: #value
]

{ #category : 'gt' }
CIItemTalent >> hasMagritteDescription [
	^ true
]

{ #category : 'accessing' }
CIItemTalent >> id [
	^ id copy
]

{ #category : 'initialization' }
CIItemTalent >> initializeComment: aString [
	comment := aString copy
]

{ #category : 'initialization' }
CIItemTalent >> initializeId: anId name: aName eligibility: aKind parameters: aDictionary [
	(anId isString and: [ anId notEmpty ])
		ifFalse: [ self error: 'Talent ID required' ].
	(#(weapon Chest Backpack set) includes: aKind)
		ifFalse: [ self error: 'Invalid talent eligibility' ].
	id := anId copy.
	displayName := aName copy.
	eligibility := aKind.
	parameters := aDictionary copy.
	^ self
]

{ #category : 'descriptions' }
CIItemTalent >> magritteDescription [
	^ MAContainer
		withAll: {MAStringDescription new
					accessor: #id;
					label: 'Talent ID';
					beReadOnly;
					yourself.
				MAStringDescription new
					accessor: #displayName;
					label: 'Name';
					beReadOnly;
					yourself.
				MAStringDescription new
					accessor: #eligibilityText;
					label: 'Eligibility';
					beReadOnly;
					yourself.
				MAMemoDescription new
					accessor: #comment;
					label: 'Effect';
					beReadOnly;
					yourself}
]

{ #category : 'initialization' }
CIItemTalent >> modeProfile: profile for: mode [
	modeProfiles ifNil: [ modeProfiles := Dictionary new ].
	modeProfiles at: mode put: profile
]

{ #category : 'accessing' }
CIItemTalent >> modeProfileFor: mode [
	modeProfiles ifNil: [ ^ nil ].
	^ modeProfiles at: mode ifAbsent: [ nil ]
]

{ #category : 'accessing' }
CIItemTalent >> parameters [
	^ parameters copy
]

{ #category : 'accessing' }
CIItemTalent >> parametersForMode: mode [
	| profile resolved |
	mode = #pve ifTrue: [ ^ self parameters ].
	profile := self modeProfileFor: mode.
	(profile notNil and: [ profile isResolved ]) ifFalse: [ ^ nil ].
	resolved := self parameters.
	profile parameters
		keysAndValuesDo: [ :key :value | resolved at: key put: value ].
	^ resolved
]

{ #category : 'copying' }
CIItemTalent >> postCopy [
	super postCopy.
	modeProfiles := modeProfiles ifNotNil: #copy
]
