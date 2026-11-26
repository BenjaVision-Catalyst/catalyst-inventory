Class {
	#name : 'CIInventoryGatewayQualificationApplication',
	#superclass : 'CUAuthenticatedQuicApplication',
	#classVars : [
		'InventoryService',
		'ProofNames',
		'UsersService'
	],
	#category : 'BVC-Inventory-Connect-Tests',
	#package : 'BVC-Inventory-Connect-Tests'
}

{ #category : 'qualification' }
CIInventoryGatewayQualificationApplication class >> clearFixture [
	ProofNames := nil.
	UsersService := nil.
	InventoryService := nil
]

{ #category : 'qualification' }
CIInventoryGatewayQualificationApplication class >> equipFixtureRowsAfterChange: changed [
	| rows shoes vest replacementShoes replacementVest |
	rows := self starterItems asOrderedCollection.
	shoes := rows detect: [ :row | row itemIdentifier = 'extraGripShoes' ].
	shoes equippedApparelSlotIdentifier: (changed ifFalse: [ 'Shoes' ]).
	changed ifFalse: [ ^ rows ].
	vest := rows detect: [ :row | row itemIdentifier = 'responseChest' ].
	vest equippedSlotIdentifier: nil.
	replacementVest := CIInventoryEquipmentSummary
			item: 'fieldVest'
			fromDefinition: (CIInventoryItemDefinition
					id: 'fieldVest'
					name: 'Field vest'
					icon: nil)
			metadata: (Dictionary new
					at: #presentationKind put: 'gear';
					at: #inventoryTypeCount put: 1;
					at: #equippedSlotIdentifier put: 'Chest';
					yourself).
	replacementShoes := CIInventoryApparelItemSummary
			item: 'fieldShoes'
			fromDefinition: (CIInventoryItemDefinition
					id: 'fieldShoes'
					name: 'Field shoes'
					icon: nil).
	replacementShoes equippedApparelSlotIdentifier: 'Shoes'.
	rows
		add: replacementVest;
		add: replacementShoes.
	^ rows
]

{ #category : 'qualification' }
CIInventoryGatewayQualificationApplication class >> equipFixtureRowsForOverwriteReset [
	| rows |
	rows := self equipFixtureRowsAfterChange: true.
	(rows detect: [ :row | row itemIdentifier = 'responseChest' ])
		equippedSlotIdentifier: 'Chest'.
	(rows detect: [ :row | row itemIdentifier = 'fieldVest' ])
		equippedSlotIdentifier: nil.
	(rows detect: [ :row | row itemIdentifier = 'extraGripShoes' ])
		equippedApparelSlotIdentifier: 'Shoes'.
	(rows detect: [ :row | row itemIdentifier = 'fieldShoes' ])
		equippedApparelSlotIdentifier: nil.
	^ rows
]

{ #category : 'qualification' }
CIInventoryGatewayQualificationApplication class >> proofNames: proofs users: users inventory: inventory [
	ProofNames := proofs.
	UsersService := users.
	InventoryService := inventory
]

{ #category : 'qualification' }
CIInventoryGatewayQualificationApplication class >> qualifyIn: directory [
	| runtime config services gateway settings host worker users inventory alice bob deadline listenerPort equipmentPhase |
	runtime := CRRuntime new.
	settings := Dictionary new
			at: 'role' put: 'server';
			at: 'bind' put: '127.0.0.1:0';
			at: 'server_name' put: 'localhost';
			at: 'certificate' put: (directory / 'server' / 'certificate.der') fullName;
			at: 'private_key' put: (directory / 'server' / 'private-key.der') fullName;
			at: 'trusted_certificate'
				put: (directory / 'client' / 'certificate.der') fullName;
			at: 'capacity' put: 8;
			yourself.
	gateway := CCQuicConfiguration new
			nativeProtocolVersion: 2;
			identifier: #connect;
			label: 'Connect';
			nativeOptionsJson: (STONJSON toString: settings);
			libraryPath: (directory / 'native-library-path') contents trimBoth;
			principal: 'qualification-peer';
			allowedOperations: #(101 102 103 104 105 106 107);
			applicationClass: self;
			bindings: {CRServiceBindingConfiguration new
						identifier: #users;
						serviceIdentifier: #users;
						yourself.
					CRServiceBindingConfiguration new
						identifier: #inventory;
						serviceIdentifier: #inventory;
						yourself};
			yourself.
	services := {CROrchestrationConfiguration default.
			CUUsersConfiguration new
				identifier: #users;
				label: 'Users';
				authoritative: true;
				yourself.
			CIInventoryConfiguration new
				identifier: #inventory;
				label: 'Inventory';
				authoritative: true;
				yourself.
			gateway}.
	config := CRRuntimeConfiguration new
			label: 'Inventory isolation qualification';
			services: services;
			yourself.
	host := CRHostConfiguration new
			identifier: #authority;
			label: 'Authority';
			address: 'localhost';
			maxProcesses: 1;
			services: (services collect: #identifier);
			yourself.
	config
		topology: (CRTopologyConfiguration new
				hosts: {host};
				placementStrategyConfiguration: CRRoundRobinPlacementStrategyConfiguration new;
				yourself).
	config deployment
		serviceDeployments: (services
				collect: [ :service |
					CRServiceDeploymentConfiguration new
						serviceIdentifier: service identifier;
						label: service label;
						initialCount: 1;
						yourself ]).
	config failureEvidenceConfiguration captureDebugArtifacts: false.
	alice := CUUser new
			name: UUID new asString;
			ensureIdentity;
			yourself.
	bob := CUUser new
			name: UUID new asString;
			ensureIdentity;
			yourself.
	[ runtime configure: config.
	runtime start.
	deadline := CRPlatform current currentMillis + 10000.
	[ runtime convergenceReport notNil
		and: [ runtime convergenceReport isConverged ] ]
		whileFalse: [ CRPlatform current currentMillis >= deadline
				ifTrue: [ self error: 'Runtime failed to converge' ].
			(Delay forMilliseconds: 20) wait ].
	worker := CRPharoWorker allInstances
			detect: [ :each |
				each runtime == runtime
					and: [ (each services serviceAtIdentifier: #inventory) notNil ] ].
	users := worker services serviceAtIdentifier: #users.
	inventory := worker services serviceAtIdentifier: #inventory.
	CUUsers allUsers
		add: alice;
		add: bob.
	inventory replaceReadRows: self starterItems forOwner: alice userIdentifier.
	inventory
		replaceReadRows: {CIInventoryGearSummary
					item: 'bob-item'
					fromDefinition: ((CIInventoryItemDefinition
							id: 'coat'
							name: 'Coat'
							icon: nil)
							tierId: 6;
							yourself)
					metadata: (Dictionary new
							at: #presentationKind put: 'gear';
							at: #inventoryTypeCount put: 1;
							at: #gearSlotIdentifier put: 'Chest';
							yourself)}
		forOwner: bob userIdentifier.
	self
		proofNames: (Dictionary new
				at: (directory / 'proof-a') contents utf8Encoded put: alice name;
				at: (directory / 'proof-b') contents utf8Encoded put: bob name;
				yourself)
		users: users
		inventory: inventory.
	deadline := CRPlatform current currentMillis + 10000.
	[ listenerPort := ((worker services serviceAtIdentifier: #connect) status
			at: #statistics) at: #port.
	listenerPort > 0 ]
		whileFalse: [ CRPlatform current currentMillis >= deadline
				ifTrue: [ self error: 'Connect listener did not report a bound port' ].
			(Delay forMilliseconds: 20) wait ].
	CRPlatform current
		writeConnectEvidence: (Dictionary new
				at: 'port' put: listenerPort;
				at: 'alice' put: alice userIdentifier;
				at: 'bob' put: bob userIdentifier;
				yourself)
		to: (directory / 'isolation-ready.json') fullName.
	equipmentPhase := 0.
	deadline := CRPlatform current currentMillis + 60000.
	[ (directory / 'isolation-stop') exists
		or: [ CRPlatform current currentMillis >= deadline ] ]
		whileFalse: [ (equipmentPhase = 0 and: [ (directory / 'fixture-equipment-seed') exists ])
				ifTrue: [ inventory
						replaceReadRows: (self equipFixtureRowsAfterChange: false)
						forOwner: alice userIdentifier.
					(directory / 'fixture-equipment-seed-ready') ensureCreateFile.
					equipmentPhase := 1 ].
			(equipmentPhase = 1 and: [ (directory / 'fixture-equipment-change') exists ])
				ifTrue: [ inventory
						replaceReadRows: (self equipFixtureRowsAfterChange: true)
						forOwner: alice userIdentifier.
					(directory / 'fixture-equipment-change-ready') ensureCreateFile.
					equipmentPhase := 2 ].
			(equipmentPhase = 2
				and: [ (directory / 'fixture-equipment-overwrite') exists ])
				ifTrue: [ inventory
						replaceReadRows: (self equipFixtureRowsAfterChange: true)
						forOwner: alice userIdentifier.
					(directory / 'fixture-equipment-overwrite-ready') ensureCreateFile.
					equipmentPhase := 3 ].
			(equipmentPhase = 3
				and: [ (directory / 'fixture-equipment-overwrite-reset') exists ])
				ifTrue: [ inventory
						replaceReadRows: self equipFixtureRowsForOverwriteReset
						forOwner: alice userIdentifier.
					(directory / 'fixture-equipment-overwrite-reset-ready') ensureCreateFile.
					equipmentPhase := 4 ].
			(Delay forMilliseconds: 20) wait ] ]
		ensure: [ runtime stop.
			runtime registry unregister: runtime.
			self clearFixture.
			CUUsers allUsers remove: alice ifAbsent: [  ].
			CUUsers allUsers remove: bob ifAbsent: [  ] ]
]

{ #category : 'qualification' }
CIInventoryGatewayQualificationApplication class >> starterItems [
	| items |
	items := OrderedCollection new.
	#(#('responseHead' 'Response Helmet' 'Head') #('responseEyes' 'Response Goggles' 'Eyes') #('responseChest' 'Response Aid Vest' 'Chest') #('responseFeet' 'Response Boots' 'Feet'))
		do: [ :spec |
			| metadata |
			metadata := Dictionary new
					at: #presentationKind put: 'gear';
					at: #inventoryTypeCount put: 1;
					at: #gearSlotIdentifier put: spec third;
					at: #brandIdentifier put: 'response';
					at: #brandName put: 'Relay Works';
					yourself.
			spec first = 'responseChest'
				ifTrue: [ metadata
						at: #defensiveAttributes put: #('armour');
						at: #utilityAttributes put: #('healing') ].
			items
				add: (CIInventoryGearSummary
						item: spec first
						fromDefinition: (CIInventoryItemDefinition
								id: spec first
								name: spec second
								icon: nil)
						metadata: metadata) ].
	items
		add: (CIInventoryApparelItemSummary
				item: 'extraGripShoes'
				fromDefinition: (CIInventoryItemDefinition
						id: 'extraGripShoes'
						name: 'Extra-grip shoes'
						icon: nil)).
	#(#('Credits' 'Credits' 240) #('Tokens' 'Tokens' 34) #('Marks' 'Marks' 8) #('DepotKey' 'Depot Key' 2) #('RelayKey' 'Relay Key' 1) #('Water' 'Water' 7) #('Rations' 'Rations' 5) #('Fruit' 'Fruit' 12) #('Tea' 'Tea' 3) #('Bread' 'Bread' 4) #('Granite' 'Granite' 42) #('Shale' 'Shale' 19) #('Quartz' 'Quartz' 8) #('Flint' 'Flint' 6) #('Oak' 'Oak' 18) #('Birch' 'Birch' 14) #('Pine' 'Pine' 25) #('Seeds' 'Seeds' 16) #('Compost' 'Compost' 9) #('Sprouts' 'Sprouts' 4) #('Bricks' 'Bricks' 60) #('Panels' 'Panels' 13) #('Fasteners' 'Fasteners' 85) #('Glass' 'Glass' 11))
		do: [ :spec |
			items
				add: (CIInventoryResourceStackSummary
						stack: spec first
						definition: spec first
						name: spec second
						count: spec third) ].
	^ items asArray
]

{ #category : 'qualification' }
CIInventoryGatewayQualificationApplication >> authenticationOperation [
	^ 101
]

{ #category : 'qualification' }
CIInventoryGatewayQualificationApplication >> execute: request asVerifiedUser: identity using: producer [
	| rows fields description reply bytes |
	(#(105 106 107) includes: request operation)
		ifTrue: [ (request body size = 36
				and: [ request body
						allSatisfy: [ :byte | byte = 45 or: [ (byte between: 48 and: 57) or: [ byte between: 97 and: 102 ] ] ] ])
				ifFalse: [ ^ self replyWith: #[] status: 400 ].
			bytes := request operation = 105
					ifTrue: [ InventoryService
							equipSavedSet: request body utf8Decoded
							forVerifiedUser: identity ]
					ifFalse: [ request operation = 106
							ifTrue: [ InventoryService
									overwriteSavedSet: request body utf8Decoded
									forVerifiedUser: identity ]
							ifFalse: [ InventoryService
									deleteSavedSet: request body utf8Decoded
									forVerifiedUser: identity ] ].
			bytes ifNil: [ ^ self replyWith: #[] status: 422 ].
			^ self replyWith: bytes status: 0 ].
	request operation = 104
		ifTrue: [ (request body size = 1 and: [ #(0 1) includes: request body first ])
				ifFalse: [ ^ self replyWith: #[] status: 400 ].
			bytes := InventoryService
					createSavedSetFor: identity
					outfit: request body first = 1.
			bytes ifNil: [ ^ self replyWith: #[] status: 422 ].
			^ self replyWith: bytes status: 0 ].
	request operation = 103
		ifTrue: [ request body isEmpty ifFalse: [ ^ self replyWith: #[] status: 403 ].
			bytes := CIInventoryProfileGraph
					encodeReply: (self profileGraphFor: identity).
			bytes ifNil: [ ^ self replyWith: #[] status: 422 ].
			^ self replyWith: bytes status: 0 ].
	(request operation = 102 and: [ request body isEmpty ])
		ifFalse: [ ^ self replyWith: #[] status: 403 ].
	rows := InventoryService
			rowsForVerifiedUser: identity
			offset: 0
			limit: 2.
	description := (CIInventoryItemSummary
			item: 'item'
			definition: 'definition'
			name: 'Name') magritteDescription.
	fields := description children asArray
			collect: [ :field | field accessor readSelector ].
	reply := Dictionary new
			at: 'fields'
				put: (description children asArray
						collect: [ :field |
							Dictionary new
								at: 'key' put: field accessor readSelector asString;
								at: 'label' put: field label;
								yourself ]);
			at: 'rows'
				put: (rows collect: [ :row | fields collect: [ :field | row perform: field ] ]);
			yourself.
	bytes := (STONJSON toString: reply) utf8Encoded.
	bytes size > 4080 ifTrue: [ ^ self replyWith: #[] status: 422 ].
	^ self replyWith: bytes status: 0
]

{ #category : 'qualification' }
CIInventoryGatewayQualificationApplication >> profileGraphFor: identity [
	^ InventoryService profileGraphForVerifiedUser: identity
]

{ #category : 'qualification' }
CIInventoryGatewayQualificationApplication >> verifiedUserForProof: proof connection: connection [
	| name |
	ProofNames ifNil: [ ^ nil ].
	name := ProofNames removeKey: proof ifAbsent: [ ^ nil ].
	^ UsersService getUser: name
]
