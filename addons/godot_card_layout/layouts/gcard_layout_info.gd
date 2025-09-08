## Represents layout information for a card.
class_name GCardLayoutInfo
extends RefCounted

var position:Vector2
var rotation:float

func copy(other:GCardLayoutInfo):
	position = other.position
	rotation = other.rotation
