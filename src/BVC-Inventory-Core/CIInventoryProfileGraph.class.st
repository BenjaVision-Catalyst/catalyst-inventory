Class {
	#name : 'CIInventoryProfileGraph',
	#superclass : 'Object',
	#category : 'BVC-Inventory-Core',
	#package : 'BVC-Inventory-Core'
}

{ #category : 'projection' }
CIInventoryProfileGraph class >> addInspectorIdentity: fields to: card descriptions: descriptions [
	| equipment children |
	fields ifEmpty: [ ^ self ].
	equipment := descriptions detect: [ :node | (node at: 'id') = 'equipmentCard' ].
	children := equipment at: 'children'.
	fields keys sorted
		do: [ :key |
			| amount description |
			amount := fields at: key.
			(children includes: key)
				ifFalse: [ description := amount isInteger
							ifTrue: [ MANumberDescription new ]
							ifFalse: [ MAStringDescription new ].
					descriptions
						add: (self
								field: key
								from: (description
										label: key;
										yourself)).
					children := children copyWith: key ].
			(card at: 'values') at: key put: (self atomFor: amount) ].
	equipment at: 'children' put: children
]

{ #category : 'projection' }
CIInventoryProfileGraph class >> addInspectorRows: rows in: id descriptions: descriptions objects: objects [
	| values fields |
	values := Dictionary new.
	fields := rows
			withIndexCollect: [ :row :index |
				| fieldId description field atom |
				fieldId := id , ':' , index asString.
				description := row second isSymbol
						ifTrue: [ MASymbolDescription new ]
						ifFalse: [ row second isInteger
								ifTrue: [ MANumberDescription new ]
								ifFalse: [ MAStringDescription new ] ].
				description
					label: row first;
					priority: index.
				field := self field: fieldId from: description.
				field at: 'accessor' put: self inspectorAccessor.
				row size = 3
					ifTrue: [ (field at: 'properties')
							at: 'metadata:ciDistanceMetres'
							put: (self atomFor: row third) ].
				row size = 5
					ifTrue: [ (field at: 'properties')
							at: 'metadata:ciAttributeType'
							put: (self atomFor: row fifth) ].
				(row size >= 4 and: [ row fourth notNil and: [ row fourth > 0 ] ])
					ifTrue: [ (field at: 'properties')
							at: 'metadata:ciMeterMillionths'
							put: (self atomFor: (row third / row fourth * 1000000) rounded) ].
				descriptions add: field.
				atom := row second isSymbol
						ifTrue: [ self atom: 'symbol' value: row second asString ]
						ifFalse: [ self atomFor: row second ].
				values at: fieldId put: atom.
				fieldId ].
	objects
		add: (self
				object: id
				description: id
				values: values).
	^ fields asArray
]

{ #category : 'projection' }
CIInventoryProfileGraph class >> addItemInspector: sections forCard: card descriptions: descriptions objects: objects [
	| id children values falloff |
	id := 'item:' , (((card at: 'values') at: 'itemIdentifier') at: 'value')
			, ':inspector'.
	children := OrderedCollection new.
	values := Dictionary new.
	falloff := ((card at: 'values')
			at: 'definitionIdentifier'
			ifAbsent: [ Dictionary new ]) at: 'value' ifAbsent: [ '' ].
	falloff := (falloff beginsWith: 'weapon.launch.')
			ifTrue: [ sections detect: [ :each | each first = 'falloff' ] ifNone: [ nil ] ]
			ifFalse: [ nil ].
	sections
		withIndexDo: [ :section :index |
			| sectionId relation relationId rows fieldIds |
			rows := section third.
			(rows notEmpty and: [ falloff isNil or: [ section first ~= 'falloff' ] ])
				ifTrue: [ sectionId := id , ':' , section first.
					relationId := sectionId , ':section'.
					relation := self
							relation: relationId
							from: (MAToOneRelationDescription new
									label: section second;
									priority: index * 10;
									yourself)
							to: sectionId.
					(relation at: 'properties')
						at: 'metadata:ciCard'
						put: (self atom: 'string' value: section first).
					(falloff notNil
						and: [ falloff third notEmpty and: [ section first = 'stats' ] ])
						ifTrue: [ (relation at: 'properties')
								at: 'metadata:ciFalloff'
								put: (self
										atom: 'string'
										value: (','
												join: (falloff third
														collect: [ :point | point third asString , ':' , point second asString ]))) ].
					relation at: 'accessor' put: self inspectorAccessor.
					descriptions add: relation.
					children add: relationId.
					values at: relationId put: (self atom: 'reference' value: sectionId).
					fieldIds := self
							addInspectorRows: rows
							in: sectionId
							descriptions: descriptions
							objects: objects.
					descriptions
						add: (self
								container: sectionId
								children: fieldIds
								properties: Dictionary new) ] ].
	descriptions
		add: (self
				container: id
				children: children asArray
				properties: Dictionary new).
	objects
		add: (self
				object: id
				description: id
				values: values).
	(card at: 'values') at: 'inspector' put: (self atom: 'reference' value: id)
]

{ #category : 'projection' }
CIInventoryProfileGraph class >> addModStorageAllowanceFieldTo: descriptionId in: descriptions [
	| container |
	container := descriptions detect: [ :node | (node at: 'id') = descriptionId ].
	container
		at: 'children'
		put: ((container at: 'children') copyWith: 'modStorageAllowance')
]

{ #category : 'projection' }
CIInventoryProfileGraph class >> addModStorageTo: graph for: identity count: count allowance: allowance [
	| objects inventory storage descriptions |
	objects := graph at: 'objects'.
	inventory := objects
			detect: [ :row | (row at: 'id') = (identity , ':inventory') ].
	storage := objects
			detect: [ :row | (row at: 'id') = (identity , ':inventory:gear:equippedGear:ModStorage') ].
	(inventory at: 'values')
		at: 'modStorageAllowance'
		put: (self atomFor: allowance).
	(storage at: 'values')
		at: 'inventoryTypeCount' put: (self atomFor: count);
		at: 'modStorageAllowance' put: (self atomFor: allowance).
	descriptions := graph at: 'descriptions'.
	self addModStorageAllowanceFieldTo: 'inventoryModel' in: descriptions.
	self addModStorageAllowanceFieldTo: 'equipmentCard' in: descriptions.
	graph
		at: 'descriptions'
		put: (descriptions
				copyWith: (self
						field: 'modStorageAllowance'
						from: (MANumberDescription new
								label: 'Mod allowance';
								min: 0;
								yourself)))
]

{ #category : 'projection' }
CIInventoryProfileGraph class >> addRecord: id kind: kind values: values to: objects [
	| encoded |
	encoded := Dictionary new.
	values
		keysAndValuesDo: [ :key :value |
			key = 'modSlots'
				ifTrue: [ | refs |
					refs := value
							withIndexCollect: [ :mod :index |
								| modId fields |
								modId := id , ':mod:' , index asString.
								fields := Dictionary new
										at: 'slotIdentifier' put: (self atomFor: mod slotIdentifier);
										yourself.
								mod equippedModIdentifier
									ifNotNil: [ :name | fields at: 'equippedModIdentifier' put: (self atomFor: name) ].
								objects
									add: (self
											object: modId
											description: 'tileMod'
											values: fields).
								self atom: 'reference' value: modId ].
					encoded at: key put: (self atom: 'array' value: refs asArray copy) ]
				ifFalse: [ encoded at: key put: (self atomFor: value) ] ].
	objects
		add: (self
				object: id
				description: kind
				values: encoded)
]

{ #category : 'projection' }
CIInventoryProfileGraph class >> addRecordSchema: kind to: descriptions known: known [
	| fields |
	(known includes: kind) ifTrue: [ ^ self ].
	known add: kind.
	fields := self recordFieldsFor: kind.
	descriptions
		add: (self
				container: kind
				children: (fields collect: #asString)
				properties: Dictionary new).
	fields
		do: [ :selector |
			| id description field |
			id := selector asString.
			(known includes: id)
				ifFalse: [ known add: id.
					description := self descriptionForField: selector.
					field := self field: id from: description.
					(description isKindOf: MAToManyScalarRelationDescription)
						ifTrue: [ field
								at: 'reference' put: 'tileText';
								at: 'classes' put: (Array with: 'String').
							(known includes: 'tileText')
								ifFalse: [ known add: 'tileText'.
									descriptions
										add: (self field: 'tileText' from: MAStringDescription new) ] ].
					selector = #modSlots
						ifTrue: [ field
								at: 'reference' put: 'tileMod';
								at: 'classes' put: (Array with: 'MAAdaptiveModel').
							descriptions
								add: (self
										container: 'tileMod'
										children: #('slotIdentifier' 'equippedModIdentifier') copy
										properties: Dictionary new);
								add: (self field: 'slotIdentifier' from: (MAStringDescription new label: 'Mod slot'));
								add: (self
										field: 'equippedModIdentifier'
										from: (MAStringDescription new label: 'Equipped mod')) ].
					descriptions add: field ] ]
]

{ #category : 'projection' }
CIInventoryProfileGraph class >> atom: type value: value [
	^ Dictionary new
		at: 'type' put: type;
		at: 'value' put: value;
		yourself
]

{ #category : 'projection' }
CIInventoryProfileGraph class >> atomFor: value [
	value isInteger ifTrue: [ ^ self atom: 'integer' value: value asString ].
	(value == true or: [ value == false ])
		ifTrue: [ ^ self atom: 'boolean' value: value ].
	value isArray
		ifTrue: [ ^ self atom: 'array' value: (value collect: [ :each | self atomFor: each ]) ].
	^ self atom: 'string' value: value asString
]

{ #category : 'projection' }
CIInventoryProfileGraph class >> container: id children: children properties: properties [
	^ (self
		node: id
		class: 'MAPriorityContainer'
		properties: properties)
		at: 'children' put: children;
		yourself
]

{ #category : 'projection' }
CIInventoryProfileGraph class >> descriptionForField: field [
	| accessor label |
	accessor := field asSymbol.
	label := field asString.
	(#(tierId inventoryTypeCount expertiseLevel count) includes: accessor)
		ifTrue: [ ^ MANumberDescription new
				accessor: accessor;
				label: label;
				yourself ].
	accessor = #isEmptySlot
		ifTrue: [ ^ MABooleanDescription new
				accessor: accessor;
				label: 'Empty slot';
				yourself ].
	(#(offensiveAttributes defensiveAttributes utilityAttributes)
		includes: accessor)
		ifTrue: [ ^ MAToManyScalarRelationDescription new
				accessor: accessor;
				label: label;
				classes: {String};
				yourself ].
	accessor = #modSlots
		ifTrue: [ ^ MAToManyRelationDescription new
				accessor: accessor;
				label: 'Mod slots';
				yourself ].
	^ MAStringDescription new
		accessor: accessor;
		label: label;
		yourself
]

{ #category : 'projection' }
CIInventoryProfileGraph class >> encodeReply: graph [
	| bytes result stream size |
	bytes := (STONJSON toString: graph) utf8Encoded.
	size := bytes size.
	size <= 4080 ifTrue: [ ^ bytes ].
	size > 65536 ifTrue: [ ^ nil ].
	result := ByteArray new writeStream.
	result nextPutAll: 'ZLIB' utf8Encoded.
	0 to: 3 do: [ :i | result nextPut: ((size bitShift: i * -8) bitAnd: 255) ].
	stream := ZLibWriteStream on: result.
	stream nextPutAll: bytes.
	stream close.
	result position > 4080 ifTrue: [ ^ nil ].
	^ result contents
]

{ #category : 'projection' }
CIInventoryProfileGraph class >> equipmentCardsFor: slots kind: kind owned: items [
	^ slots
		collect: [ :spec |
			| slot found |
			slot := spec first.
			found := items
					detect: [ :each | each equippedSlotIdentifier = slot ]
					ifNone: [ nil ].
			found
				ifNil: [ Dictionary new
						at: 'itemIdentifier' put: slot;
						at: 'definitionIdentifier' put: slot;
						at: 'displayName' put: spec second;
						at: 'presentationKind' put: kind;
						at: 'isEmptySlot' put: true;
						yourself ]
				ifNotNil: [ self
						valuesFor: found
						fields: (self recordFieldsFor: 'equipmentCard') ] ]
]

{ #category : 'projection' }
CIInventoryProfileGraph class >> field: id from: description [
	| properties |
	properties := Dictionary new
			at: 'label' put: (self atom: 'string' value: description label);
			at: 'priority'
				put: (self atom: 'integer' value: description priority asString);
			at: 'readOnly' put: (self atom: 'boolean' value: true);
			yourself.
	description group
		ifNotNil: [ :group | properties at: 'group' put: (self atom: 'string' value: group asString) ].
	description icon
		ifNotNil: [ :icon | properties at: 'metadata:cfIcon' put: (self atom: 'symbol' value: icon asString) ].
	^ (self
		node: id
		class: description class name asString
		properties: properties)
		at: 'accessor'
			put: (Dictionary new
					at: 'class' put: 'MADictionaryAccessor';
					at: 'key' put: id;
					yourself);
		yourself
]

{ #category : 'projection' }
CIInventoryProfileGraph class >> forVerifiedUser: identity rows: items [
	^ self
		forVerifiedUser: identity
		rows: items
		savedSets: Dictionary new
]

{ #category : 'projection' }
CIInventoryProfileGraph class >> forVerifiedUser: identity rows: items savedSets: savedSets [
	| sections descriptions objects inventoryId profileId profileValues known |
	sections := self inventoryDescription children asArray.
	inventoryId := identity , ':inventory'.
	profileId := identity , ':profile'.
	descriptions := OrderedCollection new.
	objects := OrderedCollection new.
	profileValues := Dictionary new.
	known := Set new.
	descriptions
		add: (self
				container: 'user'
				children: #('profile') copy
				properties: Dictionary new);
		add: (self
				relation: 'profile'
				from: (MAToOneRelationDescription new label: 'Game profile')
				to: 'userProfile');
		add: (self
				container: 'userProfile'
				children: #('inventory') copy
				properties: Dictionary new);
		add: (self
				relation: 'inventory'
				from: (MAToOneRelationDescription new label: 'Inventory')
				to: 'inventoryModel');
		add: (self
				container: 'inventoryModel'
				children: (sections collect: [ :each | each accessor readSelector asString ])
				properties: Dictionary new).
	sections
		do: [ :section |
			| key target sectionId properties contents groups |
			key := section accessor readSelector asString.
			target := key , 'Section'.
			sectionId := inventoryId , ':' , key.
			groups := self groupsFor: key owned: items.
			(#('gear' 'apparel') includes: key)
				ifTrue: [ groups := groups
							copyWith: {key , 'SavedSets'.
									'Saved sets'.
									'savedSet'.
									(savedSets at: key ifAbsent: [ #() ])
										collect: [ :entry | self savedSetValuesFor: entry ]} ].
			properties := Dictionary new.
			key = 'stats'
				ifFalse: [ properties at: 'metadata:ciGrid' put: (self atom: 'symbol' value: key) ].
			descriptions
				add: (self
						relation: key
						from: section
						to: target);
				add: (self
						container: target
						children: (groups collect: #first) asArray copy
						properties: properties).
			contents := Dictionary new.
			groups
				withIndexDo: [ :group :priority |
					| groupId rowKind groupDescription relation refs |
					groupId := group first.
					rowKind := group third.
					groupDescription := MAToManyRelationDescription new
							label: group second;
							group: group second;
							priority: priority * 10;
							yourself.
					relation := self
							relation: groupId
							from: groupDescription
							to: rowKind.
					rowKind = 'savedSet'
						ifTrue: [ (relation at: 'properties')
								at: 'visible'
								put: (self atom: 'boolean' value: false) ].
					descriptions add: relation.
					self
						addRecordSchema: rowKind
						to: descriptions
						known: known.
					refs := group fourth
							withIndexCollect: [ :values :index |
								| id |
								id := sectionId , ':' , groupId , ':'
										, (values
												at: 'itemIdentifier'
												ifAbsent: [ values at: 'categoryIdentifier' ifAbsent: [ index asString ] ]).
								self
									addRecord: id
									kind: rowKind
									values: values
									to: objects.
								self atom: 'reference' value: id ].
					contents at: groupId put: (self atom: 'array' value: refs asArray copy) ].
			profileValues at: key put: (self atom: 'reference' value: sectionId).
			objects
				add: (self
						object: sectionId
						description: target
						values: contents) ].
	objects
		add: (self
				object: identity
				description: 'user'
				values: (Dictionary new
						at: 'profile' put: (self atom: 'reference' value: profileId);
						yourself));
		add: (self
				object: profileId
				description: 'userProfile'
				values: (Dictionary new
						at: 'inventory' put: (self atom: 'reference' value: inventoryId);
						yourself));
		add: (self
				object: inventoryId
				description: 'inventoryModel'
				values: profileValues).
	^ Dictionary new
		at: 'format' put: 'magritte.graph/3';
		at: 'root' put: 'user';
		at: 'descriptions' put: descriptions asArray;
		at: 'objects' put: objects asArray;
		yourself
]

{ #category : 'projection' }
CIInventoryProfileGraph class >> forVerifiedUser: identity rows: items savedSets: savedSets catalog: catalog [
	^ self
		forVerifiedUser: identity
		rows: items
		savedSets: savedSets
		catalog: catalog
		modStorageAllowance: CIInventoryReadStore defaultModStorageAllowance
]

{ #category : 'projection' }
CIInventoryProfileGraph class >> forVerifiedUser: identity rows: items savedSets: savedSets catalog: catalog modStorageAllowance: allowance [
	| graph descriptions objects cards itemsById tier visibleItems |
	visibleItems := items first: (items size min: 32).
	(items allButFirst: visibleItems size)
		do: [ :item | 
			((item isKindOf: CIInventoryEquipmentSummary)
				and: [ item equippedSlotIdentifier notNil ])
				ifTrue: [ visibleItems := visibleItems copyWith: item ] ].
	graph := self
			forVerifiedUser: identity
			rows: visibleItems
			savedSets: savedSets.
	self
		addModStorageTo: graph
		for: identity
		count: (items count: [ :row | row isKindOf: CIInventoryModItemSummary ])
		allowance: allowance.
	descriptions := (graph at: 'descriptions') asOrderedCollection.
	objects := (graph at: 'objects') asOrderedCollection.
	cards := objects
			select: [ :record | (record at: 'description') = 'equipmentCard' ].
	itemsById := Dictionary new.
	items do: [ :item | itemsById at: item itemIdentifier put: item ].
	tier := self utilityTierForRows: items.
	cards
		do: [ :card | 
			| values item type sections |
			values := card at: 'values'.
			(values includesKey: 'isEmptySlot')
				ifFalse: [ item := itemsById at: ((values at: 'itemIdentifier') at: 'value').
					type := catalog typeAt: item definitionIdentifier ifAbsent: [ nil ].
					type
						ifNotNil: [ self
								addInspectorIdentity: (type inspectorIdentityFor: item)
								to: card
								descriptions: descriptions.
							sections := self
									inspectorSectionsFor: type
									item: item
									utilityTier: tier
									catalog: catalog.
							sections
								ifNotEmpty: [ self
										addItemInspector: sections
										forCard: card
										descriptions: descriptions
										objects: objects ] ] ] ].
	objects size = (graph at: 'objects') size
		ifTrue: [ graph at: 'descriptions' put: descriptions asArray.
			^ graph ].
	descriptions
		detect: [ :each | (each at: 'id') = 'equipmentCard' ]
		ifFound: [ :description | 
			description
				at: 'children'
				put: ((description at: 'children') copyWith: 'inspector') ].
	descriptions
		add: (self
				relation: 'inspector'
				from: (MAToOneRelationDescription new label: 'Inspector')
				to: 'itemInspector').
	descriptions
		add: (self
				container: 'itemInspector'
				children: #()
				properties: Dictionary new).
	graph at: 'descriptions' put: descriptions asArray.
	graph at: 'objects' put: objects asArray.
	^ graph
]

{ #category : 'projection' }
CIInventoryProfileGraph class >> groupsFor: section owned: items [
	| gear |
	section = 'apparel'
		ifTrue: [ ^ #(#('clothing' 'Clothing' #('Hat' 'Mask' 'Neck' 'Shirt' 'Pants' 'Shoes')) #('accessories' 'Accessories' #('Glasses' 'BackpackTrophy' 'Patches' 'Watch' 'Emotes' 'Uniforms')))
				collect: [ :group |
					{group first.
						group second.
						'apparelSlot'.
						group third
							collect: [ :category |
								| count slot equipped |
								count := category = 'Shoes'
										ifTrue: [ items count: [ :item | item definitionIdentifier = 'extraGripShoes' ] ]
										ifFalse: [ 0 ].
								equipped := items
										detect: [ :item |
											(item isKindOf: CIInventoryApparelItemSummary)
												and: [ item equippedApparelSlotIdentifier = category ] ]
										ifNone: [ nil ].
								slot := CIInventoryApparelSlotSummary
										category: category
										tier: 1
										inventoryCount: count
										equippedDefinition: (equipped
												ifNotNil: [ equipped definitionIdentifier ]).
								self valuesFor: slot fields: (self recordFieldsFor: 'apparelSlot') ]} ] ].
	section = 'resources'
		ifTrue: [ ^ self resourceGroups
				collect: [ :group |
					{group first.
						group second.
						'resourceStack'.
						(items
							select: [ :item |
								(item isKindOf: CIInventoryResourceStackSummary)
									and: [ group third includes: item definitionIdentifier ] ])
							collect: [ :item | self valuesFor: item fields: (self recordFieldsFor: 'resourceStack') ]} ] ].
	section = 'gear' ifFalse: [ ^ #() ].
	gear := items select: [ :item | item isKindOf: CIInventoryEquipmentSummary ].
	^ {{'toolsWeapons'.
			'Tools / Weapons'.
			'equipmentCard'.
			self
				equipmentCardsFor: #(#('MeleeWeapon' 'Melee weapon') #('LeftHandWeapon' 'Off-hand weapon') #('RangedWeapon' 'Ranged weapon'))
				kind: 'weapon'
				owned: gear}.
		{'equippedGear'.
			'Gear'.
			'equipmentCard'.
			self
				equipmentCardsFor: #(#('Mask' 'Mask') #('Backpack' 'Backpack') #('Chest' 'Vest') #('Gloves' 'Gloves') #('KneePads' 'Knee pads') #('ModStorage' 'Mod storage'))
				kind: 'gear'
				owned: gear}.
		{'gadgets'.
			'Gadgets'.
			'equipmentCard'.
			self
				equipmentCardsFor: #(#('GadgetLeft' 'Left gadget') #('GadgetRight' 'Right gadget'))
				kind: 'gadget'
				owned: gear}}
]

{ #category : 'projection' }
CIInventoryProfileGraph class >> inspectorAccessor [
	"Adaptive inspector rows resolve their values by description ID."

	^ Dictionary new
		at: 'class' put: 'MANullAccessor';
		at: 'uuid'
			put: (Dictionary new
					at: 'type' put: 'nil';
					yourself);
		yourself
]

{ #category : 'projection' }
CIInventoryProfileGraph class >> inspectorSectionsFor: type item: item utilityTier: tier catalog: catalog [
	| sections talent |
	sections := type inspectorSectionsAtUtilityTier: tier item: item.
	(item respondsTo: #talentIdentifier) ifFalse: [ ^ sections ].
	item talentIdentifier ifNil: [ ^ sections ].
	talent := catalog talentAt: item talentIdentifier ifAbsent: [ ^ sections ].
	talent comment ifEmpty: [ ^ sections ].
	^ sections
		copyWith: {'talent'.
				'Talent'.
				{{'Name'.
						talent displayName}.
					{'Comment'.
						talent comment}}}
]

{ #category : 'projection' }
CIInventoryProfileGraph class >> inventoryDescription [
	| description |
	description := MAPriorityContainer new.
	#(#(apparel 'Apparel' shirt 10) #(gear 'Gear' helmetSafety 20) #(resources 'Resources' cubes 30) #(stats 'Stats' chartSimple 40))
		do: [ :section |
			description
				add: (MAToOneRelationDescription new
						accessor: section first;
						label: section second;
						icon: section third;
						priority: section fourth;
						classes: {MAAdaptiveModel};
						beReadOnly;
						yourself) ].
	^ description
]

{ #category : 'projection' }
CIInventoryProfileGraph class >> node: id class: className properties: properties [
	^ Dictionary new
		at: 'id' put: id;
		at: 'class' put: className;
		at: 'properties' put: properties;
		at: 'conditions' put: Array new;
		yourself
]

{ #category : 'projection' }
CIInventoryProfileGraph class >> object: id description: description values: values [
	^ Dictionary new
		at: 'id' put: id;
		at: 'description' put: description;
		at: 'values' put: values;
		yourself
]

{ #category : 'projection' }
CIInventoryProfileGraph class >> recordFieldsFor: aKind [
	aKind = 'savedSet' ifTrue: [ ^ #(itemIdentifier displayName) ].
	aKind = 'apparelSlot'
		ifTrue: [ ^ #(categoryIdentifier inventoryTypeCount tierId equippedDefinitionIdentifier) ].
	aKind = 'resourceStack'
		ifTrue: [ ^ #(itemIdentifier definitionIdentifier displayName count) ].
	^ #(itemIdentifier definitionIdentifier displayName tierId presentationKind inventoryTypeCount expertiseLevel brandIdentifier talentIdentifier offensiveAttributes defensiveAttributes utilityAttributes modSlots isEmptySlot)
]

{ #category : 'projection' }
CIInventoryProfileGraph class >> relation: id from: description to: target [
	^ (self field: id from: description)
		at: 'reference' put: target;
		at: 'classes' put: (Array with: 'MAAdaptiveModel');
		yourself
]

{ #category : 'projection' }
CIInventoryProfileGraph class >> resourceGroups [
	^ #(#('currencies' 'Currencies' #('Credits' 'Tokens' 'Marks')) #('keys' 'Keys' #('DepotKey' 'RelayKey')) #('foodDrink' 'Food / Drink' #('Water' 'Rations' 'Fruit' 'Tea' 'Bread')) #('rock' 'Rock' #('Granite' 'Shale' 'Quartz' 'Flint')) #('wood' 'Wood' #('Oak' 'Birch' 'Pine')) #('garden' 'Garden' #('Seeds' 'Compost' 'Sprouts')) #('building' 'Building' #('Bricks' 'Panels' 'Fasteners' 'Glass')))
]

{ #category : 'projection' }
CIInventoryProfileGraph class >> savedSetValuesFor: entry [
	^ Dictionary new
		at: 'itemIdentifier' put: (entry at: 'itemIdentifier');
		at: 'displayName' put: (entry at: 'displayName');
		yourself
]

{ #category : 'projection' }
CIInventoryProfileGraph class >> utilityTierForRows: rows [
	^ rows
		count: [ :row |
			(row isKindOf: CIInventoryGearSummary)
				and: [ row equippedSlotIdentifier notNil
						and: [ row primaryAttribute
								ifNil: [ false ]
								ifNotNil: [ :attribute | attribute attributeIdentifier = 'utilityTier' and: [ attribute value = 1 ] ] ] ] ]
]

{ #category : 'projection' }
CIInventoryProfileGraph class >> valuesFor: item fields: fields [
	| values |
	values := Dictionary new.
	fields
		do: [ :selector |
			| value |
			(item respondsTo: selector)
				ifTrue: [ value := item perform: selector.
					value ifNotNil: [ values at: selector asString put: value ] ] ].
	^ values
]
