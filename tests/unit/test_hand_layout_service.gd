extends GutTest

var hand_layout_service:GCardHandLayoutService

func before_each():
	hand_layout_service = autofree(partial_double(GCardHandLayoutService).new())
	
func test_example():
	assert_false(false)

func test_1_card():
	hand_layout_service.number_of_cards = 1
	var layouts := hand_layout_service.get_card_layouts()
	var layout:GCardLayoutInfo = layouts.front()
	assert_almost_eq(layout.position, Vector2(0, 0), Vector2(0.01, 0.01))
	assert_almost_eq(layout.rotation, 0.0, 0.01)

func test_2_cards():
	var radius := 100.0
	hand_layout_service.number_of_cards = 2
	hand_layout_service.circle_percentage = 0.1
	hand_layout_service.dynamic_radius = false
	hand_layout_service.radius = radius
	var total_angle := TAU*hand_layout_service.circle_percentage
	var step := total_angle/2.0
	var layouts := hand_layout_service.get_card_layouts()
	var layout1:GCardLayoutInfo = layouts.front()
	assert_almost_eq(layout1.position, Vector2(radius*cos(-step-PI/2), radius*sin(-step-PI/2)) + Vector2.DOWN * radius, Vector2(0.0001, 0.0001))
	assert_almost_eq(layout1.rotation, -step, 0.01)
	var layout2:GCardLayoutInfo = layouts.back()
	assert_almost_eq(layout2.position, Vector2(radius*cos(step-PI/2), radius*sin(step-PI/2)) + Vector2.DOWN * radius, Vector2(0.0001, 0.0001))
	assert_almost_eq(layout2.rotation, step, 0.01)

func test_3_cards():
	var radius := 100.0
	hand_layout_service.number_of_cards = 3
	hand_layout_service.circle_percentage = 0.1
	hand_layout_service.dynamic_radius = false
	hand_layout_service.radius = radius
	var total_angle := TAU*hand_layout_service.circle_percentage
	var initial_angle := -total_angle/2.0
	var step := total_angle/(hand_layout_service.number_of_cards-1)
	var layouts := hand_layout_service.get_card_layouts()
	var layout1:GCardLayoutInfo = layouts[0]
	assert_almost_eq(layout1.position, Vector2(radius*cos(initial_angle-PI/2), radius*sin(initial_angle-PI/2)) + Vector2.DOWN * radius, Vector2(0.0001, 0.0001))
	assert_almost_eq(layout1.rotation, initial_angle, 0.01)
	var layout2:GCardLayoutInfo = layouts[1]
	assert_almost_eq(layout2.position, Vector2(0, 0), Vector2(0.0001, 0.0001))
	assert_almost_eq(layout2.rotation, 0.0, 0.01)
	var layout3:GCardLayoutInfo = layouts[2]
	assert_almost_eq(layout3.position, Vector2(radius*cos(initial_angle + total_angle - PI/2), radius*sin(initial_angle + total_angle - PI/2)) + Vector2.DOWN * radius, Vector2(0.0001, 0.0001))
	assert_almost_eq(layout3.rotation, step, 0.01)

func test_hover_position():
	var radius := 100.0
	hand_layout_service.number_of_cards = 3
	hand_layout_service.circle_percentage = 0.1
	hand_layout_service.dynamic_radius = false
	hand_layout_service.radius = radius
	hand_layout_service.hovered_index = 0
	hand_layout_service.hover_relative_position = Vector2(0, -20)
	var total_angle := TAU*hand_layout_service.circle_percentage
	var initial_angle := -total_angle/2.0
	var step := total_angle/(hand_layout_service.number_of_cards-1)
	var layouts := hand_layout_service.get_card_layouts()
	# Hovered card goes up.
	var layout1:GCardLayoutInfo = layouts[0]
	assert_almost_eq(layout1.position, Vector2(radius*cos(initial_angle-PI/2), radius*sin(initial_angle-PI/2)) + Vector2.DOWN * radius + hand_layout_service.hover_relative_position, Vector2(0.0001, 0.0001))
	assert_almost_eq(layout1.rotation, 0.0, 0.01)
	# Unhovered card got pushed.
	var layout2:GCardLayoutInfo = layouts[1]
	assert_almost_eq(layout2.position, Vector2(0, 0) + Vector2.RIGHT*hand_layout_service.hover_padding, Vector2(0.0001, 0.0001))
	assert_almost_eq(layout2.rotation, 0.0, 0.01)
	var layout3:GCardLayoutInfo = layouts[2]
	assert_almost_eq(layout3.position, Vector2(radius*cos(initial_angle + total_angle - PI/2), radius*sin(initial_angle + total_angle - PI/2)) + Vector2.DOWN * radius + Vector2.RIGHT*hand_layout_service.hover_padding, Vector2(0.0001, 0.0001))
	assert_almost_eq(layout3.rotation, step, 0.01)
	
	# Change to a new hover
	hand_layout_service.hovered_index = 1
	hand_layout_service.hover_padding = 30
	layouts = hand_layout_service.get_card_layouts()
	# Hovered card goes up.
	layout2 = layouts[1]
	assert_almost_eq(layout2.rotation, 0.0, 0.01)
	# Unhovered card got pushed.
	layout1 = layouts[0]
	assert_almost_eq(layout1.position, Vector2(radius*cos(initial_angle-PI/2), radius*sin(initial_angle-PI/2)) + Vector2.DOWN * radius + Vector2.LEFT * hand_layout_service.hover_padding  , Vector2(0.0001, 0.0001))
	assert_almost_eq(layout1.rotation, initial_angle, 0.01)
	layout3 = layouts[2]
	assert_almost_eq(layout3.position, Vector2(radius*cos(initial_angle + total_angle - PI/2), radius*sin(initial_angle + total_angle - PI/2)) + Vector2.DOWN * radius + Vector2.RIGHT*hand_layout_service.hover_padding, Vector2(0.0001, 0.0001))
	assert_almost_eq(layout3.rotation, step, 0.01)

func test_recalculate_positions():
	hand_layout_service.number_of_cards = 1
	var layouts := hand_layout_service.get_card_layouts()
	assert_call_count(hand_layout_service, "recalculate_layouts", 1)
	hand_layout_service.number_of_cards = 2
	layouts = hand_layout_service.get_card_layouts()
	assert_call_count(hand_layout_service, "recalculate_layouts", 2)
	hand_layout_service.circle_percentage = 0.1
	layouts = hand_layout_service.get_card_layouts()
	assert_call_count(hand_layout_service, "recalculate_layouts", 3)
	hand_layout_service.dynamic_radius_factor = 500
	layouts = hand_layout_service.get_card_layouts()
	assert_call_count(hand_layout_service, "recalculate_layouts", 4)
	hand_layout_service.dynamic_radius = false
	layouts = hand_layout_service.get_card_layouts()
	assert_call_count(hand_layout_service, "recalculate_layouts", 5)
	hand_layout_service.radius = 9999
	layouts = hand_layout_service.get_card_layouts()
	assert_call_count(hand_layout_service, "recalculate_layouts", 6)


func test_do_not_recalculate_positions():
	hand_layout_service.number_of_cards = 1
	hand_layout_service.hovered_index = 0
	hand_layout_service.hover_padding = 15
	var layouts := hand_layout_service.get_card_layouts()
	assert_call_count(hand_layout_service, "recalculate_layouts", 1)
	
	hand_layout_service.hovered_index = 0
	hand_layout_service.hover_padding = 20
	layouts = hand_layout_service.get_card_layouts()
	assert_call_count(hand_layout_service, "recalculate_layouts", 1)  #Only once for the first time
