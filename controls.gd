extends Node

func _ready():
	populate_controls()

func populate_controls():
	var all_actions = InputMap.get_actions()
	var actions_to_modify = []
	for action in all_actions:
		if not action.begins_with("ui_"):
			actions_to_modify.append(action)
	for id in range(Constants.MAX_PLAYERS):
		for action in actions_to_modify:
			var events = InputMap.action_get_events(action)
			var new_action = "{0}_{1}".format([action, id])
			var deadzone = InputMap.action_get_deadzone(action)
			InputMap.add_action(new_action)
			InputMap.action_set_deadzone(action, deadzone)
			for event in events:
				var new_event: InputEvent
				if event is InputEventJoypadButton:
					new_event = InputEventJoypadButton.new()
					new_event.button_index = event.button_index
				elif event is InputEventJoypadMotion:
					new_event = InputEventJoypadMotion.new()
					new_event.axis = event.axis
					new_event.axis_value = event.axis_value
				new_event.device = id
				InputMap.action_add_event(new_action, new_event)
	for action in actions_to_modify:
		InputMap.erase_action(action)
