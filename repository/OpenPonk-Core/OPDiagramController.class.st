"
A DCDiagramController is the parent class to controller classes that control whole diagrams. It (its decendant) creates a palette / menu  for specific diagram. It also handles the changes in diagram, e.g. removal of element. 
"
Class {
	#name : #OPDiagramController,
	#superclass : #OPController,
	#instVars : [
		'controllers',
		'editor',
		'hoverHolder',
		'figureAdded',
		'deselectionHolder',
		'modelToControllerMapping',
		'plugin',
		'autosaveManager',
		'figureToControllerCache',
		'modelToControllerCache',
		'workbenchAnnouncer',
		'diagram',
		'view',
		'layouter'
	],
	#category : #'OpenPonk-Core-Controllers'
}

{ #category : #deprecated }
OPDiagramController >> addAllElements [
	self deprecated: 'Use #showAllElements instead.'.
"	model elements do: [ :each | self addModelElement: each ]"
]

{ #category : #connecting }
OPDiagramController >> addAsTargetFor: aController [
	super addAsTargetFor: aController.
"	| newModel |
	self assert: (self canBeTargetFor: aController).
	newModel := aController createModel.
	aController
		diagramController: self diagramController;
		model: newModel.
	self controllers add: aController.
	aController attach.
	self model add: newModel.
	self view signalUpdate"
]

{ #category : #'controllers management' }
OPDiagramController >> addController: aController [
	aController diagramController: self.
	self controllers add: aController
]

{ #category : #deprecated }
OPDiagramController >> addModelElement: aModelElement [
	| controller figure |
	self deprecated: 'Use createModel:showInDiagram: instead.'.
"	self controllers detect: [ :ctrl | ctrl model = aModelElement ] ifFound: [ ^ self ].
	(self model has: aModelElement)
		ifFalse: [ self model add: aModelElement ].
	controller := self createController: aModelElement.
	controller diagramController: self.
	self controllers add: controller.
	(controller isKindOf: OPRelationshipController)
		ifTrue: [ 
			| fromModel toModel fromCtrl toCtrl |
			fromModel := aModelElement source.
			toModel := aModelElement target.
			fromCtrl := self controllers detect: [ :ctrl | ctrl model = fromModel ] ifNone: [ self addModelElement: fromModel ].
			toCtrl := self controllers detect: [ :ctrl | ctrl model = toModel ] ifNone: [ self addModelElement: toModel ].
			controller
				source: fromCtrl;
				target: toCtrl ].
	controller registerModelEvents: controller model.
	figure := controller figure.
	figure view ifNil: [ figure renderIn: self view ].
	self diagramController figureAdded: figure.
	^ controller"
]

{ #category : #'as yet unclassified' }
OPDiagramController >> allShowableElements [
	"Should return all elements that could be directly hidden on diagram"

	^ (Set with: model) , self elementsToShowInside
]

{ #category : #'as yet unclassified' }
OPDiagramController >> allVisibleShowableElements [
	"Should return all elements that could be directly hidden on diagram but are currently shown"

	^ self controllers collect: [ :each | each model ]
]

{ #category : #userinterface }
OPDiagramController >> applyDefaultLayout [
	self layouter defaultLayout
]

{ #category : #accessing }
OPDiagramController >> autosaveManager [
	^ autosaveManager
		ifNil: [ autosaveManager := OPAutosaveManager
				on: self plugin singleStringSerializer ]
]

{ #category : #'controllers management' }
OPDiagramController >> cachedControllerForFigure: aFigure [
	| ctrl |
	figureToControllerCache
		ifNil: [ figureToControllerCache := Dictionary new.
			self controllers
				do: [ :each | figureToControllerCache at: each figure put: each ] ].
	ctrl := figureToControllerCache at: aFigure ifPresent: #yourself.
	(self controllers includes: ctrl)
		ifTrue: [ ^ ctrl ].
	ctrl := self controllers detect: [ :fresh | fresh figure = aFigure ].
	figureToControllerCache at: aFigure put: ctrl.
	^ ctrl
]

{ #category : #'controllers management' }
OPDiagramController >> cachedControllerForModel: aModel [
	^ self
		cachedControllerForModel: aModel
		ifNone: [ self controllers
				errorNotFound: 'Controller for ' , aModel printString ]
]

{ #category : #'controllers management' }
OPDiagramController >> cachedControllerForModel: aModel ifFound: aFoundBlock [
	| ctrl |
	modelToControllerCache
		ifNil: [ modelToControllerCache := Dictionary new.
			self controllers
				do: [ :each | modelToControllerCache at: each model put: each ] ].
	ctrl := modelToControllerCache at: aModel ifPresent: #yourself.
	(self controllers includes: ctrl)
		ifTrue: [ ^ aFoundBlock value: ctrl ].
	self controllers
		detect: [ :fresh | fresh model = aModel ]
		ifFound: [ :found | 
			modelToControllerCache at: aModel put: found.
			aFoundBlock value: found ]
]

{ #category : #'controllers management' }
OPDiagramController >> cachedControllerForModel: aModel ifNone: aNoneBlock [
	| ctrl |
	modelToControllerCache
		ifNil: [ modelToControllerCache := Dictionary new.
			self controllers
				do: [ :each | modelToControllerCache at: each model put: each ] ].
	ctrl := modelToControllerCache at: aModel ifPresent: #yourself.
	(self controllers includes: ctrl)
		ifTrue: [ ^ ctrl ].
	ctrl := self controllers
		detect: [ :fresh | fresh model = aModel ]
		ifNone: [ ^ aNoneBlock value ].
	modelToControllerCache at: aModel put: ctrl.
	^ ctrl
]

{ #category : #rebuilding }
OPDiagramController >> cleanView [
	self view clean.
	self view canvas shapes copy
		do: [ :each | 
			(each isKindOf: TRCanvasGridShape)
				ifFalse: [ each remove ] ].
	self view canvas fixedShapes copy do: #remove
]

{ #category : #'controllers management' }
OPDiagramController >> controllerForFigure: aFigure [
	^ self cachedControllerForFigure: aFigure
	"^ self controllers detect: [ :ctrl | ctrl figure = aFigure ]"
]

{ #category : #'controllers management' }
OPDiagramController >> controllerForModel: aModel [
	aModel = model
		ifTrue: [ ^ self ].
	^ self cachedControllerForModel: aModel
]

{ #category : #'controllers management' }
OPDiagramController >> controllerForModel: aModel ifFound: aFoundBlock [
	aModel = model
		ifTrue: [ ^ aFoundBlock value: self ].
	^ self cachedControllerForModel: aModel ifFound: aFoundBlock
]

{ #category : #'controllers management' }
OPDiagramController >> controllerForModel: aModel ifNone: aFoundBlock [
	aModel = model
		ifTrue: [ ^ self ].
	^ self cachedControllerForModel: aModel ifNone: aFoundBlock
]

{ #category : #deprecated }
OPDiagramController >> controllerNameFor: aModel [
	self deprecated: 'no replacement'
"	^ modelToControllerMapping at: aModel class"
]

{ #category : #'controllers management' }
OPDiagramController >> controllers [
	^ controllers ifNil: [ controllers := Set new ]
]

{ #category : #testing }
OPDiagramController >> controllersOfVisibleElements: aCollectionOfModelObject [
	^ aCollectionOfModelObject
		collect: [ :each | self controllerForModel: each ifNone: [ nil ] ]
		thenSelect: [ :each | each isNotNil ]
]

{ #category : #deprecated }
OPDiagramController >> createController: aModel [
	self
		deprecated: 'Use newControllerFor: instead'
		on: '8 November 2017'
		in: 'Pharo-6.0-60519-'.
	^ self newControllerFor: aModel
]

{ #category : #'protocol-canvas' }
OPDiagramController >> deselectAll [
	deselectionHolder value
]

{ #category : #accessing }
OPDiagramController >> diagram [
	^ diagram
]

{ #category : #accessing }
OPDiagramController >> diagram: aDiagram [
	diagram := aDiagram
]

{ #category : #accessing }
OPDiagramController >> diagramController [
	^ self
]

{ #category : #accessing }
OPDiagramController >> diagramController: aController [
	self error: 'Cannot assign diagramController to diagramController'
]

{ #category : #userinterface }
OPDiagramController >> disableRefresh [
	self flag: #todo
]

{ #category : #'protocol-canvas' }
OPDiagramController >> doubleClickFigure: aFigure [
	| controller |
	controller := self controllerForFigure: aFigure.
	controller figureDoubleClicked.
]

{ #category : #'ui interaction' }
OPDiagramController >> editor [
	^ editor ifNil: [ self error: 'Diagram controller is not attached to an editor.' ]
]

{ #category : #'ui interaction' }
OPDiagramController >> editor: anEditor [
	editor := anEditor
]

{ #category : #userinterface }
OPDiagramController >> enableRefresh [
	self flag: #todo
]

{ #category : #accessing }
OPDiagramController >> figure [
	^ self view
]

{ #category : #accessing }
OPDiagramController >> figureAdded: aFigure [
	figureAdded value: aFigure.
	self updateView
]

{ #category : #deprecated }
OPDiagramController >> figureFor: aModel [
	self
		deprecated: 'Use figureForModel: instead'
		on: '8 November 2017'
		in: 'Pharo-6.0-60519-'.
	^ self figureForModel: aModel
]

{ #category : #accessing }
OPDiagramController >> figureForModel: aModel [
	^ (self controllerForModel: aModel) figure
]

{ #category : #'ui interaction' }
OPDiagramController >> formPresenter [
	^ self editor workbench formModel
]

{ #category : #'controllers management' }
OPDiagramController >> hasControllerForModel: aModel [
	^ aModel = model
		or: [ self cachedControllerForModel: aModel ifNone: [ ^ false ].
			true ]
]

{ #category : #testing }
OPDiagramController >> hasRedo [
	^ self autosaveManager futureIsEmpty not
]

{ #category : #testing }
OPDiagramController >> hasSupportForModel: aModel [
	modelToControllerMapping isDictionary
		ifTrue: [ ^ modelToControllerMapping includesKey: aModel class ].
	^ modelToControllerMapping hasControllerFor: aModel
]

{ #category : #testing }
OPDiagramController >> hasUndo [
	^ self autosaveManager historyIsEmpty not
]

{ #category : #figures }
OPDiagramController >> hideAllElements [
	[ self controllers isNotEmpty ] whileTrue: [ self controllers anyOne removeController ].
	self cleanView.
	self view signalUpdate
]

{ #category : #figures }
OPDiagramController >> hideModelFromDiagram: aModel [
	self
		controllerForModel: aModel
		ifFound: [ :ctrl | ctrl removeController ]
]

{ #category : #'protocol-canvas' }
OPDiagramController >> hoverFigure: aFigure [
	| controller |
	controller := self controllerForFigure: aFigure.
	hoverHolder value: controller
]

{ #category : #'protocol-canvas' }
OPDiagramController >> hoverView [
	hoverHolder value: self
]

{ #category : #initialization }
OPDiagramController >> initialize [
	super initialize.
	selectionHolder := [  ].
	deselectionHolder := [  ].
	hoverHolder := [  ].
	figureAdded := [ :figure |  ].
	modelToControllerMapping := self modelToControllerMapping.
	diagramController := self
]

{ #category : #'ui interaction' }
OPDiagramController >> initializePalette: aPalette [
	self subclassResponsibility
]

{ #category : #testing }
OPDiagramController >> isVisibleInDiagram: aModel [
	^ self hasControllerForModel: aModel
]

{ #category : #accessing }
OPDiagramController >> layout [
	^ (controllers
		collect: [ :ctrl | ctrl model uuid -> ctrl layout ]
		thenReject: [ :each | each value isNone ]) asDictionary
]

{ #category : #accessing }
OPDiagramController >> layout: aLayout [
	aLayout
		keysAndValuesDo: [ :key :value | 
			self controllers
				detect: [ :ctrl | ctrl model uuid = key ]
				ifFound: [ :ctrl | ctrl layout: value ] ].
	self updateView
]

{ #category : #accessing }
OPDiagramController >> layouter [
	^ layouter
		ifNil: [ layouter := self plugin layouterClass new diagramController: self ]
]

{ #category : #accessing }
OPDiagramController >> layouter: aLayouter [
	layouter := aLayouter
]

{ #category : #'undo/redo' }
OPDiagramController >> loadState: aMemento [
"	| oldModel |
	aMemento ifNil: [ ^ self ].
	oldModel := self model.
	model := aMemento model.
	model announcer: oldModel announcer.
	self rebuild.
	self diagram: aMemento diagram.
	self logCr: aMemento diagram.
	self editor updateUndoRedo"
]

{ #category : #accessing }
OPDiagramController >> modelClass [
	^ self plugin modelClass
]

{ #category : #accessing }
OPDiagramController >> modelForFigure: aFigure [
	^ (self controllerForFigure: aFigure) model
]

{ #category : #'events handling' }
OPDiagramController >> modelRemoved: aModel [
	self controllerForModel: aModel ifFound: #removeController
]

{ #category : #accessing }
OPDiagramController >> modelToControllerMapping [
	^ Dictionary new
]

{ #category : #'controllers management' }
OPDiagramController >> newControllerFor: aModel [
	modelToControllerMapping isDictionary
		ifTrue: [ ^ self newControllerForOld: aModel ].
	^ modelToControllerMapping newControllerFor: aModel
]

{ #category : #'controllers management' }
OPDiagramController >> newControllerForOld: aModel [
	| controller |
	controller := (modelToControllerMapping at: aModel class) new.
	controller model: aModel.
	^ controller
]

{ #category : #'ui interaction' }
OPDiagramController >> openInForm: aController [
	self formPresenter editController: aController
]

{ #category : #accessing }
OPDiagramController >> parent [
	^ self
]

{ #category : #accessing }
OPDiagramController >> plugin [
	^ plugin ifNil: [ OPPluginRegistry default pluginForController: self ]
]

{ #category : #rebuilding }
OPDiagramController >> rebuild [
	controllers := nil.
	self cleanView.
	diagram
		ifNil: [ ^ self
				showElements;
				applyDefaultLayout ].
	diagram camera
		ifNotNil: [ :camera | 
			view canvas camera translateTo: camera offset.
			view canvas camera scale: camera zoom ].
	self showElements.
	diagram layout
		ifNil: [ self applyDefaultLayout ]
		ifNotNil: [ self layout: diagram layout ]
]

{ #category : #'undo/redo' }
OPDiagramController >> redo [
	self assert: [ self hasRedo ].
	self loadState: self autosaveManager loadNext
]

{ #category : #deprecated }
OPDiagramController >> registerModelEvents: aModel [
	self deprecated: 'Use #model: and #internalSubscribeTo: instead'.
	"super registerModelEvents: aModel.
	aModel announcer when: OPElementChanged do: [ :evt | self saveState ]"
]

{ #category : #deprecated }
OPDiagramController >> remove [
	self deprecated: 'There should be no need to call #remove on DiagramController'.
	self error: 'There should be no need to call #remove on DiagramController'.
"	super remove.
	[ self controllers isNotEmpty ] whileTrue: [ self controllers last remove ]"
]

{ #category : #destruction }
OPDiagramController >> removeAllControllers [
	[ self controllers isNotEmpty ] whileTrue: [ self controllers last removeController ]
]

{ #category : #'controllers management' }
OPDiagramController >> removeController: aController [
	self controllers remove: aController
]

{ #category : #deprecated }
OPDiagramController >> removeControllerOf: aModelElement [
	self
		deprecated: 'Use #removeController: and #removeController instead'
		on: '8 November 2017'
		in: 'Pharo-6.0-60519-'.
	^ self removeController: (self controllerForModel: aModelElement)
]

{ #category : #deprecated }
OPDiagramController >> removeFromModel: aModel [
	"Remove aModel from the diagram.
	It is aModel's owner's controller responsibility to remove it.
	The assertion tests whether aModel is attached to the current controller chain.
	"
	self deprecated: 'Use #removeModel on its controller instead.'

"	self assert: (self controllerForModel: aModel) model = aModel.
	(self controllerForModel: aModel owner) removeModelElement: aModel"
]

{ #category : #destruction }
OPDiagramController >> removeFromView: aFigure [
	aFigure ifNil: [ ^ self ].
	(self controllerForFigure: aFigure) removeFull
]

{ #category : #deprecated }
OPDiagramController >> removeModel [
	self deprecated: 'should not implement'.
	^ self shouldNotImplement
]

{ #category : #deprecated }
OPDiagramController >> removeModelElement: aModelElement [
	self deprecated: 'Use removeModel on its controller instead.'.
"	model remove: aModelElement"

	(self controllerForModel: aModelElement) removeModel
]

{ #category : #'undo/redo' }
OPDiagramController >> saveState [
"	| memento |
	memento := self memento.
	self autosaveManager saveState: memento.
	self editor updateUndoRedo.
	self editor workbench projectController autoSave: memento"
]

{ #category : #'ui interaction' }
OPDiagramController >> selectController: aController [
	self editor paletteModel selectSelectionTool selectedTool targetSelected: aController
]

{ #category : #'protocol-canvas' }
OPDiagramController >> selectFigure: aFigure [
	| controller |
	controller := self controllerForFigure: aFigure.
	selectionHolder value: controller
]

{ #category : #'protocol-canvas' }
OPDiagramController >> selectView [
	selectionHolder value: self
]

{ #category : #figures }
OPDiagramController >> selectableFigures [
	^ #()
]

{ #category : #rebuilding }
OPDiagramController >> showAllElements [
	self disableRefresh.
	self showWithoutDependentInDiagram: self.
	self enableRefresh.
	self controllers
		select: [ :each | each isKindOf: OPController ]
		thenDo: #refreshFigure
]

{ #category : #views }
OPDiagramController >> showDiagram: aDiagram [
	aDiagram camera
		ifNotNil: [ :camera | 
			view canvas camera translateTo: camera offset.
			view canvas camera scale: camera zoom ].
	aDiagram isDefault & aDiagram visibleElements isEmpty
		ifTrue: [ self showAllElements ]
		ifFalse: [ self visibleElements: aDiagram visibleElements ].
	aDiagram layout
		ifNil: [ self applyDefaultLayout ]
		ifNotNil: [ self layout: aDiagram layout ].
	diagram := aDiagram
]

{ #category : #rebuilding }
OPDiagramController >> showElements [
	self showAllElements.
	diagram
		ifNotNil: [ diagram visibleElements
				ifNotEmpty: [ :elements | self visibleElements: elements ] ]
]

{ #category : #figures }
OPDiagramController >> showInDiagramModel: aModel [
	self controllerForModel: aModel ifFound: [ :ctrl | ^ ctrl ].
	^ (self newControllerFor: aModel)
		showInDiagram: self;
		yourself
]

{ #category : #construction }
OPDiagramController >> showWithoutDependentInDiagram: aDiagramController [
	"it is impossible to show diagram without dependent - dependent elements ARE the diagram"
	self dependentElements
		do: [ :each | aDiagramController showInDiagramModel: each ]
]

{ #category : #figures }
OPDiagramController >> showWithoutDependentInDiagramModel: aModel [
	self controllerForModel: aModel ifFound: [ :ctrl | ^ ctrl ].
	^ (self newControllerFor: aModel)
		showWithoutDependentInDiagram: self;
		yourself
]

{ #category : #'undo/redo' }
OPDiagramController >> undo [
	self assert: [ self hasUndo ].
	self loadState: self autosaveManager loadPrevious
]

{ #category : #userinterface }
OPDiagramController >> updateView [
	self controllers do: [ :each | each refreshFigure ]
]

{ #category : #accessing }
OPDiagramController >> view [
	^ view
]

{ #category : #accessing }
OPDiagramController >> view: aView [
	view := aView
]

{ #category : #accessing }
OPDiagramController >> visibleElements [
	^ self allShowableElements select: [ :el | self isVisibleInDiagram: el ]
]

{ #category : #accessing }
OPDiagramController >> visibleElements: aCollection [
	| executor |
	aCollection ifEmpty: [ ^ self ].
	executor := OPShowHideFacade on: self.
	executor hideAll.
	executor
		showElements:
			(self allShowableElements
				select: [ :each | aCollection anySatisfy: [ :any | any = each ] ])
]

{ #category : #'protocol-events' }
OPDiagramController >> whenDeselectionChanged: aBlock [
	deselectionHolder := aBlock
]

{ #category : #'protocol-events' }
OPDiagramController >> whenFigureAdded: aBlock [
	figureAdded := aBlock ifNil: [ [ :figure |  ] ]
]

{ #category : #'protocol-events' }
OPDiagramController >> whenHoverChanged: aBlock [
	hoverHolder := aBlock
]

{ #category : #'protocol-events' }
OPDiagramController >> whenSelectionChanged: aBlock [
	selectionHolder := aBlock
]

{ #category : #accessing }
OPDiagramController >> workbenchAnnouncer [
	^ workbenchAnnouncer
]

{ #category : #accessing }
OPDiagramController >> workbenchAnnouncer: anObject [
	workbenchAnnouncer := anObject
]
