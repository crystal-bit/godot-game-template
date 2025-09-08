## Provides functionalities to return a list of [GCardLayoutInfo]s that form a hand layout.[br][br]
## Use this class if you want to create your custom hand layout node, or use [GCardHandLayout] for a out-of-box solution.[br][br]
## To use this class, set up all the parameters as desired then call [method get_card_layouts].
class_name GCardHandLayoutService
extends RefCounted

## How many cards to display.[br][br]
## This value should be greater than 0.[br][br]
## Update this value will cause [method recalculate_layouts] to be called when calling [method get_card_layouts].
var number_of_cards:int: set = _set_number_of_cards
## Set radius dynamically based on the [memeber number_of_cards]. ([member radius] = [member dynamic_radius_factor] * number_of_cards).[br][br]
## If [b]true[/b], [member radius] is ignored.[br]
## Update this value will cause [method recalculate_layouts] to be called when calling [method get_card_layouts].
var dynamic_radius := true: set = _set_dynamic_radius
## If [member dynamic_radius] is [br]true[/br], this value is used to compute the radius to create the curve based on [memeber number_of_cards].[br]
## A bigger value creates a flatter curve and more seperation between the cards.[br][br]
## If [member dynamic_radius] is [br]false[/br], this is ignored.
## Update this value will cause [method recalculate_layouts] to be called when calling [method get_card_layouts].
var dynamic_radius_factor:float = 100.0: set = _set_dynamic_radius_factor
## A fixed radius used to create the curve.[br][br]
## If [member dynamic_radius] is [b]true[/b], this is ignored.
## Update this value will cause [method recalculate_layouts] to be called when calling [method get_card_layouts].
var radius := 1000.0: set = _set_radius
## Determines how much of a circle to use for the curve.[br][br]
## A value of [b]0.0[/b] creates a point, and a value of [b]1.0[/b] creates a full circle.
## Usually a value between [b]0.1[/b] and [b]0.03[/b] is suitable for a card hand layout.
## Update this value will cause [method recalculate_layouts] to be called when calling [method get_card_layouts].
var circle_percentage:float = 0.05: set = _set_circle_percentage
## The card index that is currently being hovered.[br][br]
## Unhovered card will move left or right for [member hover_padding] pixels.[br][br]
var hovered_index := -1
## How much pixels do un-hovered card move away from the hovered card.[br][br]
## The cards to the left of the hovered card move to the left, the cards to the right move to the right.[br][br]
var hover_padding := 15.0
## The relative position of the card when being hovered.
var hover_relative_position:Vector2

var _need_recalculate_curve:bool = true
var _base_layout_infos:Array[GCardLayoutInfo] = []

## Get a list of card layouts.[br][br]
## Updating some member variables will cause [method recalculate_layouts] to be called.[br]
## This is a convinient method to use that combines [method recalculate_layouts] and [method sample_curve].
func get_card_layouts() -> Array[GCardLayoutInfo]:
	if _need_recalculate_curve:
		recalculate_layouts()
	return sample_curve()

## Recalcualte the layouts and cache it for [method sample_curve] to use.[br][br]
## This method should be called if some variables are updated, see documentation for individual member variables for details.[br][br]
## In most of the cases, calling [method get_card_layouts] is enough. This method is only for more advanced users who want more control over optimization.
func recalculate_layouts():
	_base_layout_infos.clear()
	if dynamic_radius:
		radius = number_of_cards*dynamic_radius_factor
	var total_degree := TAU * circle_percentage
	var initial_angle := - PI/2
	var step := 0.0
	if number_of_cards > 1:
		initial_angle -= total_degree/2.0
		step = total_degree/float(number_of_cards-1)
	var origin := Vector2.DOWN*radius #Add Vector2.DOWN * radius to set the curve to center around (0,0)
	for i in number_of_cards:
		# Calculate the angle for this point on the circle
		var angle := initial_angle
		if number_of_cards > 1:
			angle += step * i
		# Calculate the x and y coordinates of the point on the circle
		var x = radius * cos(angle)
		var y = radius * sin(angle)
		# Add the point to the curve
		var layout_info := GCardLayoutInfo.new()
		layout_info.position = Vector2(x, y) + origin
		layout_info.rotation = angle + PI/2
		_base_layout_infos.append(layout_info)
	_need_recalculate_curve = false

## Get the layout information based on the layouts calcualted by [method recalculate_layouts].[br][br]
## Must call [method recalculate_layouts] at least once before the first call of [method sample_curve].[br][br]
## In most of the cases, calling [method get_card_layouts] is enough. This method is only for more advanced users who want more control over optimization.
func sample_curve() -> Array[GCardLayoutInfo]:
	var result:Array[GCardLayoutInfo] = []
	var number_of_intervals := max(number_of_cards-1, 1)
	for i in number_of_cards:
		var layout_info := GCardLayoutInfo.new()
		layout_info.copy(_base_layout_infos[i])
		if i == hovered_index:
			layout_info.position += hover_relative_position
			layout_info.rotation = 0
		elif hovered_index != -1:
			var i_diff := i - hovered_index
			if i_diff < 0:
				# Cards left to the hovered card.
				layout_info.position.x -= hover_padding
			else:
				layout_info.position.x += hover_padding
				# Cards right to the hovered card.
		result.append(layout_info)
	return result

func _set_dynamic_radius(val:bool):
	dynamic_radius = val
	_need_recalculate_curve = true

func _set_dynamic_radius_factor(val:float):
	dynamic_radius_factor = val
	_need_recalculate_curve = true
	
func _set_radius(val:float):
	radius = val
	_need_recalculate_curve = true

func _set_number_of_cards(val:int):
	number_of_cards = val
	_need_recalculate_curve = true

func _set_circle_percentage(val:float):
	circle_percentage = val
	_need_recalculate_curve = true
