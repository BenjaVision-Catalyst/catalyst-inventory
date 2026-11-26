Class {
	#name : 'CIInventoryService',
	#superclass : 'CRWorkerService',
	#instVars : [
		'readStore'
	],
	#category : 'BVC-Inventory-Runtime',
	#package : 'BVC-Inventory-Runtime'
}

{ #category : 'configuration' }
CIInventoryService class >> configurationClass [
	^ CIInventoryConfiguration
]

{ #category : 'accessing' }
CIInventoryService >> profileGraphForVerifiedUser: identity [
	^ CIInventoryProfileGraph
		forVerifiedUser: identity
		rows: (self
				rowsForVerifiedUser: identity
				offset: 0
				limit: 32)
]

{ #category : 'reading' }
CIInventoryService >> replaceReadRows: rows forOwner: identity [
	readStore replaceRows: rows forOwner: identity
]

{ #category : 'reading' }
CIInventoryService >> rowsForVerifiedUser: anIdentifier offset: anOffset limit: aLimit [
	^ readStore
		rowsForOwner: anIdentifier
		offset: anOffset
		limit: aLimit
]

{ #category : 'lifecycle' }
CIInventoryService >> start [
	super start.
	readStore := CIInventoryReadStore new
]

{ #category : 'lifecycle' }
CIInventoryService >> stop [
	readStore := nil.
	super stop
]
