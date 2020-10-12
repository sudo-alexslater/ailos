extends Control

onready var disconnect_button = $Rows/ButtonCenter/Buttons/DisconnectButton
onready var game_state_manager = get_node('/root/GameStateManager')
onready var network = get_node('/root/Networking')

func _on_ResumeButton_pressed():
	game_state_manager.paused = false
	hide_view()

func _on_ExitButton_pressed():
	game_state_manager.exit_game()

func _on_DisconnectButton_pressed():
	network.stop_networking()
	hide_view()

func hide_view():
	disconnect_button.hide()
	visible = false

func show_view():
	game_state_manager.paused = true
	visible = true
	if(get_tree().network_peer):
		disconnect_button.visible = true

func toggle_view():
	if(visible):
		hide_view()
	else:
		show_view()