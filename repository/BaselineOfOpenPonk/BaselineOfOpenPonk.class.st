"
I am baseline for the core and all-in-one dynacase.
https://dynacase.github.io/
"
Class {
	#name : #BaselineOfOpenPonk,
	#superclass : #BaselineOf,
	#category : #BaselineOfOpenPonk
}

{ #category : #plugins }
BaselineOfOpenPonk class >> loadBormEditor [
	self new loadBormEditor
]

{ #category : #plugins }
BaselineOfOpenPonk class >> loadClassEditor [
	self new loadClassEditor
]

{ #category : #plugins }
BaselineOfOpenPonk class >> loadDemoEditor [
	self new loadDemoEditor
]

{ #category : #plugins }
BaselineOfOpenPonk class >> loadFsmEditor [
	self new loadFsmEditor
]

{ #category : #plugins }
BaselineOfOpenPonk class >> loadPetriNets [
	self new loadPetriNets
]

{ #category : #plugins }
BaselineOfOpenPonk class >> loadPlugins [
	self new loadPlugins
]

{ #category : #accessing }
BaselineOfOpenPonk >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ self externalProjectsBaseline: spec.
			self internalProjectsBaseline: spec.
			spec
				package: 'OpenPonk-Core'
					with: [ spec
						requires: #('Magritte' 'Mocketry' 'Roassal2' 'XMLParser' 'XPath' 'NeoJSON') ];
				package: 'OpenPonk-Perf';
				package: 'OpenPonk-Trachel';
				package: 'OpenPonk-Roassal2';
				package: 'OpenPonk-Morphic';
				"package: 'OpenPonk-Telemetry'
					with: [ spec requires: #('Sentry') ];"
					package: 'OpenPonk-Help';
				package: 'OpenPonk-Spec'
					with: [ spec
						requires:
							#('Moose' 'FileDialog' 'Magritte'" 'Commander'" 'SynchronizedLinks' 'OpenPonk-Morphic') ];
				package: 'OpenPonk-UI';
				package: 'OpenPonk-Plugins'
					with: [ spec postLoadDoIt: #loadPlugins ].
			spec
				group: 'default'
				with:
					#('OpenPonk-Core' 'OpenPonk-Perf' 'OpenPonk-Trachel' 'OpenPonk-Roassal2' 'OpenPonk-Morphic' 'OpenPonk-Spec' 'OpenPonk-UI' 'OpenPonk-Help'	"'OpenPonk-Telemetry'").
			spec group: 'complete' with: #('default' 'OpenPonk-Plugins') ]
]

{ #category : #accessing }
BaselineOfOpenPonk >> externalProjectsBaseline: spec [
"	spec
		baseline: 'Commander'
		with: [ spec repository: 'github://pharo-ide/Commander:v0.7.0/src' ]."
	spec
		baseline: 'XMLParser'
		with: [ spec
				repository: 'github://pharo-contributions/XML-XMLParser:3.5.x/src' ].
	spec
		baseline: 'XPath'
		with:
			[ spec repository: 'github://pharo-contributions/XML-XPath:2.2.0/src' ].
	spec
		baseline: 'Roassal2'
		with: [ spec
				repository:
					'github://ObjectProfile/Roassal2:004ab6f3dfd41cf06526c57115ee42cc921e7668/src';
				postLoadDoIt: #loadPetitParser ].
	spec
		baseline: 'Magritte'
		with: [ spec
				repository:
					'github://magritte-metamodel/magritte:49781e985875315d06c5991f094c30d6f8c9f02d/source';
				loads: #(Core 'Magritte-Morph');
				postLoadDoIt: #removeGreaseWarnings ].
	spec
		baseline: 'Moose'
		with: [ spec
				repository: 'github://moosetechnology/Moose:24a33d7/src';
				loads: #(Merlin) ].
	spec
		baseline: 'Mocketry'
		with: [ spec repository: 'github://dionisiydk/Mocketry:v6.0.0' ].
	spec
		baseline: 'NeoJSON'
		with: [ spec repository: 'github://svenvc/NeoJSON/repository' ]
]

{ #category : #accessing }
BaselineOfOpenPonk >> internalProjectsBaseline: spec [
	spec
		baseline: 'FileDialog'
		with: [ spec repository: 'github://peteruhnak/file-dialog:v1.x/repository' ].
	"spec
		baseline: 'Sentry'
		with: [ spec repository: 'github://peteruhnak/pharo-sentry:v1.x/repository' ]."
	spec
		baseline: 'SynchronizedLinks'
		with: [ spec repository: 'github://openponk/synchronized-links/repository' ]
]

{ #category : #plugins }
BaselineOfOpenPonk >> loadBormEditor [
	Metacello new
		baseline: 'BormEditor';
		repository: 'github://openponk/borm-editor/repository';
		load: #(plugin)
]

{ #category : #plugins }
BaselineOfOpenPonk >> loadClassEditor [
	Metacello new
		baseline: 'ClassEditor';
		repository: 'github://openponk/class-editor/repository';
		load: #(plugin)
]

{ #category : #plugins }
BaselineOfOpenPonk >> loadDemoEditor [
	self notify: 'OpenPonk DEMO project is abandoned - it is not working'.
	Metacello new
		baseline: 'DemoEditor';
		repository: 'github://openponk/demo-editor/repository';
		load: #(plugin)
]

{ #category : #plugins }
BaselineOfOpenPonk >> loadFsmEditor [
	Metacello new
		baseline: 'FsmEditor';
		repository: 'github://openponk/fsm-editor/repository';
		load: #(plugin)
]

{ #category : #accessing }
BaselineOfOpenPonk >> loadPetitParser [
	"this is solved separatedly by direct loading code because PetitParser does not specify Roassal2 version, which causes conflicts and this is probably only way to use onConflict:"
	
	Metacello new
		baseline: 'PetitParser';
		repository: 'github://moosetechnology/PetitParser:v2.x.x/src';
		onConflict: [ :err | err useLoaded ];
		load
]

{ #category : #plugins }
BaselineOfOpenPonk >> loadPetriNets [
	Metacello new
		baseline: 'PetriNets';
		repository: 'github://openponk/petrinets/repository';
		load: #(plugin)
]

{ #category : #plugins }
BaselineOfOpenPonk >> loadPlugins [
	self
		loadBormEditor;
		loadClassEditor;
		"loadDemoEditor;" "OpenPonk DEMO project is abandoned - it is not working"
		loadFsmEditor;
		loadPetriNets
]

{ #category : #scripts }
BaselineOfOpenPonk >> removeGreaseWarnings [
	('Grease-Pharo40-Slime' asPackageIfAbsent: [ ^ self ])
		removeFromSystem.
	'Grease-Core' asPackage mcWorkingCopy modified: false
]
