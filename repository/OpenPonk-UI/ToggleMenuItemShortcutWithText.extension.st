Extension { #name : #ToggleMenuItemShortcutWithText }

{ #category : #'*OpenPonk-UI' }
ToggleMenuItemShortcutWithText >> drawOn: aCanvas [
	| keyBounds |
	
	keyBounds := self boundsForKeyText: self keyText font: self owner fontToUse.
	self owner
		drawText: keyText
		on: aCanvas
		in: keyBounds
		color: (self owner stringColorToUse alpha: 0.6)
]
