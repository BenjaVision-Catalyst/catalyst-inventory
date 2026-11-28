Class {
	#name : 'CIWeaponPresentation',
	#superclass : 'Object',
	#instVars : [
		'draft',
		'icon',
		'logo',
		'mesh',
		'materials',
		'handSocket',
		'muzzleSocket',
		'aimAnimation',
		'reloadAnimation',
		'reticle',
		'fireAudio',
		'reloadAudio',
		'muzzleEffect',
		'acfItemClass',
		'ammoClass',
		'fireActionTag',
		'reloadActionTag'
	],
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'accessing' }
CIWeaponPresentation >> acfItemClass [
	^ acfItemClass ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponPresentation >> acfItemClass: value [
	draft ifFalse: [ self error: 'Open a draft before editing UE bindings' ].
	acfItemClass := value ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponPresentation >> aimAnimation [
	^ aimAnimation ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponPresentation >> aimAnimation: value [
	draft ifFalse: [ self error: 'Open a draft before editing UE bindings' ].
	aimAnimation := value ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponPresentation >> ammoClass [
	^ ammoClass ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponPresentation >> ammoClass: value [
	draft ifFalse: [ self error: 'Open a draft before editing UE bindings' ].
	ammoClass := value ifNotNil: #copy
]

{ #category : 'gt' }
CIWeaponPresentation >> asGtMagritteViewModel [
	| model |
	model := super asGtMagritteViewModel.
	draft
		ifTrue: [ model addAction: (Smalltalk at: #GtMagritteBuilderUtility) newSaveButton ].
	^ model
]

{ #category : 'private' }
CIWeaponPresentation >> editCopy [
	draft := true.
	^ self
]

{ #category : 'copying' }
CIWeaponPresentation >> editableCopy [
	^ self copy editCopy
]

{ #category : 'accessing' }
CIWeaponPresentation >> fireActionTag [
	^ fireActionTag ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponPresentation >> fireActionTag: value [
	draft ifFalse: [ self error: 'Open a draft before editing UE bindings' ].
	fireActionTag := value ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponPresentation >> fireAudio [
	^ fireAudio ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponPresentation >> fireAudio: value [
	draft ifFalse: [ self error: 'Open a draft before editing UE bindings' ].
	fireAudio := value ifNotNil: #copy
]

{ #category : 'private' }
CIWeaponPresentation >> freezeCopy [
	draft := false.
	^ self
]

{ #category : 'accessing' }
CIWeaponPresentation >> handSocket [
	^ handSocket ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponPresentation >> handSocket: value [
	draft ifFalse: [ self error: 'Open a draft before editing UE bindings' ].
	handSocket := value ifNotNil: #copy
]

{ #category : 'gt' }
CIWeaponPresentation >> hasMagritteDescription [
	^ true
]

{ #category : 'accessing' }
CIWeaponPresentation >> icon [
	^ icon ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponPresentation >> icon: value [
	draft ifFalse: [ self error: 'Open a draft before editing UE bindings' ].
	icon := value ifNotNil: #copy
]

{ #category : 'copying' }
CIWeaponPresentation >> immutableCopy [
	^ self copy freezeCopy
]

{ #category : 'initialization' }
CIWeaponPresentation >> initialize [
	super initialize.
	draft := true
]

{ #category : 'accessing' }
CIWeaponPresentation >> logo [
	^ logo ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponPresentation >> logo: value [
	draft ifFalse: [ self error: 'Open a draft before editing UE bindings' ].
	logo := value ifNotNil: #copy
]

{ #category : 'descriptions' }
CIWeaponPresentation >> magritteDescription [
	| fields |
	fields := {MAStringDescription new
				accessor: #icon;
				label: 'Inventory icon';
				yourself.
			MAStringDescription new
				accessor: #logo;
				label: 'Manufacturer logo';
				yourself.
			MAStringDescription new
				accessor: #mesh;
				label: 'Weapon mesh';
				yourself.
			MAStringDescription new
				accessor: #materials;
				label: 'Material asset or preset';
				yourself.
			MAStringDescription new
				accessor: #handSocket;
				label: 'Hand socket';
				yourself.
			MAStringDescription new
				accessor: #muzzleSocket;
				label: 'Muzzle socket';
				yourself.
			MAStringDescription new
				accessor: #aimAnimation;
				label: 'Aim animation or stance';
				yourself.
			MAStringDescription new
				accessor: #reloadAnimation;
				label: 'Reload animation';
				yourself.
			MAStringDescription new
				accessor: #reticle;
				label: 'Reticle';
				yourself.
			MAStringDescription new
				accessor: #fireAudio;
				label: 'Fire audio';
				yourself.
			MAStringDescription new
				accessor: #reloadAudio;
				label: 'Reload audio';
				yourself.
			MAStringDescription new
				accessor: #muzzleEffect;
				label: 'Muzzle effect';
				yourself.
			MAStringDescription new
				accessor: #acfItemClass;
				label: 'ACF item class';
				yourself.
			MAStringDescription new
				accessor: #ammoClass;
				label: 'ACF ammunition class';
				yourself.
			MAStringDescription new
				accessor: #fireActionTag;
				label: 'Fire action tag';
				yourself.
			MAStringDescription new
				accessor: #reloadActionTag;
				label: 'Reload action tag';
				yourself}.
	draft ifFalse: [ fields do: #beReadOnly ].
	^ MAContainer withAll: fields
]

{ #category : 'accessing' }
CIWeaponPresentation >> materials [
	^ materials ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponPresentation >> materials: value [
	draft ifFalse: [ self error: 'Open a draft before editing UE bindings' ].
	materials := value ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponPresentation >> mesh [
	^ mesh ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponPresentation >> mesh: value [
	draft ifFalse: [ self error: 'Open a draft before editing UE bindings' ].
	mesh := value ifNotNil: #copy
]

{ #category : 'validation' }
CIWeaponPresentation >> missingBindings [
	^ (self magritteDescription children
		select: [ :field | 
			| value |
			value := self perform: field accessor selector.
			value isNil or: [ value isString not or: [ value trimBoth isEmpty ] ] ])
		collect: #label
]

{ #category : 'accessing' }
CIWeaponPresentation >> muzzleEffect [
	^ muzzleEffect ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponPresentation >> muzzleEffect: value [
	draft ifFalse: [ self error: 'Open a draft before editing UE bindings' ].
	muzzleEffect := value ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponPresentation >> muzzleSocket [
	^ muzzleSocket ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponPresentation >> muzzleSocket: value [
	draft ifFalse: [ self error: 'Open a draft before editing UE bindings' ].
	muzzleSocket := value ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponPresentation >> reloadActionTag [
	^ reloadActionTag ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponPresentation >> reloadActionTag: value [
	draft ifFalse: [ self error: 'Open a draft before editing UE bindings' ].
	reloadActionTag := value ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponPresentation >> reloadAnimation [
	^ reloadAnimation ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponPresentation >> reloadAnimation: value [
	draft ifFalse: [ self error: 'Open a draft before editing UE bindings' ].
	reloadAnimation := value ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponPresentation >> reloadAudio [
	^ reloadAudio ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponPresentation >> reloadAudio: value [
	draft ifFalse: [ self error: 'Open a draft before editing UE bindings' ].
	reloadAudio := value ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponPresentation >> reticle [
	^ reticle ifNotNil: #copy
]

{ #category : 'accessing' }
CIWeaponPresentation >> reticle: value [
	draft ifFalse: [ self error: 'Open a draft before editing UE bindings' ].
	reticle := value ifNotNil: #copy
]
