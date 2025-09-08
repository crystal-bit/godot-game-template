extends GutTest

var hand_layout:GCardHandLayout
var _sender = InputSender.new(Input)

func before_each():
	hand_layout = autofree(partial_double(GCardHandLayout).new())
	watch_signals(hand_layout)
	hand_layout.animation_time = -1.0

func after_each():
	_sender.release_all()
	_sender.clear()

func test_reset_positions_on_child_order_change():
	add_child(hand_layout)
	for i in 5:
		var card:Control = autofree(Control.new())
		hand_layout.add_child(card)
	assert_call_count(hand_layout, "_reset_positions", 5)
	
	hand_layout.remove_child(hand_layout.get_children().front())
	assert_call_count(hand_layout, "_reset_positions", 6)

func test_reset_position_on_ready():
	for i in 5:
		var card:Control = autofree(Control.new())
		hand_layout.add_child(card)
	add_child(hand_layout)
	assert_call_count(hand_layout, "_reset_positions", 1)

func test_reset_position_on_card_hover():
	for i in 5:
		var card:Control = autofree(Control.new())
		hand_layout.add_child(card)
	add_child(hand_layout)
	assert_call_count(hand_layout, "_reset_positions", 1)
	var gcard:Control = hand_layout.get_children().front()
	var position_before_hover := gcard.position
	gcard.size = Vector2(100, 100)
	stub(hand_layout, "_get_global_mouse_position_for_interaction").to_return(gcard.position+Vector2.ONE)
	gcard.mouse_entered.emit()
	assert_call_count(hand_layout, "_on_child_mouse_entered", 1)
	gut.simulate(hand_layout, 1, .1)
	assert_call_count(hand_layout, "_reset_positions", 2)
	assert_almost_eq(gcard.position, position_before_hover+hand_layout.hover_relative_position, Vector2(0.01, 0.01))
	assert_almost_eq(gcard.scale, hand_layout.hovered_scale, Vector2(0.01, 0.01))
	assert_signal_emitted(hand_layout, "card_hoverd")

func test_reset_position_on_card_unhover():
	for i in 5:
		var card:Control = autofree(Control.new())
		hand_layout.add_child(card)
	add_child(hand_layout)
	assert_call_count(hand_layout, "_reset_positions", 1)
	var gcard:Control = hand_layout.get_children().front()
	var position_before_hover := gcard.position
	gcard.size = Vector2(100, 100)
	stub(hand_layout, "_get_global_mouse_position_for_interaction").to_return(gcard.position+Vector2.ONE)
	gcard.mouse_entered.emit()
	assert_call_count(hand_layout, "_on_child_mouse_entered", 1)
	gut.simulate(hand_layout, 1, .1)
	assert_call_count(hand_layout, "_reset_positions", 2)
	
	stub(hand_layout, "_get_global_mouse_position_for_interaction").to_return(gcard.position+Vector2(150, 150))
	gcard.mouse_exited.emit()
	assert_call_count(hand_layout, "_on_child_mouse_exited", 1)
	gut.simulate(hand_layout, 1, .1)
	assert_call_count(hand_layout, "_reset_positions", 3)
	assert_almost_eq(gcard.position, position_before_hover, Vector2(0.01, 0.01))
	assert_almost_eq(gcard.scale, Vector2.ONE, Vector2(0.01, 0.01))
	assert_signal_emitted(hand_layout, "cards_unhovered")

func test_reset_position_on_card_drag():
	hand_layout.enable_dragging = true
	for i in 5:
		var card:Control = autofree(Control.new())
		hand_layout.add_child(card)
	add_child(hand_layout)
	assert_call_count(hand_layout, "_reset_positions", 1)
	var gcard:Control = hand_layout.get_children().front()
	gcard.size = Vector2(100, 100)
	stub(hand_layout, "_get_global_mouse_position_for_interaction").to_return(gcard.position+Vector2.ONE)
	var event = InputFactory.mouse_left_button_down(gcard.position, gcard.global_position)
	var sender = InputSender.new(gcard)
	sender.send_event(event)
	assert_eq(hand_layout._dragging_index, 0)
	assert_call_count(hand_layout, "_reset_positions", 3)
	assert_signal_emitted(hand_layout, "card_dragging_started")
	assert_almost_eq(gcard.scale, hand_layout.dragging_scale, Vector2(0.01, 0.01))
	assert_almost_eq(gcard.rotation, 0.0, 0.01)

func test_reset_position_on_card_release_drag():
	hand_layout.enable_dragging = true
	for i in 5:
		var card:Control = autofree(Control.new())
		hand_layout.add_child(card)
	add_child(hand_layout)
	assert_call_count(hand_layout, "_reset_positions", 1)
	var gcard:Control = hand_layout.get_children().front()
	var gcard_rotation := gcard.rotation
	gcard.size = Vector2(100, 100)
	stub(hand_layout, "_get_global_mouse_position_for_interaction").to_return(gcard.position+Vector2.ONE)
	var event = InputFactory.mouse_left_button_down(gcard.position, gcard.global_position)
	var sender = InputSender.new(gcard)
	sender.send_event(event)
	assert_eq(hand_layout._dragging_index, 0)
	assert_call_count(hand_layout, "_reset_positions", 3) #_reset_positions called because hover_index changed
	assert_signal_emitted(hand_layout, "card_dragging_started")
	assert_almost_eq(gcard.rotation, 0.0, 0.01)
	
	var event_mouse_button_up = InputFactory.mouse_left_button_up(gcard.position, gcard.global_position)
	sender.send_event(event_mouse_button_up)
	assert_eq(hand_layout._dragging_index, -100)
	assert_signal_emitted(hand_layout, "card_dragging_finished")
	gut.simulate(hand_layout, 1, .1)
	assert_almost_eq(gcard.scale, Vector2.ONE, Vector2(0.01, 0.01))
	assert_almost_eq(gcard.rotation, gcard_rotation, 0.01)

func test_change_dynamic_radius_reset_position():
	var card:Control = autofree(Control).new()
	hand_layout.add_child(card)
	add_child(hand_layout)
	assert_call_count(hand_layout, "_reset_positions", 1)
	hand_layout.dynamic_radius = hand_layout.dynamic_radius
	assert_call_count(hand_layout, "_reset_positions", 1)
	hand_layout.dynamic_radius = !hand_layout.dynamic_radius
	assert_call_count(hand_layout, "_reset_positions", 2)

func test_change_dynamic_radius_ractor_reset_position():
	var card:Control = autofree(Control).new()
	hand_layout.add_child(card)
	add_child(hand_layout)
	assert_call_count(hand_layout, "_reset_positions", 1)
	hand_layout.dynamic_radius_factor = 10000
	assert_call_count(hand_layout, "_reset_positions", 2)

func test_change_radius_reset_position():
	hand_layout.dynamic_radius = !hand_layout.dynamic_radius
	var card:Control = autofree(Control).new()
	hand_layout.add_child(card)
	add_child(hand_layout)
	assert_call_count(hand_layout, "_reset_positions", 1)
	hand_layout.radius = 100000
	assert_call_count(hand_layout, "_reset_positions", 2)

func test_change_circle_percentarge_reset_position():
	var card:Control = autofree(Control).new()
	hand_layout.add_child(card)
	add_child(hand_layout)
	assert_call_count(hand_layout, "_reset_positions", 1)
	hand_layout.circle_percentage = 1.0
	assert_call_count(hand_layout, "_reset_positions", 2)

func test_change_enable_hover_reset_position():
	var card:Control = autofree(Control).new()
	hand_layout.add_child(card)
	add_child(hand_layout)
	assert_call_count(hand_layout, "_reset_positions", 1)
	hand_layout.enable_hover = false # Does not trigger repositioning
	assert_call_count(hand_layout, "_reset_positions", 1)
	
func test_change_hovered_index_reset_position():
	var card:Control = autofree(Control).new()
	hand_layout.add_child(card)	
	add_child(hand_layout)
	assert_call_count(hand_layout, "_reset_positions", 1)
	hand_layout.hovered_index = 0
	assert_call_count(hand_layout, "_reset_positions", 2)

func test_change_hovered_padding_reset_position():
	var card:Control = autofree(Control).new()
	hand_layout.add_child(card)	
	add_child(hand_layout)
	assert_call_count(hand_layout, "_reset_positions", 1)	
	hand_layout.hover_padding = 60
	assert_call_count(hand_layout, "_reset_positions", 2)

func test_change_animation_time_DONOT_reset_position():
	var card:Control = autofree(Control).new()
	hand_layout.add_child(card)	
	add_child(hand_layout)
	assert_call_count(hand_layout, "_reset_positions", 1)	
	hand_layout.animation_time = 0.2  # Does not trigger repositioning
	assert_call_count(hand_layout, "_reset_positions", 1)

func test_change_animation_ease_DONOT_reset_position():
	var card:Control = autofree(Control).new()
	hand_layout.add_child(card)	
	add_child(hand_layout)
	assert_call_count(hand_layout, "_reset_positions", 1)	
	hand_layout.animation_ease = Tween.EASE_OUT  # Does not trigger repositioning
	assert_call_count(hand_layout, "_reset_positions", 1)

func test_change_animation_trans_DONOT_reset_position():
	var card:Control = autofree(Control).new()
	hand_layout.add_child(card)	
	add_child(hand_layout)
	assert_call_count(hand_layout, "_reset_positions", 1)	
	hand_layout.animation_trans = Tween.TRANS_SINE  # Does not trigger repositioning
	assert_call_count(hand_layout, "_reset_positions", 1)

func test_change_hover_sound_DONOT_reset_position():
	var card:Control = autofree(Control).new()
	hand_layout.add_child(card)	
	add_child(hand_layout)
	assert_call_count(hand_layout, "_reset_positions", 1)	
	hand_layout.hover_sound = autofree(AudioStreamPlayer2D.new()) # Does not trigger repositioning
	assert_call_count(hand_layout, "_reset_positions", 1)

func test_change_enable_dragging_DONOT_reset_position():
	var card:Control = autofree(Control).new()
	hand_layout.add_child(card)	
	add_child(hand_layout)
	assert_call_count(hand_layout, "_reset_positions", 1)	
	hand_layout.enable_dragging = !hand_layout.enable_dragging # Does not trigger repositioning
	assert_call_count(hand_layout, "_reset_positions", 1)
#
func test_change_dragging_scale_DONOT_reset_position():
	var card:Control = autofree(Control).new()
	hand_layout.add_child(card)	
	add_child(hand_layout)
	assert_call_count(hand_layout, "_reset_positions", 1)	
	hand_layout.dragging_scale = Vector2(500, 500) # Does not trigger repositioning
	assert_call_count(hand_layout, "_reset_positions", 1)

func test_change_hover_relative_position_reset_position():
	var card:Control = autofree(Control).new()
	hand_layout.add_child(card)	
	add_child(hand_layout)
	assert_call_count(hand_layout, "_reset_positions", 1)	
	hand_layout.hover_relative_position = Vector2(100, 100)
	assert_call_count(hand_layout, "_reset_positions", 2)
