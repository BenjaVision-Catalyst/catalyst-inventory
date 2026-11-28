Class {
	#name : 'CIModDefinition',
	#superclass : 'Object',
	#instVars : [
		'id',
		'name',
		'kind',
		'interfaces',
		'models',
		'effects',
		'maximum',
		'tierCaps',
		'evidence',
		'acquisition',
		'workbookMount',
		'modelRestriction'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'instance creation' }
CIModDefinition class >> id: identifier name: label kind: mode interfaces: mounts models: allowedModels effects: modifiers maximum: max tierCaps: maxima evidence: reference acquisition: source [
	^ self new
		initializeId: identifier
		name: label
		kind: mode
		interfaces: mounts
		models: allowedModels
		effects: modifiers
		maximum: max
		tierCaps: maxima
		evidence: reference
		acquisition: source
]

{ #category : 'accessing' }
CIModDefinition >> acquisition [
	^ acquisition copy
]

{ #category : 'accessing' }
CIModDefinition >> effects [
	^ effects collect: #copy
]

{ #category : 'accessing' }
CIModDefinition >> evidence [
	^ evidence copy
]

{ #category : 'compatibility' }
CIModDefinition >> fitsSocket: socket on: itemDefinitionId [
	^ (interfaces includes: socket interface)
		and: [ models isEmpty or: [ models includes: itemDefinitionId ] ]
]

{ #category : 'accessing' }
CIModDefinition >> id [
	^ id copy
]

{ #category : 'initialization' }
CIModDefinition >> initializeId: identifier name: label kind: mode interfaces: mounts models: allowedModels effects: modifiers maximum: max tierCaps: maxima evidence: reference acquisition: source [
	(#(weaponAttachment gearMod factoryAttachment) includes: mode)
		ifFalse: [ self error: 'Unknown mod kind' ].
	id := identifier copy.
	name := label copy.
	kind := mode.
	interfaces := mounts asArray copy.
	models := allowedModels asArray copy.
	effects := modifiers collect: #copy.
	maximum := max.
	tierCaps := maxima copy.
	evidence := reference copy.
	acquisition := source copy.
	^ self
]

{ #category : 'accessing' }
CIModDefinition >> kind [
	^ kind
]

{ #category : 'accessing' }
CIModDefinition >> maximum [
	^ maximum
]

{ #category : 'accessing' }
CIModDefinition >> maximumAtTier: tier [
	^ tierCaps at: tier ifAbsent: [ nil ]
]

{ #category : 'accessing' }
CIModDefinition >> modelRestriction [
	^ modelRestriction ifNotNil: #copy
]

{ #category : 'accessing' }
CIModDefinition >> name [
	^ name copy
]

{ #category : 'validation' }
CIModDefinition >> validateRoll: value tier: tier [
	| limit |
	kind = #gearMod ifFalse: [ self error: 'Expected a rolled gear mod' ].
	(tier isInteger and: [ tier > 0 ])
		ifFalse: [ self error: 'Invalid gear mod tier' ].
	(value isNumber and: [ value >= 0 ])
		ifFalse: [ self error: 'Invalid gear mod roll' ].
	limit := (self maximumAtTier: tier) ifNil: [ maximum ].
	(limit notNil and: [ value > limit ])
		ifTrue: [ self error: 'Gear mod exceeds the documented maximum' ]
]

{ #category : 'accessing' }
CIModDefinition >> workbookMount [
	^ workbookMount ifNotNil: #copy
]

{ #category : 'initialization' }
CIModDefinition >> workbookMount: mountDescription modelRestriction: restrictionDescription [
	workbookMount := mountDescription ifNotEmpty: #copy.
	modelRestriction := restrictionDescription ifNotNil: #copy
]
