@tool
@icon("res://addons/godot_card_layout/resources/icons/hand_layout_icon.svg")
## A node to help layout [Control] nodes in a hand layout.[br][br]
## Simply add [Control]s as children to form the layout. Adding other nodes as children cause undefined behavior.
## [b]Important[/b]: Set the x value of pivot offset of the card object to card object's size/2 to correctly align the cards
## To make the layout more customized, create a custom control scene and use [GCardHandLayoutService] as a helper.
class_name GCardHandLayout
extends Control

## Emits when a card is hovered.
signal card_hoverd(card:Control, index:int)
## Emits when all the cards are unhovered.
signal cards_unhovered()
## Emits when a card starts being dragged.
signal card_dragging_started(card:Control, index:int)
## Emits when a dragged card is released.
signal card_dragging_finished(card:Control, index:int)

@export_group("idle layout")
## Set radius dynamically based on the number of cards. ([member radius] = [member dynamic_radius_factor] * number_of_cards).[br][br]
## If [b]true[/b], [member radius] is ignored.
@export var dynamic_radius := true: set = _set_dynamic_radius
## If [member dynamic_radius] is [br]true[/br], this value is used to compute the radius to create the curve based on the number of cards.[br]
## A bigger value creates a flatter curve and more seperation between the cards.[br][br]
## If [member dynamic_radius] is [br]false[/br], this is ignored.
@export var dynamic_radius_factor:float = 100.0: set = _set_dynamic_radius_factor
## A fixed radius used to create the curve.[br][br]
## If [member dynamic_radius] is [b]true[/b], this is ignored.
@export var radius := 1000.0: set = _set_radius
## Determines how much of a circle to use for the curve.[br][br]
## A value of [b]0.0[/b] creates a point, and a value of [b]1.0[/b] creates a full circle.
## Usually a value between [b]0.1[/b] and [b]0.03[/b] is suitable for a card hand layout.
@export var circle_percentage:float = 0.05: set = _set_circle_percentage

@export_group("hover")
## Whether this layout node should handle hover animation.[br][br]
## Every parameter under the [b]hover[/b] section is ignored when this is [b]false[/b]
@export var enable_hover := true: set = _set_enable_hover
## The card index that is currently being hovered.[br][br]
## This is useful when testing layout in the inspector.[br][br]
@export var hovered_index := -1: set = _set_hovered_index
## How much pixels do un-hovered card move away from the hovered card.[br][br]
## The cards to the left of the hovered card move to the left, the cards to the right move to the right.[br][br]
@export var hover_padding := 40.0: set = _set_hover_padding
## The scale of the card when it is hovered.
@export var hovered_scale := Vector2(1.1, 1.1): set = _set_hovered_scale
## The relative position of the card when being hovered.
@export var hover_relative_position := Vector2(0, -20): set = _set_hover_relative_position

@export_group("dragging")
## Enable dragging and drop the cards.(Beta)[br][br]
##
## [b]false[/b] by default.
## @experimental
@export var enable_dragging := false: set = _set_enable_dragging
## The scale of the card is being dragged.[br][br]
## Ignored when [member enable_dragging] is [b]false[/b]
@export var dragging_scale := Vector2(1.1, 1.1)

@export_group("animation") 
## The duration of all the animation related to layout, e.g. hover, reset position. [br][br]
## When value is set to [br]0.0[/br], animations are disabled.
@export var animation_time := 0.1: set = _set_animation_time
## The ease used for the animations.
@export var animation_ease := Tween.EASE_IN
## The trans used for the animations.
@export var animation_trans := Tween.TRANS_QUAD

@export_group("sounds")
## Plays when a card is hovered.
@export var hover_sound:AudioStreamPlayer2D

var gcard_hand_layout_service := GCardHandLayoutService.new()
var _reset_position_tween:Tween
var _mouse_in:bool = false
var _dragging_card:Control
var _dragging_index:int = -100
var _dragging_mouse_position:Vector2

func _ready():
	_dragging_index = -100
	child_order_changed.connect(_on_child_order_changed)
	_setup_cards()
	if get_child_count() > 0:
		_reset_positions_if_in_tree(false, false)

func _process(delta):
	if Engine.is_editor_hint() || !enable_hover && !_dragging_card:
		return
	var old_hovered_index = hovered_index
	if _dragging_card:
		assert(enable_dragging)
		_dragging_card.global_position = _get_global_mouse_position_for_interaction() - _dragging_mouse_position
	elif _mouse_in:
		assert(enable_hover)
		var mouse_position = _get_global_mouse_position_for_interaction()
		var new_hover_index := _find_card_index_with_point(mouse_position)
		if hovered_index != new_hover_index:
			hovered_index = new_hover_index
	elif hovered_index != -1:
		hovered_index = -1
	
func _enter_tree():
	if is_node_ready() && get_child_count() > 0:
		_reset_positions_if_in_tree(false, false)
	
func _validate_property(property):
	if property.name in ["radius"] && dynamic_radius:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name in ["dynamic_radius_factor"] && !dynamic_radius:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name in ["hovered_index", "hover_padding", "hovered_scale", "hover_relative_position"] && !enable_hover:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name in ["dragging_scale"] && !enable_dragging:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	if property.name in ["animation_ease", "animation_trans"] && animation_time <= 0.0:
		property.usage = PROPERTY_USAGE_NO_EDITOR
	
func _reset_positions_if_in_tree(reculculate_curve:bool = false, animated:bool = true):
	if is_inside_tree():
		_reset_positions(reculculate_curve, animated)

func _reset_positions(reculculate_curve:bool = false, animated:bool = true):
	var number_of_cards := get_child_count()
	if _dragging_card && _dragging_card.get_parent() == self:
		number_of_cards -= 1
	gcard_hand_layout_service.number_of_cards = number_of_cards
	gcard_hand_layout_service.dynamic_radius = dynamic_radius
	gcard_hand_layout_service.dynamic_radius_factor = dynamic_radius_factor
	gcard_hand_layout_service.radius = radius
	gcard_hand_layout_service.circle_percentage = circle_percentage
	gcard_hand_layout_service.hover_padding = hover_padding
	gcard_hand_layout_service.hovered_index = hovered_index
	gcard_hand_layout_service.hover_relative_position = hover_relative_position
	var should_animate := animation_time > 0.0 && animated && number_of_cards > 0 && is_inside_tree()
	var layout_infos := gcard_hand_layout_service.get_card_layouts()
	var position_index := 0
	if _reset_position_tween && _reset_position_tween.is_running():
		_reset_position_tween.stop()
	if should_animate:
		_reset_position_tween = create_tween()
	for i in get_child_count():
		var card:Control = get_children()[i]
		var target_scale = Vector2.ONE
		var target_position:Vector2
		var target_rotation := 0.0
		if i == _dragging_index:
			target_scale = dragging_scale
		else:
			var layout_info:GCardLayoutInfo = layout_infos[position_index]
			target_position = layout_info.position
			target_rotation = layout_info.rotation
			if i == hovered_index:
				target_rotation = 0
				target_scale = hovered_scale
		if !should_animate:
			if i != _dragging_index:
				card.position = target_position
			card.rotation = target_rotation
			card.scale = target_scale
		else:
			if i != _dragging_index:
				_reset_position_tween.parallel().tween_property(card, "position", target_position, animation_time).set_ease(animation_ease).set_trans(animation_trans)
			_reset_position_tween.parallel().tween_property(card, "rotation", target_rotation, animation_time).set_ease(animation_ease).set_trans(animation_trans)
			_reset_position_tween.parallel().tween_property(card, "scale", target_scale, animation_time).set_ease(animation_ease).set_trans(animation_trans)
		if i != _dragging_index:
			position_index += 1
	if should_animate:
		_reset_position_tween.play()

func _setup_cards():
	for child in get_children():
		var card = child as Control
		if card.mouse_entered.is_connected(_on_child_mouse_entered):
			continue
		card.mouse_entered.connect(_on_child_mouse_entered)
		card.mouse_exited.connect(_on_child_mouse_exited)
		card.gui_input.connect(_on_child_gui_input.bind(card))

func _find_card_index_with_point(global_point:Vector2) -> int:
	var intercepting_card:Control
	for i in range(get_child_count()-1, -1, -1):
		var card = get_children()[i] as Control
		if card.get_global_rect().has_point(global_point):
			return i
	return -1
			
func _set_dynamic_radius(val:bool):
	if dynamic_radius == val:
		return
	dynamic_radius = val
	notify_property_list_changed()
	_reset_positions_if_in_tree()

func _set_dynamic_radius_factor(val:float):
	dynamic_radius_factor = val
	_reset_positions_if_in_tree()

func _set_radius(val:float):
	radius = val
	_reset_positions_if_in_tree()
	
func _set_circle_percentage(val:float):
	circle_percentage = val
	_reset_positions_if_in_tree()

func _set_enable_hover(val:bool):
	enable_hover = val
	notify_property_list_changed()

func _set_hovered_index(val:int):
	hovered_index = val
	if hovered_index >= get_child_count():
		return
	_reset_positions_if_in_tree()
	var card:Control = null
	if hovered_index >= 0:
		if hover_sound:
			hover_sound.play()
		card = get_children()[hovered_index]
	if hovered_index >= 0:
		card_hoverd.emit(card, hovered_index)
	else:
		cards_unhovered.emit()

func _set_hover_padding(val:float):
	hover_padding = val
	_reset_positions_if_in_tree()

func _set_hovered_scale(val:Vector2):
	hovered_scale = val
	_reset_positions_if_in_tree()

func _set_hover_relative_position(val:Vector2):
	hover_relative_position = val
	_reset_positions_if_in_tree()

func _set_enable_dragging(val:bool):
	enable_dragging = val
	notify_property_list_changed()

func _set_animation_time(val:float):
	animation_time = val
	notify_property_list_changed()

func _get_global_mouse_position_for_interaction():
	return get_global_mouse_position()

func _on_child_mouse_entered():
	if _dragging_card:
		return
	_mouse_in = true

func _on_child_mouse_exited():
	if _dragging_card:
		return
	_mouse_in = false

func _on_child_order_changed():
	_setup_cards()
	_reset_positions_if_in_tree()

func _on_child_gui_input(event:InputEvent, card:Control):
	if !enable_dragging:
		return
	if event is InputEventMouseButton:
		var mouse_button_event = event as InputEventMouseButton
		if card.get_parent() != self:
			_dragging_index == -1
		else:
			_dragging_index = get_children().find(card)
		if mouse_button_event.pressed && mouse_button_event.button_index == MOUSE_BUTTON_LEFT:
			_dragging_card = card
			_dragging_mouse_position = card.get_local_mouse_position()
			_dragging_card.z_index = 1
			hovered_index = -1 #Set hover index without trigger relayout
			card_dragging_started.emit(_dragging_card, _dragging_index)
			_reset_positions_if_in_tree()
		elif !mouse_button_event.pressed && mouse_button_event.button_index == MOUSE_BUTTON_LEFT:
			assert(_dragging_card == card)
			_dragging_card = null
			card.z_index = 0
			card_dragging_finished.emit(card, _dragging_index)
			_dragging_index = -100
			_reset_positions_if_in_tree()
