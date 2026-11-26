Class {
	#name : 'CIInventoryReadStoreTest',
	#superclass : 'TestCase',
	#instVars : [
		'store'
	],
	#category : 'BVC-Inventory-Tests',
	#package : 'BVC-Inventory-Tests'
}

{ #category : 'running' }
CIInventoryReadStoreTest >> setUp [
	super setUp.
	store := CIInventoryReadStore new
]

{ #category : 'tests' }
CIInventoryReadStoreTest >> testInvalidBoundsAndMissingOwnerRefuse [
	self
		should: [ store
				rowsForOwner: nil
				offset: 0
				limit: 1 ]
		raise: Error.
	self
		should: [ store
				rowsForOwner: 'user-a'
				offset: -1
				limit: 1 ]
		raise: Error.
	self
		should: [ store
				rowsForOwner: 'user-a'
				offset: 0
				limit: 33 ]
		raise: Error
]

{ #category : 'tests' }
CIInventoryReadStoreTest >> testOwnersSeeTheirOwnRows [
	| boots coat |
	boots := CIInventoryItemSummary
			item: 'one'
			definition: 'boots'
			name: 'Boots'.
	coat := CIInventoryItemSummary
			item: 'two'
			definition: 'coat'
			name: 'Coat'.
	store replaceRows: {boots} forOwner: 'user-a'.
	store replaceRows: {coat} forOwner: 'user-b'.
	self
		assert: (store
				rowsForOwner: 'user-a'
				offset: 0
				limit: 32)
		equals: {boots}.
	self
		assert: (store
				rowsForOwner: 'user-b'
				offset: 0
				limit: 32)
		equals: {coat}.
	self
		assertEmpty: (store
				rowsForOwner: 'unknown'
				offset: 0
				limit: 32)
]

{ #category : 'tests' }
CIInventoryReadStoreTest >> testPageDoesNotExposeBackingCollection [
	| first second rows page |
	first := CIInventoryItemSummary
			item: 'one'
			definition: 'boots'
			name: 'Boots'.
	second := CIInventoryItemSummary
			item: 'two'
			definition: 'coat'
			name: 'Coat'.
	rows := {first.
			second}.
	store replaceRows: rows forOwner: 'user-a'.
	rows at: 2 put: first.
	page := store
			rowsForOwner: 'user-a'
			offset: 1
			limit: 1.
	self assert: page equals: {second}.
	page at: 1 put: first.
	self
		assert: (store
				rowsForOwner: 'user-a'
				offset: 1
				limit: 1)
		equals: {second}.
	self
		assertEmpty: (store
				rowsForOwner: 'user-a'
				offset: 2
				limit: 1)
]
