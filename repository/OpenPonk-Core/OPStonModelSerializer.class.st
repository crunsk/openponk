"
I use STON format as a simple serialization strategy.

!! Warning

If your model relies on Announements to propagate updates between elements, the links will be broken as Announcer will be ommited during serialization.
"
Class {
	#name : #OPStonModelSerializer,
	#superclass : #OPModelSerializer,
	#category : #'OpenPonk-Core-Persistence'
}

{ #category : #accessing }
OPStonModelSerializer >> formatName [
	^ 'ston'
]

{ #category : #'serialize/materialize' }
OPStonModelSerializer >> materializeModelFrom: aStream [
	^ self stonMaterialize: aStream
]

{ #category : #'serialize/materialize' }
OPStonModelSerializer >> serializeModel: aModel to: aStream [
	^ self stonSerialize: aModel to: aStream
]

{ #category : #'ston - serialize/materialize' }
OPStonModelSerializer >> stonMaterialize: aStream [
	^ (STON reader
		allowComplexMapKeys: true;
		on: aStream) next
]

{ #category : #'ston - serialize/materialize' }
OPStonModelSerializer >> stonSerialize: anObject to: aStream [
	^ STON put: anObject onStreamPretty: aStream
]
