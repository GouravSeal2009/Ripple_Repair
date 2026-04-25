extends Node2D

const COLS := 15
const ROWS := 10
const MAX_FALLOUT := 100.0
const UI_BG := Color("#060910")
const UI_PANEL := Color("#0b1220")
const UI_PANEL_ALT := Color("#0f1728")
const UI_BORDER := Color("#25445a")
const UI_TEXT := Color("#f5f7fb")
const UI_MUTED := Color("#aeb9c8")
const UI_TEAL := Color("#78f0e1")
const UI_RED := Color("#f11115")
const UI_RED_DARK := Color("#a8290a")

enum Tile { FLOOR, WALL, CRACK, HOLE, VENT, SHORT, WATER, DOOR }

const TYPE_DATA := {
	"pressure": {
		"label": "Pressure Valve",
		"color": Color("#62d6c4"),
		"preview": "vents burst open and launch you upward without warning"
	},
	"power": {
		"label": "Power Junction",
		"color": Color("#ffbe5c"),
		"preview": "shorts spread into nearby wiring"
	},
	"support": {
		"label": "Support Clamp",
		"color": Color("#9ce66f"),
		"preview": "the floor accepts the stress, then cracks"
	},
	"automation": {
		"label": "AI Terminal",
		"color": Color("#ff6b63"),
		"preview": "maintenance units wake up with bad priorities"
	},
	"coolant": {
		"label": "Coolant Pump",
		"color": Color("#77a7ff"),
		"preview": "coolant leaks through the safest paths and slows you down"
	},
	"doors": {
		"label": "Bulkhead Relay",
		"color": Color("#d7a2ff"),
		"preview": "some doors open while better doors close"
	},
}

const LEVELS := [
	{
		"name": "Lesson Wing",
		"intro": "Three repairs, three side effects. Learn to read the room before you save it.",
		"start": Vector2i(1, 1),
		"fallout": 0.0,
		"map": [
			"###############",
			"#.....#.......#",
			"#.....#.......#",
			"#.............#",
			"#.....###.....#",
			"#.............#",
			"#.......#.....#",
			"#.............#",
			"#.............#",
			"###############",
		],
		"problems": [
			{"pos": Vector2i(12, 1), "type": "pressure"},
			{"pos": Vector2i(3, 7), "type": "power"},
			{"pos": Vector2i(11, 7), "type": "support"},
		],
	},
	{
		"name": "Civic Core",
		"intro": "Now the fixes start talking to each other. A good repair order matters.",
		"start": Vector2i(1, 8),
		"fallout": 8.0,
		"map": [
			"###############",
			"#.....#.......#",
			"#.....#...#...#",
			"#.........#...#",
			"###D####..#...#",
			"#.........#...#",
			"#...#.........#",
			"#...#.....#...#",
			"#.........#...#",
			"###############",
		],
		"problems": [
			{"pos": Vector2i(2, 1), "type": "doors"},
			{"pos": Vector2i(11, 1), "type": "coolant"},
			{"pos": Vector2i(8, 5), "type": "automation"},
			{"pos": Vector2i(4, 8), "type": "power"},
		],
	},
	{
		"name": "Verdict Reactor",
		"intro": "Midway through the station, every successful fix starts costing twice.",
		"start": Vector2i(1, 5),
		"fallout": 18.0,
		"map": [
			"###############",
			"#.....#.......#",
			"#.....#.......#",
			"#.........#...#",
			"#.###D###.#...#",
			"#.........#...#",
			"#...#.........#",
			"#...#.....#...#",
			"#.........#...#",
			"###############",
		],
		"problems": [
			{"pos": Vector2i(5, 1), "type": "pressure"},
			{"pos": Vector2i(12, 2), "type": "support"},
			{"pos": Vector2i(2, 7), "type": "coolant"},
			{"pos": Vector2i(8, 8), "type": "doors"},
			{"pos": Vector2i(11, 6), "type": "automation"},
		],
	},
	{
		"name": "Drift Spine",
		"intro": "The station starts fighting back. Safer paths disappear the moment you trust them.",
		"start": Vector2i(1, 7),
		"fallout": 24.0,
		"map": [
			"###############",
			"#......#......#",
			"#..##..#..#...#",
			"#......#..#...#",
			"#..D..........#",
			"#..##..###....#",
			"#......#......#",
			"#..#...#...#..#",
			"#......#......#",
			"###############",
		],
		"problems": [
			{"pos": Vector2i(2, 1), "type": "pressure"},
			{"pos": Vector2i(10, 1), "type": "coolant"},
			{"pos": Vector2i(12, 4), "type": "automation"},
			{"pos": Vector2i(5, 6), "type": "power"},
			{"pos": Vector2i(10, 7), "type": "doors"},
			{"pos": Vector2i(3, 8), "type": "support"},
		],
	},
	{
		"name": "Escape Lattice",
		"intro": "One last lattice of bad decisions. The room will not forgive wasted motion.",
		"start": Vector2i(1, 8),
		"fallout": 30.0,
		"map": [
			"###############",
			"#.....#....#..#",
			"#.###.#.##.#..#",
			"#.....#....#..#",
			"#.###D###.....#",
			"#.....#..###..#",
			"#.##..#.......#",
			"#.....#.###...#",
			"#.............#",
			"###############",
		],
		"problems": [
			{"pos": Vector2i(2, 1), "type": "power"},
			{"pos": Vector2i(11, 1), "type": "pressure"},
			{"pos": Vector2i(4, 3), "type": "doors"},
			{"pos": Vector2i(12, 4), "type": "support"},
			{"pos": Vector2i(8, 6), "type": "automation"},
			{"pos": Vector2i(2, 8), "type": "coolant"},
			{"pos": Vector2i(10, 8), "type": "pressure"},
		],
	},
]

var grid: Array = []
var problems: Array = []
var drones: Array = []
var sparks: Array = []
var unstable: Array = []
var particles: Array = []
var consequence_markers: Array = []
var consequence_log: Array[String] = []
var vent_blasts: Array = []
var bg_ship_texture: Texture2D
var bg_satellite_texture: Texture2D
var bg_box_texture: Texture2D
var bg_trash_bag_texture: Texture2D
var bg_item_textures: Array[Texture2D] = []
var show_objective_arrow := true
var alarm_player: AudioStreamPlayer
var alarm_streams := {}

var level_index := 0
var player := Vector2i.ZERO
var player_from := Vector2i.ZERO
var player_lerp := 1.0
var fallout := 0.0
var repairs := 0
var move_cooldown := 0.0
var key_repeat_cooldown := 0.0
var repair_cooldown := 0.0
var vent_pull_cooldown := 0.0
var pulse := 0.0
var phase := "menu"
var message := "No fix is isolated."
var shake := 0.0

var cell_size := 48.0
var board_origin := Vector2.ZERO
var draw_offset := Vector2.ZERO

var ui_layer: CanvasLayer
var root_ui: Control
var top_panel: PanelContainer
var bottom_panel: PanelContainer
var chain_title: Label
var log_title: Label
var title_label: Label
var subtitle_label: Label
var fallout_label: Label
var problem_label: Label
var repair_label: Label
var repair_caption: Label
var objective_label: Label
var fallout_bar: ProgressBar
var problem_bar: ProgressBar
var repair_bar: ProgressBar
var meter_fills := {}
var status_label: Label
var log_label: Label
var banner_panel: PanelContainer
var banner_title: Label
var banner_text: Label
var legend_panel: PanelContainer
var overlay: PanelContainer
var overlay_title: Label
var overlay_text: Label
var overlay_button: Button
var menu_buttons: VBoxContainer
var menu_back_button: Button
var hint_label: Label
var tutorial_panel: PanelContainer
var tutorial_title: Label
var tutorial_text: Label
var tutorial_close_button: Button
var alert_panel: PanelContainer
var alert_icon: Label
var alert_title: Label
var alert_text: Label
var status_hold := 0.0
var tutorial_active := false
var tutorial_seen := {}
var banner_timer := 0.0
var alert_timer := 0.0
var screen_flash := 0.0
var screen_flash_color := Color.TRANSPARENT
var pending_next_level := -1
var restart_level_index := 0
var achievements := {}
var best_room_cleared := 0
var last_alert_title := ""
var last_alert_body := ""
var alert_color := Color("#ff3746")
const SAVE_PATH := "user://ripple_repair_progress.json"
var floating_props: Array = []
var active_vent_rows := {}
var top_row: HBoxContainer


func _ready() -> void:
	_apply_fullscreen()
	_load_background_assets()
	_build_alarm_player()
	_build_ui()
	_load_progress()
	_update_board_metrics()
	_layout_ui()
	_initialize_floating_props()
	_load_level(0, "menu")
	_show_intro_instructions()


func _process(delta: float) -> void:
	_update_board_metrics()
	_layout_ui()
	pulse += delta
	shake = maxf(0.0, shake - delta * 18.0)
	status_hold = maxf(0.0, status_hold - delta)
	banner_timer = maxf(0.0, banner_timer - delta)
	alert_timer = maxf(0.0, alert_timer - delta)
	screen_flash = maxf(0.0, screen_flash - delta * 2.6)
	if is_instance_valid(banner_panel):
		banner_panel.visible = banner_timer > 0.0 and phase == "playing"
	if is_instance_valid(alert_panel):
		alert_panel.visible = alert_timer > 0.0 and phase == "playing" and not tutorial_active
		if alert_timer > 0.0:
			var blink := 0.78 + sin(pulse * 22.0) * 0.22
			alert_panel.modulate = Color(1, 1, 1, blink)
	_update_floating_props(delta)
	_update_particles(delta)

	if phase == "playing":
		_update_tutorial()
		move_cooldown = maxf(0.0, move_cooldown - delta)
		key_repeat_cooldown = maxf(0.0, key_repeat_cooldown - delta)
		repair_cooldown = maxf(0.0, repair_cooldown - delta)
		vent_pull_cooldown = maxf(0.0, vent_pull_cooldown - delta)
		_update_drones(delta)
		_update_sparks(delta)
		_update_unstable(delta)
		_update_consequence_markers(delta)
		_update_vent_blasts(delta)
		_update_vent_flow()
		_read_grid_input()
		_update_context_line()
		_update_hud()
		if fallout >= MAX_FALLOUT:
			_end_game("Cascade Locked", "The consequences have merged into one impossible repair.")
		elif _remaining_problems() == 0:
			_complete_level()

	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if phase == "playing" or phase == "ended":
			_show_pause_menu()
		return
	if event.is_action_pressed("repair"):
		if tutorial_active:
			_hide_tutorial()
			return
		if phase == "playing":
			_try_repair()
		else:
			_advance_or_restart()
	elif event.is_action_pressed("restart"):
		if phase == "menu":
			_start_game()
		else:
			_restart_current_level()


func _build_ui() -> void:
	ui_layer = CanvasLayer.new()
	add_child(ui_layer)

	root_ui = Control.new()
	root_ui.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui_layer.add_child(root_ui)

	top_panel = _make_panel(Vector2(18, 16), Vector2(1244, 86))
	root_ui.add_child(top_panel)
	top_row = HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 10)
	top_panel.add_child(top_row)

	var brand := VBoxContainer.new()
	brand.custom_minimum_size = Vector2(280, 72)
	brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(brand)
	title_label = Label.new()
	title_label.text = "Ripple Repair"
	title_label.add_theme_font_size_override("font_size", 30)
	title_label.modulate = UI_TEXT
	brand.add_child(title_label)
	subtitle_label = Label.new()
	subtitle_label.text = "Every fix makes a new flaw."
	subtitle_label.modulate = UI_TEAL
	brand.add_child(subtitle_label)

	var fallout_meter := _make_meter(top_row, "Fallout", "0%")
	fallout_label = fallout_meter["value"]
	var problem_meter := _make_meter(top_row, "Problems", "0")
	problem_label = problem_meter["value"]
	var repair_meter := _make_meter(top_row, "Level", "0 / 3")
	repair_caption = repair_meter["caption"]
	repair_label = repair_meter["value"]
	objective_label = _make_meter(top_row, "Objective", "Inspect a glowing system")["value"]

	bottom_panel = _make_panel(Vector2(18, 682), Vector2(1244, 100))
	root_ui.add_child(bottom_panel)
	var bottom := HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 16)
	bottom_panel.add_child(bottom)

	var status_box := VBoxContainer.new()
	status_box.custom_minimum_size = Vector2(0, 88)
	status_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(status_box)
	chain_title = Label.new()
	chain_title.text = "YOUR NEXT ACTION"
	chain_title.modulate = UI_TEXT
	status_box.add_child(chain_title)
	status_label = Label.new()
	status_label.text = message
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.modulate = UI_MUTED
	status_box.add_child(status_label)
	hint_label = Label.new()
	hint_label.text = "Move: WASD / Arrows    Repair: Space / Enter    Restart: R    Menu: Esc"
	hint_label.modulate = UI_TEAL
	status_box.add_child(hint_label)

	var log_box := VBoxContainer.new()
	log_box.custom_minimum_size = Vector2(0, 88)
	log_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(log_box)
	log_title = Label.new()
	log_title.text = "CHAIN LOG"
	log_title.modulate = UI_TEXT
	log_box.add_child(log_title)
	log_label = Label.new()
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	log_label.modulate = UI_TEXT
	log_box.add_child(log_label)

	overlay = PanelContainer.new()
	overlay.position = Vector2(350, 130)
	overlay.size = Vector2(580, 540)
	overlay.add_theme_stylebox_override("panel", _panel_style(UI_PANEL_ALT.darkened(0.08), UI_TEAL, 2))
	root_ui.add_child(overlay)
	var panel := VBoxContainer.new()
	panel.custom_minimum_size = Vector2(540, 500)
	panel.add_theme_constant_override("separation", 16)
	overlay.add_child(panel)
	overlay_title = Label.new()
	overlay_title.add_theme_font_size_override("font_size", 46)
	panel.add_child(overlay_title)
	overlay_text = Label.new()
	overlay_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	overlay_text.modulate = UI_TEXT
	panel.add_child(overlay_text)
	menu_buttons = VBoxContainer.new()
	menu_buttons.add_theme_constant_override("separation", 10)
	panel.add_child(menu_buttons)
	overlay_button = Button.new()
	overlay_button.custom_minimum_size = Vector2(0, 48)
	_style_button(overlay_button, Color("#ff4d5c"))
	overlay_button.pressed.connect(_advance_or_restart)
	panel.add_child(overlay_button)
	menu_back_button = Button.new()
	menu_back_button.text = "Back"
	menu_back_button.custom_minimum_size = Vector2(0, 42)
	_style_button(menu_back_button, Color("#a9b4b4"))
	menu_back_button.pressed.connect(_show_main_menu)
	panel.add_child(menu_back_button)

	tutorial_panel = PanelContainer.new()
	tutorial_panel.position = Vector2(56, 176)
	tutorial_panel.size = Vector2(420, 220)
	tutorial_panel.add_theme_stylebox_override("panel", _panel_style(UI_PANEL_ALT, Color("#ffbe5c"), 2))
	root_ui.add_child(tutorial_panel)
	var tutorial_content := Control.new()
	tutorial_content.set_anchors_preset(Control.PRESET_FULL_RECT)
	tutorial_panel.add_child(tutorial_content)
	tutorial_close_button = Button.new()
	tutorial_close_button.text = "X"
	tutorial_close_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	tutorial_close_button.position = Vector2(-40, 10)
	tutorial_close_button.size = Vector2(28, 28)
	tutorial_close_button.custom_minimum_size = Vector2(28, 28)
	_style_button(tutorial_close_button, Color("#39465c"))
	tutorial_close_button.add_theme_font_size_override("font_size", 14)
	tutorial_close_button.pressed.connect(_hide_tutorial)
	var tutorial_margin := MarginContainer.new()
	tutorial_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	tutorial_margin.add_theme_constant_override("margin_left", 16)
	tutorial_margin.add_theme_constant_override("margin_top", 16)
	tutorial_margin.add_theme_constant_override("margin_right", 50)
	tutorial_margin.add_theme_constant_override("margin_bottom", 16)
	tutorial_content.add_child(tutorial_margin)
	tutorial_content.add_child(tutorial_close_button)
	var tutorial_box := VBoxContainer.new()
	tutorial_box.add_theme_constant_override("separation", 8)
	tutorial_margin.add_child(tutorial_box)
	tutorial_title = Label.new()
	tutorial_title.add_theme_font_size_override("font_size", 24)
	tutorial_box.add_child(tutorial_title)
	tutorial_text = Label.new()
	tutorial_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	tutorial_text.modulate = UI_TEXT
	tutorial_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tutorial_box.add_child(tutorial_text)
	tutorial_panel.visible = false

	alert_panel = PanelContainer.new()
	alert_panel.position = Vector2(416, 118)
	alert_panel.size = Vector2(448, 92)
	alert_panel.add_theme_stylebox_override("panel", _panel_style(Color("#22070b"), UI_RED, 2))
	root_ui.add_child(alert_panel)
	var alert_row := HBoxContainer.new()
	alert_row.add_theme_constant_override("separation", 12)
	alert_panel.add_child(alert_row)
	alert_icon = Label.new()
	alert_icon.text = "[!]"
	alert_icon.add_theme_font_size_override("font_size", 28)
	alert_icon.modulate = Color("#ffd166")
	alert_icon.custom_minimum_size = Vector2(54, 64)
	alert_row.add_child(alert_icon)
	var alert_box := VBoxContainer.new()
	alert_box.add_theme_constant_override("separation", 2)
	alert_row.add_child(alert_box)
	alert_title = Label.new()
	alert_title.text = "ALERT"
	alert_title.add_theme_font_size_override("font_size", 28)
	alert_title.modulate = UI_TEXT
	alert_box.add_child(alert_title)
	alert_text = Label.new()
	alert_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	alert_text.modulate = Color("#ffd5d7")
	alert_box.add_child(alert_text)
	alert_panel.visible = false

	banner_panel = PanelContainer.new()
	banner_panel.position = Vector2(390, 122)
	banner_panel.size = Vector2(500, 96)
	banner_panel.add_theme_stylebox_override("panel", _panel_style(UI_PANEL_ALT, UI_TEAL, 2))
	root_ui.add_child(banner_panel)
	var banner_box := VBoxContainer.new()
	banner_box.add_theme_constant_override("separation", 6)
	banner_panel.add_child(banner_box)
	banner_title = Label.new()
	banner_title.add_theme_font_size_override("font_size", 25)
	banner_box.add_child(banner_title)
	banner_text = Label.new()
	banner_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	banner_text.modulate = UI_TEXT
	banner_box.add_child(banner_text)
	banner_panel.visible = false

	legend_panel = null


func _make_meter(parent: HBoxContainer, caption: String, value: String) -> Dictionary:
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(150, 70)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(box)
	var cap := Label.new()
	cap.text = caption
	cap.modulate = UI_MUTED
	box.add_child(cap)
	var val := Label.new()
	val.text = value
	val.add_theme_font_size_override("font_size", 24)
	val.modulate = UI_TEXT
	if caption == "Objective":
		box.custom_minimum_size = Vector2(320, 70)
		val.add_theme_font_size_override("font_size", 24)
		val.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		val.custom_minimum_size = Vector2(0, 42)
	box.add_child(val)
	if caption != "Objective":
		var bar := ProgressBar.new()
		bar.custom_minimum_size = Vector2(160, 8)
		bar.max_value = 100.0
		bar.value = 0.0
		bar.show_percentage = false
		bar.add_theme_stylebox_override("background", _bar_style(Color(1, 1, 1, 0.08), Color.TRANSPARENT))
		var fill_color := UI_TEAL
		if caption == "Fallout":
			fill_color = UI_RED_DARK
			fallout_bar = bar
			meter_fills["fallout"] = fill_color
		elif caption == "Problems":
			problem_bar = bar
			meter_fills["problems"] = fill_color
		else:
			fill_color = Color("#9ce66f")
			repair_bar = bar
			meter_fills["repairs"] = fill_color
		bar.add_theme_stylebox_override("fill", _bar_style(fill_color, Color.TRANSPARENT))
		box.add_child(bar)
	return {
		"caption": cap,
		"value": val,
	}


func _add_legend_row(parent: VBoxContainer, label: String, color: Color, body: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)
	var swatch := ColorRect.new()
	swatch.color = color
	swatch.custom_minimum_size = Vector2(14, 14)
	row.add_child(swatch)
	var text := Label.new()
	text.text = "%s: %s" % [label, body]
	text.modulate = Color("#d7ddd8")
	row.add_child(text)


func _style_button(button: Button, color: Color) -> void:
	button.add_theme_stylebox_override("normal", _button_style(color, 0.88))
	button.add_theme_stylebox_override("hover", _button_style(color.lightened(0.12), 1.0))
	button.add_theme_stylebox_override("pressed", _button_style(color.darkened(0.12), 1.0))
	button.add_theme_color_override("font_color", Color("#fff6f1"))
	button.add_theme_font_size_override("font_size", 17)


func _button_style(color: Color, alpha: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var bg := color
	bg.a = alpha
	style.bg_color = bg
	style.border_color = Color("#06080b")
	style.set_border_width_all(2)
	style.set_corner_radius_all(5)
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	style.content_margin_left = 12
	style.content_margin_right = 12
	return style


func _bar_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_corner_radius_all(2)
	return style


func _make_panel(pos: Vector2, size: Vector2) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.position = pos
	panel.size = size
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.045, 0.06, 0.08, 0.9), Color("#2d5a67"), 1))
	return panel


func _layout_ui() -> void:
	if not is_instance_valid(root_ui):
		return
	var size := get_viewport_rect().size
	var pad := clampf(size.x * 0.014, 18.0, 28.0)
	var top_height := clampf(size.y * 0.10, 78.0, 96.0)
	var bottom_height := clampf(size.y * 0.14, 104.0, 138.0)
	if is_instance_valid(top_panel):
		top_panel.position = Vector2(pad, pad)
		top_panel.size = Vector2(size.x - pad * 2.0, top_height)
	if is_instance_valid(top_row):
		top_row.add_theme_constant_override("separation", int(clampf(size.x * 0.006, 6.0, 14.0)))
	if is_instance_valid(title_label):
		title_label.add_theme_font_size_override("font_size", int(clampf(size.x * 0.018, 22.0, 30.0)))
	if is_instance_valid(subtitle_label):
		subtitle_label.add_theme_font_size_override("font_size", int(clampf(size.x * 0.009, 13.0, 16.0)))
	if is_instance_valid(objective_label):
		objective_label.add_theme_font_size_override("font_size", int(clampf(size.x * 0.014, 20.0, 24.0)))
	if is_instance_valid(bottom_panel):
		bottom_panel.position = Vector2(pad, size.y - bottom_height - pad)
		bottom_panel.size = Vector2(size.x - pad * 2.0, bottom_height)
	if is_instance_valid(overlay):
		overlay.size = Vector2(clampf(size.x * 0.44, 560.0, 820.0), clampf(size.y * 0.62, 460.0, 660.0))
		overlay.position = Vector2((size.x - overlay.size.x) * 0.5, (size.y - overlay.size.y) * 0.5)
	if is_instance_valid(tutorial_panel):
		tutorial_panel.size = Vector2(clampf(size.x * 0.34, 420.0, 620.0), clampf(size.y * 0.28, 220.0, 320.0))
		tutorial_panel.position = Vector2(pad + 52.0, top_height + pad + 26.0)
	if is_instance_valid(alert_panel):
		alert_panel.size = Vector2(clampf(size.x * 0.36, 448.0, 680.0), 92.0)
		alert_panel.position = Vector2((size.x - alert_panel.size.x) * 0.5, top_height + pad + 10.0)
	if is_instance_valid(banner_panel):
		banner_panel.size = Vector2(clampf(size.x * 0.34, 500.0, 720.0), 96.0)
		banner_panel.position = Vector2((size.x - banner_panel.size.x) * 0.5, top_height + pad + 14.0)


func _panel_style(bg: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(6)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style


func _load_level(index: int, next_phase := "playing") -> void:
	level_index = index
	var level: Dictionary = LEVELS[index]
	grid.clear()
	for row_text in level["map"]:
		var row := []
		for c in row_text:
			if c == "#":
				row.append(Tile.WALL)
			elif c == "D":
				row.append(Tile.DOOR)
			else:
				row.append(Tile.FLOOR)
		grid.append(row)

	problems.clear()
	var id := 0
	for problem in level["problems"]:
		problems.append({
			"id": id,
			"pos": problem["pos"],
			"type": problem["type"],
			"fixed": false,
		})
		id += 1

	player = level["start"]
	player_from = player
	player_lerp = 1.0
	fallout = level["fallout"]
	repairs = 0
	move_cooldown = 0.0
	key_repeat_cooldown = 0.0
	repair_cooldown = 0.0
	vent_pull_cooldown = 0.0
	drones.clear()
	sparks.clear()
	unstable.clear()
	particles.clear()
	consequence_markers.clear()
	consequence_log.clear()
	vent_blasts.clear()
	active_vent_rows.clear()
	show_objective_arrow = index == 0
	restart_level_index = index
	message = level["intro"]
	status_hold = 2.5
	tutorial_active = false
	phase = next_phase
	if is_instance_valid(overlay):
		overlay.visible = phase != "playing"
	if is_instance_valid(tutorial_panel):
		tutorial_panel.visible = false
	if is_instance_valid(banner_panel):
		banner_panel.visible = false
	if is_instance_valid(alert_panel):
		alert_panel.visible = false
	if phase == "playing":
		_show_room_banner()
	_update_hud()
	_render_log()


func _start_game() -> void:
	_apply_fullscreen()
	_set_hud_visible(true)
	_load_level(0, "playing")
	overlay.visible = false


func _load_background_assets() -> void:
	bg_ship_texture = _load_png_texture("res://assets/background/ship_2.png")
	bg_satellite_texture = _load_png_texture("res://assets/background/satellite.png")
	bg_box_texture = _load_png_texture("res://assets/background/box.png")
	bg_trash_bag_texture = _load_png_texture("res://assets/background/objects/Trashbag.png")
	bg_item_textures = []
	for path in [
		"res://assets/background/objects/Debris_small.png",
		"res://assets/background/objects/Debris_med.png",
		"res://assets/background/objects/Rocks_small.png",
		"res://assets/background/objects/Rocks_med.png",
		"res://assets/background/item1.png",
		"res://assets/background/item2.png",
		"res://assets/background/item3.png",
	]:
		var texture := _load_png_texture(path)
		if texture != null:
			bg_item_textures.append(texture)


func _load_png_texture(path: String, key_white := false) -> Texture2D:
	var image := Image.new()
	var error := image.load(path)
	if error != OK:
		return null
	if key_white:
		for y in range(image.get_height()):
			for x in range(image.get_width()):
				var pixel := image.get_pixel(x, y)
				if pixel.r > 0.93 and pixel.g > 0.93 and pixel.b > 0.93:
					image.set_pixel(x, y, Color(pixel.r, pixel.g, pixel.b, 0.0))
	return ImageTexture.create_from_image(image)


func _build_alarm_player() -> void:
	alarm_player = AudioStreamPlayer.new()
	alarm_player.bus = "Master"
	alarm_player.volume_db = -10.0
	add_child(alarm_player)
	alarm_streams = {
		"pressure": _make_alarm_stream(860.0, 560.0, 0.82, 0.18),
		"automation": _make_alarm_stream(980.0, 720.0, 0.58, 0.09),
		"doors": _make_alarm_stream(640.0, 420.0, 0.96, 0.22),
	}


func _make_alarm_stream(freq_a: float, freq_b: float, duration: float, pulse: float) -> AudioStreamWAV:
	var sample_rate := 22050
	var sample_count := int(sample_rate * duration)
	var data := PackedByteArray()
	data.resize(sample_count * 2)
	for i in range(sample_count):
		var t := float(i) / float(sample_rate)
		var phase := fmod(t, pulse)
		var freq := freq_a if phase < pulse * 0.5 else freq_b
		var env := clampf(1.0 - t / duration, 0.0, 1.0)
		var sample := sin(TAU * freq * t) * 0.55 * env
		var value := int(clampf(sample, -1.0, 1.0) * 32767.0)
		data[i * 2] = value & 0xFF
		data[i * 2 + 1] = (value >> 8) & 0xFF
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = sample_rate
	wav.stereo = false
	wav.data = data
	return wav


func _play_alarm(kind: String) -> void:
	if not is_instance_valid(alarm_player):
		return
	if not alarm_streams.has(kind):
		return
	alarm_player.stop()
	alarm_player.stream = alarm_streams[kind]
	alarm_player.play()


func _save_progress() -> void:
	var data := {
		"achievements": achievements,
		"best_room_cleared": best_room_cleared,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(data))


func _load_progress() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var text := file.get_as_text()
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var data: Dictionary = parsed
	achievements = {}
	if data.has("achievements") and data["achievements"] is Dictionary:
		for key in data["achievements"].keys():
			if bool(data["achievements"][key]):
				achievements[key] = true
	best_room_cleared = int(data.get("best_room_cleared", 0))


func _initialize_floating_props() -> void:
	var size := get_viewport_rect().size
	floating_props = [
		_make_floating_prop("left", bg_ship_texture, Vector2(212, 212), 0.98, size, Vector2(16.0, -8.0), -0.06, 0.04, "powered"),
		_make_floating_prop("left", bg_trash_bag_texture, Vector2(66, 66), 0.78, size, Vector2(12.0, -7.0), -0.16, 0.12, "drift"),
		_make_floating_prop("right", bg_ship_texture, Vector2(300, 300), 1.0, size, Vector2(-18.0, 7.0), 0.08, 0.05, "powered"),
		_make_floating_prop("right", bg_trash_bag_texture, Vector2(72, 72), 0.82, size, Vector2(-10.0, 6.0), 0.1, -0.1, "drift"),
		_make_floating_prop("right", bg_item_textures[3] if bg_item_textures.size() > 3 else null, Vector2(82, 82), 0.9, size, Vector2(-7.0, 5.0), 0.06, -0.015, "drift"),
		_make_floating_prop("window", bg_ship_texture, Vector2(360, 360), 1.0, size, Vector2(14.0, 1.0), -0.05, 0.03, "powered"),
		_make_floating_prop("window", bg_ship_texture, Vector2(224, 224), 0.92, size, Vector2(-10.0, 5.0), 0.05, -0.03, "powered"),
	]


func _make_floating_prop(zone: String, texture: Texture2D, size_px: Vector2, alpha: float, viewport_size: Vector2, velocity: Vector2, rotation: float, rot_speed: float, motion := "drift") -> Dictionary:
	var bounds := _floating_bounds(zone, viewport_size)
	var pos := _floating_spawn_point(bounds, size_px, velocity, true)
	return {
		"zone": zone,
		"texture": texture,
		"size": size_px,
		"alpha": alpha,
		"pos": pos,
		"vel": velocity,
		"base_vel": velocity,
		"rotation": rotation,
		"rot_speed": rot_speed,
		"drift_timer": randf_range(1.6, 3.6),
		"motion": motion,
		"path_phase": randf_range(0.0, TAU),
	}


func _floating_bounds(zone: String, viewport_size: Vector2) -> Rect2:
	match zone:
		"left":
			return Rect2(Vector2(18, 160), Vector2(maxf(120.0, board_origin.x - 36.0), viewport_size.y - 230.0))
		"right":
			var start_x := board_origin.x + COLS * cell_size + 24.0
			return Rect2(Vector2(start_x, 140), Vector2(maxf(120.0, viewport_size.x - start_x - 24.0), viewport_size.y - 220.0))
		"window":
			return Rect2(Vector2(viewport_size.x * 0.33, 126), Vector2(viewport_size.x * 0.32, 124))
	return Rect2(Vector2.ZERO, viewport_size)


func _floating_spawn_point(bounds: Rect2, size_px: Vector2, vel: Vector2, start_outside := false) -> Vector2:
	var pad := maxf(size_px.x, size_px.y) * 0.45
	var pos := bounds.position
	if absf(vel.x) >= absf(vel.y):
		var y := randf_range(bounds.position.y, bounds.position.y + maxf(1.0, bounds.size.y - size_px.y))
		if vel.x >= 0.0:
			pos = Vector2(bounds.position.x - size_px.x - pad, y)
		else:
			pos = Vector2(bounds.end.x + pad, y)
	else:
		var x := randf_range(bounds.position.x, bounds.position.x + maxf(1.0, bounds.size.x - size_px.x))
		if vel.y >= 0.0:
			pos = Vector2(x, bounds.position.y - size_px.y - pad)
		else:
			pos = Vector2(x, bounds.end.y + pad)
	if not start_outside:
		return pos
	return pos


func _update_floating_props(delta: float) -> void:
	if floating_props.is_empty():
		return
	var viewport_size := get_viewport_rect().size
	for prop in floating_props:
		var bounds := _floating_bounds(prop["zone"], viewport_size)
		var size_px: Vector2 = prop["size"]
		var pos: Vector2 = prop["pos"]
		var vel: Vector2 = prop["vel"]
		var base_vel: Vector2 = prop["base_vel"]
		var motion: String = prop["motion"]
		var drift_timer := float(prop["drift_timer"]) - delta
		if motion == "powered":
			var path_phase := float(prop["path_phase"]) + delta * 0.8
			var perp := Vector2(-base_vel.y, base_vel.x).normalized()
			vel = base_vel + perp * sin(path_phase) * 2.8
			prop["path_phase"] = path_phase
			prop["rotation"] = vel.angle() + PI
			drift_timer = randf_range(2.4, 4.2)
		elif drift_timer <= 0.0:
			var speed := maxf(10.0, vel.length())
			var angle_bias := randf_range(-0.6, 0.6)
			if prop["zone"] == "window":
				angle_bias = randf_range(-0.22, 0.22)
			vel = Vector2.RIGHT.rotated(vel.angle() + angle_bias) * clampf(speed * randf_range(0.92, 1.08), 10.0, 30.0)
			drift_timer = randf_range(1.4, 3.2)
		pos += vel * delta
		var pad := maxf(size_px.x, size_px.y) * 0.55
		var off_left := pos.x + size_px.x < bounds.position.x - pad
		var off_right := pos.x > bounds.end.x + pad
		var off_top := pos.y + size_px.y < bounds.position.y - pad
		var off_bottom := pos.y > bounds.end.y + pad
		if off_left or off_right or off_top or off_bottom:
			pos = _floating_spawn_point(bounds, size_px, base_vel)
		prop["pos"] = pos
		prop["vel"] = vel
		prop["drift_timer"] = drift_timer
		if motion != "powered":
			prop["rotation"] = float(prop["rotation"]) + float(prop["rot_speed"]) * delta


func _show_room_banner() -> void:
	var level: Dictionary = LEVELS[level_index]
	banner_title.text = "Room %d: %s" % [level_index + 1, level["name"]]
	banner_text.text = "Repair every glowing system. Each fix creates a known side effect. Keep Fallout below 100%."
	banner_timer = 3.2
	banner_panel.visible = true


func _apply_fullscreen() -> void:
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	var screen := DisplayServer.window_get_current_screen()
	var screen_size := DisplayServer.screen_get_size(screen)
	DisplayServer.window_set_size(screen_size)
	DisplayServer.window_set_position(Vector2i.ZERO)


func _advance_or_restart() -> void:
	if pending_next_level >= 0:
		_load_level(pending_next_level, "playing")
		pending_next_level = -1
		_set_hud_visible(true)
		overlay.visible = false
	else:
		_start_game()


func _restart_current_level() -> void:
	_set_hud_visible(true)
	_load_level(restart_level_index, "playing")
	overlay.visible = false


func _set_overlay_actions(primary_text: String, primary_color: Color, show_home := true, home_text := "Main Menu") -> void:
	overlay_button.text = primary_text
	_style_button(overlay_button, primary_color)
	overlay_button.visible = true
	menu_back_button.text = home_text
	menu_back_button.visible = show_home


func _set_overlay_theme(border_color: Color, bg := Color("#0c1526")) -> void:
	if is_instance_valid(overlay):
		overlay.add_theme_stylebox_override("panel", _panel_style(Color(bg.r, bg.g, bg.b, 0.97), border_color, 2))


func show_overlay(title: String, body: String, button_text: String, button_color := Color("#78f0e1"), show_home := true, border_color := Color("#78f0e1")) -> void:
	pending_next_level = -1
	_set_hud_visible(false)
	_clear_menu_buttons()
	_set_overlay_theme(border_color)
	overlay_title.text = title
	overlay_text.text = "%s\n\nFix order matters. Read the preview, choose the cost, then live with it." % body
	_set_overlay_actions(button_text, button_color, show_home)
	overlay.visible = true


func show_next_level_overlay(next_index: int) -> void:
	pending_next_level = next_index
	_set_hud_visible(false)
	_clear_menu_buttons()
	_set_overlay_theme(UI_TEAL)
	var next: Dictionary = LEVELS[next_index]
	overlay_title.text = "Room Cleared"
	overlay_text.text = "You contained this room.\n\nNext: %s\n%s\n\nPress the button to continue the run." % [next["name"], next["intro"]]
	_set_overlay_actions("Start Level %d" % [next_index + 1], Color("#78f0e1"), true, "Main Menu")
	overlay.visible = true


func _show_main_menu() -> void:
	phase = "menu"
	_set_hud_visible(false)
	_clear_menu_buttons()
	_set_overlay_theme(UI_TEAL)
	overlay_title.text = "Ripple Repair"
	overlay_text.text = "Repair every glowing system in each room. Every repair solves one problem and creates another, so the challenge is choosing the least dangerous order."
	_add_menu_button("Play", _start_game, Color("#ff4d5c"))
	_add_menu_button("Level Select", _show_level_select, Color("#78f0e1"))
	_add_menu_button("Instructions", _show_instructions, Color("#77a7ff"))
	_add_menu_button("Achievements", _show_achievements, Color("#d7a2ff"))
	_add_menu_button("Exit Game", _exit_game, Color("#39465c"))
	overlay_button.visible = false
	menu_back_button.visible = false
	overlay.visible = true


func _show_intro_instructions() -> void:
	phase = "menu"
	_set_hud_visible(false)
	_clear_menu_buttons()
	_set_overlay_theme(UI_TEAL)
	overlay_title.text = "Before You Start"
	overlay_text.text = "Repair every glowing system in the room, then move to the next room.\n\nEvery repair has a visible side effect. Read it first, then decide if that fix is worth the damage it will cause.\n\nFallout is the danger meter. Repairs and hazards raise it. If Fallout reaches 100%, the station spirals out of control and the run ends."
	overlay_button.text = "Play"
	_style_button(overlay_button, Color("#ff4d5c"))
	overlay_button.visible = true
	menu_back_button.text = "Main Menu"
	menu_back_button.visible = true
	overlay.visible = true

func _show_level_select() -> void:
	_clear_menu_buttons()
	_set_overlay_theme(UI_TEAL)
	overlay_title.text = "Level Select"
	overlay_text.text = "Replay cleared rooms any time. New rooms stay locked until you clear the one before them."
	var unlocked_count := mini(LEVELS.size(), maxi(1, best_room_cleared + 1))
	for i in range(LEVELS.size()):
		var button := Button.new()
		var unlocked := i < unlocked_count
		button.text = "Level %d - %s%s" % [i + 1, LEVELS[i]["name"], "" if unlocked else " (Locked)"]
		button.custom_minimum_size = Vector2(0, 48)
		_style_button(button, UI_TEAL if unlocked else Color("#39465c"))
		button.disabled = not unlocked
		if unlocked:
			button.pressed.connect(func(idx := i): _start_game_from(idx))
		menu_buttons.add_child(button)
	overlay_button.visible = false
	menu_back_button.text = "Back"
	menu_back_button.visible = true


func _show_instructions() -> void:
	_clear_menu_buttons()
	_set_overlay_theme(UI_TEAL)
	overlay_title.text = "Instructions"
	overlay_text.text = "Goal:\nRepair every glowing system in the room, then continue to the next room.\n\nHow a turn works:\n1. Move with WASD or Arrow keys.\n2. Walk onto a glowing system.\n3. Read the preview. It tells you the side effect this repair will cause.\n4. Decide whether to repair now or leave and try another system first.\n5. Press Space or Enter only when you accept that tradeoff.\n\nFallout:\nFallout is the station danger meter. It rises when repairs create new hazards or when hazards hit you. If Fallout reaches 100%, the room collapses into chaos and the run ends.\n\nDesign rule:\nConsequences are shown on purpose. This is a fair strategy game about repair order, not hidden traps."
	overlay_button.visible = false
	menu_back_button.text = "Back"
	overlay_button.visible = false
	menu_back_button.visible = true


func _show_achievements() -> void:
	_clear_menu_buttons()
	_set_overlay_theme(UI_TEAL)
	overlay_title.text = "Achievements"
	var rows := [
		_achievement_row("First Fix", "repair one system"),
		_achievement_row("Systems Thinker", "clear all five rooms (%d / 5)" % best_room_cleared),
		_achievement_row("Clean Chain", "finish under 45% Fallout"),
		_achievement_row("Disaster Artist", "survive above 80% Fallout"),
	]
	overlay_text.text = "\n".join(rows)
	overlay_button.visible = false
	menu_back_button.visible = true


func _show_pause_menu() -> void:
	phase = "menu"
	_set_hud_visible(false)
	_clear_menu_buttons()
	_set_overlay_theme(UI_TEAL)
	overlay_title.text = "Paused"
	overlay_text.text = "Resume the current run, return to the main menu, or exit the game."
	_add_menu_button("Resume", _resume_game, Color("#78f0e1"))
	_add_menu_button("Main Menu", _show_main_menu, Color("#77a7ff"))
	_add_menu_button("Exit Game", _exit_game, Color("#39465c"))
	overlay_button.visible = false
	menu_back_button.visible = false
	overlay.visible = true


func _achievement_row(name: String, body: String) -> String:
	var mark := "LOCKED"
	if achievements.has(name):
		mark = "UNLOCKED"
	return "%s  %s: %s" % [mark, name, body]


func _add_menu_button(label: String, callable: Callable, color: Color) -> void:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(0, 52)
	_style_button(button, color)
	button.pressed.connect(callable)
	menu_buttons.add_child(button)


func _clear_menu_buttons() -> void:
	for child in menu_buttons.get_children():
		child.queue_free()


func _start_game_from(index: int) -> void:
	_apply_fullscreen()
	restart_level_index = index
	_set_hud_visible(true)
	_load_level(index, "playing")
	overlay.visible = false


func _resume_game() -> void:
	_apply_fullscreen()
	phase = "playing"
	_set_hud_visible(true)
	overlay.visible = false


func _exit_game() -> void:
	get_tree().quit()


func _set_hud_visible(is_visible: bool) -> void:
	if is_instance_valid(top_panel):
		top_panel.visible = is_visible
	if is_instance_valid(bottom_panel):
		bottom_panel.visible = is_visible
	if is_instance_valid(legend_panel):
		legend_panel.visible = is_visible
	if is_instance_valid(alert_panel):
		alert_panel.visible = is_visible and alert_timer > 0.0 and not tutorial_active
	if is_instance_valid(banner_panel):
		banner_panel.visible = is_visible and banner_timer > 0.0
	if is_instance_valid(tutorial_panel):
		tutorial_panel.visible = is_visible and tutorial_active


func _read_grid_input() -> void:
	if move_cooldown > 0.0 or key_repeat_cooldown > 0.0:
		return
	var dir := Vector2i.ZERO
	if Input.is_action_just_pressed("move_up"):
		dir = Vector2i.UP
	elif Input.is_action_just_pressed("move_down"):
		dir = Vector2i.DOWN
	elif Input.is_action_just_pressed("move_left"):
		dir = Vector2i.LEFT
	elif Input.is_action_just_pressed("move_right"):
		dir = Vector2i.RIGHT
	elif Input.is_action_pressed("move_up"):
		dir = Vector2i.UP
	elif Input.is_action_pressed("move_down"):
		dir = Vector2i.DOWN
	elif Input.is_action_pressed("move_left"):
		dir = Vector2i.LEFT
	elif Input.is_action_pressed("move_right"):
		dir = Vector2i.RIGHT
	if dir != Vector2i.ZERO:
		if tutorial_active:
			_hide_tutorial()
		_move_player(dir)
		key_repeat_cooldown = 0.07


func _move_player(dir: Vector2i) -> void:
	var start := player
	var flow := _airflow_dir_at(player)
	var steps := 1
	var cooldown := 0.15
	if flow != Vector2i.ZERO:
		if dir == flow:
			steps = 3
			cooldown = 0.06
		elif dir == -flow:
			cooldown = 0.34
		else:
			cooldown = 0.18
	var moved := _step_player(dir, steps)
	if moved == 0:
		_burst(player + dir, Color("#ff6b63"), 5)
		move_cooldown = 0.12
		return
	player_from = start
	player_lerp = 0.0
	var tile: int = grid[player.y][player.x]
	move_cooldown = cooldown
	if tile == Tile.WATER:
		move_cooldown = maxf(move_cooldown, 0.25)
	elif tile == Tile.CRACK:
		move_cooldown = maxf(move_cooldown, 0.20)

	var row_flow := _airflow_dir_at(player)
	if row_flow != Vector2i.ZERO:
		_add_fallout(2.0)
		_spawn_vent_blast([player])
		shake = maxf(shake, 3.5)
		if row_flow == dir:
			_set_message("Airflow boost: moving with the opened row launches you farther than normal.")
		elif row_flow == -dir:
			_set_message("Airflow drag: pushing against the opened row slows you down.")
		else:
			_set_message("The vent row is open. Air keeps hauling you upward unless you fight it.")
		_burst(player, Color("#62d6c4"), 10)
	if tile == Tile.SHORT:
		_add_fallout(6.0)
		_burst(player, Color("#ffbe5c"), 9)
	elif tile == Tile.WATER:
		_add_fallout(5.0 if _adjacent_to_short(player) else 2.0)
		_burst(player, Color("#77a7ff"), 5)
	elif tile == Tile.CRACK:
		_add_fallout(2.0)


func _step_player(dir: Vector2i, steps := 1) -> int:
	var moved := 0
	for i in range(steps):
		var target := player + dir
		if not _is_walkable(target):
			break
		player = target
		moved += 1
	player_lerp = 0.28 if moved > 0 else player_lerp
	return moved


func _try_repair() -> void:
	if repair_cooldown > 0.0:
		return
	var problem := _problem_at(player)
	if problem.is_empty():
		_set_message("Nothing here is broken enough to repair. Yet.")
		repair_cooldown = 0.25
		return

	problem["fixed"] = true
	repairs += 1
	if level_index == 0 and repairs >= 2:
		show_objective_arrow = false
	achievements["First Fix"] = true
	_save_progress()
	repair_cooldown = 0.45
	shake = 4.0
	_burst(problem["pos"], TYPE_DATA[problem["type"]]["color"], 18)
	if _remaining_problems() == 0:
		_set_message("Final repair locked in. Room stabilized before the next side effect could spiral.")
		return
	_apply_consequence(problem)


func _apply_consequence(problem: Dictionary) -> void:
	var title := ""
	var body := ""
	match problem["type"]:
		"pressure":
			var lane := _make_airflow_lane(problem["pos"])
			var affected: Array[Vector2i] = lane["cells"]
			active_vent_rows[problem["pos"].y] = lane
			_mark_cells([lane["vent_cell"]], "VENT OPENED", Color("#62d6c4"))
			_spawn_vent_blast(affected)
			_add_fallout(9.0)
			title = "Pressure Rebound"
			body = "Bad consequence: an outer vent blew open and now the whole row is pulling toward it."
		"power":
			var cells := _ring(problem["pos"], 2)
			var chosen: Array[Vector2i] = []
			for i in range(cells.size()):
				if i % 2 == 0:
					chosen.append(cells[i])
			_place_cells(Tile.SHORT, chosen)
			_mark_cells(chosen, "SHORTS SPREAD", Color("#ffbe5c"))
			for cell in _ring(problem["pos"], 1):
				sparks.append({"pos": cell, "timer": randf()})
			_add_fallout(11.0)
			title = "Hot Patch"
			body = "Bad consequence: electrical shorts spread around the repair site."
		"support":
			var cells := _ring(problem["pos"], 1)
			_place_cells(Tile.CRACK, cells)
			_mark_cells(cells, "FLOOR CRACKED", Color("#ffbe5c"))
			var index := 0
			for cell in cells:
				unstable.append({"pos": cell, "timer": 4.5 + index * 0.45})
				index += 1
			_add_fallout(10.0)
			title = "Load Transfer"
			body = "Bad consequence: the floor cracked and may collapse soon."
		"automation":
			var spawn := _nearest_open_cells(problem["pos"], 2)
			for cell in spawn:
				drones.append({"pos": cell, "cooldown": 0.45, "speed": 0.82})
			_mark_cells(spawn, "DRONES WOKE", Color("#ff6b63"))
			_add_fallout(13.0)
			title = "Helpful Automation"
			body = "Bad consequence: maintenance drones woke up and now chase you."
		"coolant":
			var water := _flood(problem["pos"], 8)
			_place_cells(Tile.WATER, water)
			_mark_cells(water, "COOLANT LEAK", Color("#77a7ff"))
			_add_fallout(10.0)
			title = "Coolant Logic"
			body = "Bad consequence: coolant flooded the walkway and slows you down."
		"doors":
			var doors := _toggle_doors(problem["pos"])
			_mark_cells(doors, "DOORS CHANGED", Color("#d7a2ff"))
			_add_fallout(12.0)
			title = "Bulkhead Bargain"
			body = "Bad consequence: bulkheads changed and routes may be blocked."
	_add_consequence(title, body, problem["type"])


func _update_drones(delta: float) -> void:
	for drone in drones:
		drone["cooldown"] -= delta
		if drone["cooldown"] > 0.0:
			continue
		drone["cooldown"] = drone["speed"]
		var options := _neighbors(drone["pos"]).filter(func(cell): return _is_walkable(cell))
		options.sort_custom(func(a, b): return _distance(a, player) < _distance(b, player))
		if not options.is_empty():
			drone["pos"] = options[0]
		if drone["pos"] == player:
			_add_fallout(12.0)
			_burst(drone["pos"], Color("#ff6b63"), 13)
			_set_message("Automation tries to help by becoming your newest problem.")
			drone["cooldown"] += 1.2
			shake = 5.0


func _update_sparks(delta: float) -> void:
	for spark in sparks:
		spark["timer"] -= delta
		if spark["timer"] > 0.0:
			continue
		spark["timer"] = 0.3 + randf() * 0.55
		if _distance(spark["pos"], player) <= 1:
			_add_fallout(5.0)
			move_cooldown = maxf(move_cooldown, 0.16)
			_burst(spark["pos"], Color("#ffbe5c"), 9)


func _update_unstable(delta: float) -> void:
	var still_unstable := []
	for cell in unstable:
		cell["timer"] -= delta
		var pos: Vector2i = cell["pos"]
		if cell["timer"] <= 0.0 and grid[pos.y][pos.x] == Tile.CRACK:
			grid[pos.y][pos.x] = Tile.HOLE
			_add_fallout(4.0)
			_burst(pos, Color("#354147"), 10)
		elif grid[pos.y][pos.x] == Tile.CRACK:
			still_unstable.append(cell)
	unstable = still_unstable


func _update_consequence_markers(delta: float) -> void:
	var alive := []
	for marker in consequence_markers:
		marker["life"] -= delta
		if marker["life"] > 0.0:
			alive.append(marker)
	consequence_markers = alive


func _update_vent_blasts(delta: float) -> void:
	var alive := []
	for blast in vent_blasts:
		blast["life"] -= delta
		if blast["life"] > 0.0:
			alive.append(blast)
	vent_blasts = alive


func _update_vent_flow() -> void:
	if tutorial_active or move_cooldown > 0.0 or key_repeat_cooldown > 0.0:
		return
	var flow := _airflow_dir_at(player)
	if flow == Vector2i.ZERO:
		vent_pull_cooldown = 0.0
		return
	if vent_pull_cooldown > 0.0:
		return
	var moved := _step_player(flow, 1)
	if moved > 0:
		player_from = player - flow
		player_lerp = 0.0
		move_cooldown = 0.12
		vent_pull_cooldown = 0.24
		_spawn_vent_blast([player])
		_burst(player, Color("#62d6c4"), 8)
		_set_message("Air current: the opened row keeps pulling you upward.")


func _airflow_dir_at(pos: Vector2i) -> Vector2i:
	if not _inside(pos):
		return Vector2i.ZERO
	if active_vent_rows.has(pos.y) and _is_open_tile(pos):
		var lane: Dictionary = active_vent_rows[pos.y]
		if lane.has("cells") and lane["cells"].has(pos):
			return lane["dir"]
	return Vector2i.UP if grid[pos.y][pos.x] == Tile.VENT else Vector2i.ZERO


func _airflow_cells_for_row(row: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for x in range(COLS):
		var cell := Vector2i(x, row)
		if _is_open_tile(cell):
			cells.append(cell)
	return cells


func _make_airflow_lane(origin: Vector2i) -> Dictionary:
	var row := origin.y
	var cells := _airflow_cells_for_row(row)
	var dir := Vector2i.RIGHT
	var vent_cell := Vector2i(COLS - 1, row)
	if origin.x >= COLS / 2:
		dir = Vector2i.RIGHT
		for x in range(COLS - 1, -1, -1):
			var cell := Vector2i(x, row)
			if _is_open_tile(cell):
				vent_cell = cell
				break
	else:
		dir = Vector2i.LEFT
		vent_cell = Vector2i(0, row)
		for x in range(COLS):
			var cell := Vector2i(x, row)
			if _is_open_tile(cell):
				vent_cell = cell
				break
	return {
		"row": row,
		"dir": dir,
		"cells": cells,
		"vent_cell": vent_cell,
	}


func _update_particles(delta: float) -> void:
	var alive := []
	for particle in particles:
		particle["life"] -= delta
		particle["pos"] += particle["vel"] * delta
		if particle["life"] > 0.0:
			alive.append(particle)
	particles = alive


func _complete_level() -> void:
	phase = "ended"
	best_room_cleared = max(best_room_cleared, level_index + 1)
	if level_index == LEVELS.size() - 1:
		var rating := "clean chain"
		if fallout >= 75.0:
			rating = "barely legal repair"
		elif fallout >= 45.0:
			rating = "messy miracle"
		_record_score()
		achievements["Systems Thinker"] = true
		if fallout < 45.0:
			achievements["Clean Chain"] = true
		if fallout >= 80.0:
			achievements["Disaster Artist"] = true
		_save_progress()
		show_overlay(
			"Consequences Contained",
			"You cleared every room with %d%% fallout: %s. The best fix was not perfect. It was understood." % [roundi(fallout), rating],
			"Play Again",
			Color("#78f0e1"),
			true,
			UI_TEAL
		)
	else:
		_save_progress()
		show_next_level_overlay(level_index + 1)


func _end_game(title: String, body: String) -> void:
	phase = "ended"
	vent_blasts.clear()
	consequence_markers.clear()
	particles.clear()
	show_overlay(title, body, "Retry Level %d" % [restart_level_index + 1], Color("#ffbe5c"), true, Color("#ffbe5c"))
	pending_next_level = restart_level_index


func _record_score() -> void:
	_save_progress()


func _update_context_line() -> void:
	if status_hold > 0.0:
		return
	var problem := _problem_at(player)
	if problem.is_empty():
		var target := _nearest_problem()
		if target.is_empty():
			status_label.text = "All systems in this room are repaired. Continue to the next room."
		else:
			var data: Dictionary = TYPE_DATA[target["type"]]
			status_label.text = "Goal: repair every glowing system. Start by reaching the nearest glowing %s, then decide if its consequence is worth it." % data["label"]
		return
	var data: Dictionary = TYPE_DATA[problem["type"]]
	status_label.text = "Decision: repair this %s now, or leave it and choose a safer order. If you commit, it will %s." % [data["label"], data["preview"]]


func _update_tutorial() -> void:
	if tutorial_active:
		return
	if level_index == 0 and not tutorial_seen.has("move"):
		_show_tutorial("Your Goal", "Repair every glowing system in this room. Do not mash repairs. Walk to a glowing marker, read its side effect, then choose whether that fix should happen now.")
		tutorial_seen["move"] = true
		return
	if level_index == 0 and not tutorial_seen.has("preview") and not _problem_at(player).is_empty():
		_show_tutorial("Make a Choice", "You are standing on a repair point. The card and bottom panel tell you the exact side effect this fix will cause. That preview stays visible on purpose so the challenge is strategy, not surprise punishment.")
		tutorial_seen["preview"] = true
		return
	if not tutorial_seen.has("chain") and consequence_log.size() == 1:
		_show_tutorial("The Chain Begins", "That repair worked, but it changed the room. The log records each consequence so you can understand why the disaster is spreading.")
		tutorial_seen["chain"] = true
		return
	if not tutorial_seen.has("fallout") and fallout >= 35.0:
		_show_tutorial("Fallout Warning", "Fallout is the station danger meter. Repairs and hazards raise it. At 100%, the room is lost. Your real job is not repairing fast. It is keeping the chain under control.")
		tutorial_seen["fallout"] = true


func _show_tutorial(title: String, body: String) -> void:
	tutorial_title.text = title
	tutorial_text.text = body
	tutorial_panel.visible = true
	if is_instance_valid(legend_panel):
		legend_panel.visible = false
	tutorial_active = true
	status_hold = 999.0


func _hide_tutorial() -> void:
	tutorial_panel.visible = false
	tutorial_active = false
	if is_instance_valid(legend_panel) and phase == "playing":
		legend_panel.visible = true
	status_hold = 0.0


func _update_hud() -> void:
	var remaining := _remaining_problems()
	var total := problems.size()
	fallout_label.text = "%d%%" % roundi(fallout)
	problem_label.text = str(remaining)
	if is_instance_valid(repair_caption):
		repair_caption.text = "Level %d" % [level_index + 1]
	repair_label.text = "Level %d   %d / %d" % [level_index + 1, repairs, total]
	if is_instance_valid(fallout_bar):
		fallout_bar.value = fallout
		problem_bar.value = clampf(float(remaining) / maxf(1.0, float(total)) * 100.0, 0.0, 100.0)
		repair_bar.value = clampf(float(repairs) / maxf(1.0, float(total)) * 100.0, 0.0, 100.0)
		var fallout_color := Color("#ffbe5c")
		if fallout >= 75.0:
			fallout_color = Color("#ff6b63")
		elif fallout >= 45.0:
			fallout_color = Color("#ffd166")
		fallout_bar.add_theme_stylebox_override("fill", _bar_style(fallout_color, Color.TRANSPARENT))
	if not _problem_at(player).is_empty():
		objective_label.text = "Decide: repair or leave"
	elif remaining > 0:
		objective_label.text = "Repair all glowing systems"
	else:
		objective_label.text = "Proceed to next room"
	if fallout >= 75.0:
		subtitle_label.text = "Fallout critical. Stop making expensive fixes."
		subtitle_label.modulate = Color("#ff6b63")
	elif fallout >= 45.0:
		subtitle_label.text = "Consequences are starting to compound."
		subtitle_label.modulate = Color("#ffbe5c")
	else:
		subtitle_label.text = "Every fix makes a new flaw."
		subtitle_label.modulate = Color("#a9b4b4")
	if is_instance_valid(status_label) and status_hold > 0.0:
		status_label.text = message
	_render_log()


func _render_log() -> void:
	if not is_instance_valid(log_label):
		return
	if consequence_log.is_empty():
		log_label.text = "No consequences yet. The first fix writes the first line of the chain."
	else:
		var rows: Array[String] = []
		var index := 1
		for entry in consequence_log:
			rows.append("%d. %s" % [index, entry])
			index += 1
		log_label.text = "\n".join(rows)


func _set_message(text: String) -> void:
	message = text
	status_hold = 3.2
	if is_instance_valid(status_label):
		status_label.text = text


func _add_consequence(title: String, body: String, kind := "") -> void:
	consequence_log.push_front("%s. %s" % [title, body])
	if consequence_log.size() > 3:
		consequence_log.resize(3)
	var critical := kind == "pressure" or kind == "automation" or kind == "doors"
	if critical:
		status_hold = 0.0
	else:
		_set_message("%s: %s" % [title, body])
	_show_alert(title, body, kind, critical)


func _show_alert(title: String, body: String, kind: String, critical: bool) -> void:
	if tutorial_active:
		alert_timer = 0.0
		return
	last_alert_title = title
	last_alert_body = body
	if is_instance_valid(alert_panel):
		alert_title.text = "ALERT // %s" % title.to_upper()
		alert_text.text = body
	var colors := {
		"pressure": Color("#4ce7ff"),
		"automation": Color("#ff4f57"),
		"doors": Color("#c989ff"),
	}
	alert_color = colors.get(kind, Color("#ff3746"))
	if critical:
		alert_timer = 2.4
		screen_flash = maxf(screen_flash, 1.0)
		screen_flash_color = alert_color
		_play_alarm(kind)
	else:
		alert_timer = 0.0


func _add_fallout(amount: float) -> void:
	fallout = clampf(fallout + amount, 0.0, MAX_FALLOUT)
	screen_flash = 0.55
	screen_flash_color = Color("#ffbe5c") if fallout < 75.0 else Color("#ff6b63")


func _mark_cells(cells: Array, label: String, color: Color) -> void:
	for cell in cells:
		if not _inside(cell):
			continue
		consequence_markers.append({
			"pos": cell,
			"label": label,
			"color": color,
			"life": 2.2,
		})
		_burst(cell, color, 8)


func _spawn_vent_blast(cells: Array) -> void:
	for cell in cells:
		if not _inside(cell):
			continue
		vent_blasts.append({
			"pos": cell,
			"life": 1.15,
		})


func _place_cells(tile: int, cells: Array) -> void:
	for cell in cells:
		if not _inside(cell):
			continue
		if not _problem_at(cell).is_empty():
			continue
		if cell == player:
			continue
		if grid[cell.y][cell.x] == Tile.WALL:
			continue
		grid[cell.y][cell.x] = tile


func _toggle_doors(center: Vector2i) -> Array[Vector2i]:
	var candidates := [
		Vector2i(5, 4),
		Vector2i(8, 4),
		Vector2i(6, 1),
		Vector2i(6, 2),
		Vector2i(9, 6),
		center + Vector2i.LEFT,
		center + Vector2i.RIGHT,
	]
	var changed: Array[Vector2i] = []
	for cell in candidates:
		if not _inside(cell):
			continue
		if not _problem_at(cell).is_empty():
			continue
		var tile: int = grid[cell.y][cell.x]
		if tile == Tile.WALL or tile == Tile.HOLE:
			continue
		grid[cell.y][cell.x] = Tile.FLOOR if tile == Tile.DOOR else Tile.DOOR
		changed.append(cell)
		_burst(cell, Color("#d7a2ff"), 6)
	return changed


func _flood(start: Vector2i, count: int) -> Array[Vector2i]:
	var seen := {}
	var queue: Array[Vector2i] = [start]
	var result: Array[Vector2i] = []
	while not queue.is_empty() and result.size() < count:
		var cell: Vector2i = queue.pop_front()
		if not _inside(cell) or seen.has(cell):
			continue
		seen[cell] = true
		if _is_open_tile(cell) and _problem_at(cell).is_empty():
			result.append(cell)
		for neighbor in _neighbors(cell):
			queue.append(neighbor)
	return result


func _ring(center: Vector2i, radius: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for y in range(center.y - radius, center.y + radius + 1):
		for x in range(center.x - radius, center.x + radius + 1):
			var cell := Vector2i(x, y)
			if abs(x - center.x) + abs(y - center.y) != radius:
				continue
			if _inside(cell) and _is_open_tile(cell):
				cells.append(cell)
	return cells


func _nearest_open_cells(center: Vector2i, count: int) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for radius in range(1, 8):
		for cell in _ring(center, radius):
			if cell == player:
				continue
			if not _problem_at(cell).is_empty():
				continue
			cells.append(cell)
			if cells.size() == count:
				return cells
	return cells


func _problem_at(pos: Vector2i) -> Dictionary:
	for problem in problems:
		if not problem["fixed"] and problem["pos"] == pos:
			return problem
	return {}


func _nearest_problem() -> Dictionary:
	var best := {}
	var best_distance := 999
	for problem in problems:
		if problem["fixed"]:
			continue
		var distance := _distance(player, problem["pos"])
		if distance < best_distance:
			best_distance = distance
			best = problem
	return best


func _risk_for_type(type: String) -> String:
	match type:
		"pressure":
			return "B"
		"power":
			return "A"
		"support":
			return "B"
		"automation":
			return "S"
		"coolant":
			return "B"
		"doors":
			return "A"
	return "?"


func _remaining_problems() -> int:
	var count := 0
	for problem in problems:
		if not problem["fixed"]:
			count += 1
	return count


func _is_walkable(pos: Vector2i) -> bool:
	if not _inside(pos):
		return false
	var tile: int = grid[pos.y][pos.x]
	return tile != Tile.WALL and tile != Tile.HOLE and tile != Tile.DOOR


func _is_open_tile(pos: Vector2i) -> bool:
	if not _inside(pos):
		return false
	var tile: int = grid[pos.y][pos.x]
	return tile != Tile.WALL and tile != Tile.HOLE and tile != Tile.DOOR


func _inside(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.y >= 0 and pos.x < COLS and pos.y < ROWS


func _neighbors(pos: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for dir in [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]:
		var cell: Vector2i = pos + dir
		if _inside(cell):
			cells.append(cell)
	return cells


func _adjacent_to_short(pos: Vector2i) -> bool:
	for cell in _neighbors(pos):
		if grid[cell.y][cell.x] == Tile.SHORT:
			return true
	return false


func _distance(a: Vector2i, b: Vector2i) -> int:
	return abs(a.x - b.x) + abs(a.y - b.y)


func _burst(cell: Vector2i, color: Color, amount: int) -> void:
	if not _inside(cell):
		return
	var center := _cell_center(cell)
	for i in range(amount):
		particles.append({
			"pos": center,
			"vel": Vector2(randf_range(-130.0, 130.0), randf_range(-130.0, 130.0)),
			"life": randf_range(0.25, 0.65),
			"color": color,
			"size": randf_range(2.0, 5.0),
		})


func _draw() -> void:
	_update_board_metrics()
	var jitter := Vector2(randf_range(-shake, shake), randf_range(-shake, shake)) if shake > 0.0 else Vector2.ZERO
	draw_offset = jitter
	draw_set_transform(jitter)
	_draw_backdrop()
	_draw_grid()
	_draw_vent_blasts()
	_draw_objective_arrow()
	_draw_problems()
	_draw_consequence_markers()
	_draw_entities()
	_draw_particles()
	_draw_tooltip()
	_draw_vignette()
	draw_set_transform(Vector2.ZERO)
	draw_offset = Vector2.ZERO


func _update_board_metrics() -> void:
	var size := get_viewport_rect().size
	var margin := minf(size.x, size.y) * 0.12
	cell_size = floorf(minf((size.x - margin * 2.0) / COLS, (size.y - margin * 2.25) / ROWS))
	board_origin = Vector2(
		floorf((size.x - cell_size * COLS) / 2.0),
		floorf((size.y - cell_size * ROWS) / 2.0 + 14.0)
	)


func _cell_rect(cell: Vector2i) -> Rect2:
	return Rect2(board_origin + Vector2(cell) * cell_size, Vector2(cell_size, cell_size))


func _cell_center(cell: Vector2i) -> Vector2:
	return board_origin + (Vector2(cell) + Vector2(0.5, 0.5)) * cell_size


func _draw_backdrop() -> void:
	var rect := get_viewport_rect()
	var size := rect.size
	draw_rect(rect, Color("#020814"))
	draw_rect(Rect2(Vector2.ZERO, size), Color("#14345d", 0.34))
	_draw_star_field(size)
	_draw_floating_debris(size)
	draw_rect(Rect2(Vector2.ZERO, size), Color("#02050a", 0.08))


func _draw_star_field(size: Vector2) -> void:
	var cols: int = maxi(12, int(ceil(size.x / 72.0)))
	var rows: int = maxi(8, int(ceil(size.y / 72.0)))
	for gy in range(rows):
		for gx in range(cols):
			var idx: int = gy * cols + gx
			var x: float = (float(gx) + 0.18 + 0.52 * abs(sin(float(idx) * 12.9898))) * size.x / float(cols)
			var y: float = (float(gy) + 0.16 + 0.56 * abs(sin(float(idx) * 78.233 + 1.7))) * size.y / float(rows)
			var twinkle: float = 0.72 + 0.28 * sin(pulse * 1.8 + idx * 0.73)
			var core := Color(0.9, 0.96, 1.0, twinkle)
			if idx % 11 == 0:
				draw_circle(Vector2(x, y), 5.0, Color(0.7, 0.84, 1.0, twinkle * 0.18))
				draw_circle(Vector2(x, y), 2.2, Color(0.88, 0.95, 1.0, twinkle * 0.44))
				draw_circle(Vector2(x, y), 1.0, core)
			elif idx % 4 == 0:
				draw_circle(Vector2(x, y), 2.3, Color(0.82, 0.9, 1.0, twinkle * 0.16))
				draw_circle(Vector2(x, y), 1.05, core)
			else:
				draw_circle(Vector2(x, y), 0.9, core)


func _draw_floating_debris(size: Vector2) -> void:
	for prop in floating_props:
		var modulate := Color(1, 1, 1, prop["alpha"])
		if prop["texture"] == bg_ship_texture:
			modulate = Color(1.08, 1.08, 1.08, prop["alpha"])
		_draw_background_texture(prop["texture"], prop["pos"], prop["size"], modulate, prop["rotation"])


func _draw_background_texture(texture: Texture2D, pos: Vector2, size: Vector2, modulate: Color = Color.WHITE, rotation := 0.0) -> void:
	if texture == null:
		return
	var tex_size := texture.get_size()
	if tex_size.x <= 0.0 or tex_size.y <= 0.0:
		return
	var center := pos + size * 0.5
	var scale := Vector2(size.x / tex_size.x, size.y / tex_size.y)
	draw_set_transform(draw_offset + center, rotation, scale)
	draw_texture(texture, -tex_size * 0.5, modulate)
	draw_set_transform(draw_offset, 0.0, Vector2.ONE)


func _draw_vent_blasts() -> void:
	for blast in vent_blasts:
		var cell: Vector2i = blast["pos"]
		var life: float = blast["life"]
		var rect := _cell_rect(cell).grow(-cell_size * 0.05)
		var alpha := clampf(life / 1.15, 0.0, 1.0)
		draw_rect(rect, Color(0.35, 0.95, 1.0, 0.14 * alpha))
		for i in range(4):
			var x := rect.position.x + rect.size.x * (0.22 + i * 0.16)
			var tip_y := rect.position.y - rect.size.y * (0.34 + (1.0 - alpha) * 0.22)
			draw_line(Vector2(x, rect.position.y + rect.size.y * 0.86), Vector2(x, tip_y), Color(0.86, 1.0, 1.0, 0.9 * alpha), 2.0)
			draw_line(Vector2(x, tip_y), Vector2(x - 4, tip_y + 8), Color(0.86, 1.0, 1.0, 0.9 * alpha), 2.0)
			draw_line(Vector2(x, tip_y), Vector2(x + 4, tip_y + 8), Color(0.86, 1.0, 1.0, 0.9 * alpha), 2.0)


func _draw_grid() -> void:
	var board_rect := Rect2(board_origin - Vector2(8, 8), Vector2(COLS, ROWS) * cell_size + Vector2(16, 16))
	draw_rect(board_rect, Color("#071012", 0.58))
	draw_rect(board_rect, Color("#62d6c4", 0.16), false, 2.0)
	_draw_board_stars(board_rect)
	for y in range(ROWS):
		for x in range(COLS):
			_draw_tile(Vector2i(x, y), grid[y][x])


func _draw_board_stars(board_rect: Rect2) -> void:
	for i in range(46):
		var x := board_rect.position.x + 14 + fmod(float(i * 83), maxf(20.0, board_rect.size.x - 28.0))
		var y := board_rect.position.y + 12 + fmod(float(i * 47), maxf(20.0, board_rect.size.y - 24.0))
		var twinkle := 0.18 + 0.12 * sin(pulse * 1.6 + i)
		draw_circle(Vector2(x, y), 0.95 + float(i % 2) * 0.25, Color(0.86, 0.93, 1.0, twinkle))
		if i % 9 == 0:
			draw_line(Vector2(x - 3, y), Vector2(x + 3, y), Color(0.86, 0.93, 1.0, twinkle * 0.8), 1.0)
			draw_line(Vector2(x, y - 3), Vector2(x, y + 3), Color(0.86, 0.93, 1.0, twinkle * 0.8), 1.0)


func _draw_objective_arrow() -> void:
	if phase != "playing" or not show_objective_arrow or not _problem_at(player).is_empty():
		return
	var target := _nearest_problem()
	if target.is_empty():
		return
	var start := _cell_center(player)
	var finish := _cell_center(target["pos"])
	var dir := (finish - start).normalized()
	var end := finish - dir * cell_size * 0.48
	var color := Color("#62d6c4")
	color.a = 0.62 + sin(pulse * 5.0) * 0.16
	draw_line(start + dir * cell_size * 0.42, end, color, 3.0)
	var side := Vector2(-dir.y, dir.x)
	var tip := end
	var left := tip - dir * 15.0 + side * 8.0
	var right := tip - dir * 15.0 - side * 8.0
	draw_polygon(PackedVector2Array([tip, left, right]), PackedColorArray([color, color, color]))
	var font := ThemeDB.fallback_font
	draw_string(font, start + Vector2(18, -18), "Next repair", HORIZONTAL_ALIGNMENT_LEFT, 160, 14, color)


func _draw_tile(cell: Vector2i, tile: int) -> void:
	var rect := _cell_rect(cell).grow(-cell_size * 0.055)
	if tile == Tile.WALL:
		draw_rect(rect, Color("#11181b"))
		draw_rect(Rect2(rect.position + Vector2(cell_size * 0.15, cell_size * 0.12), Vector2(cell_size * 0.52, cell_size * 0.09)), Color(1, 1, 1, 0.05))
		return
	if tile == Tile.HOLE:
		draw_rect(rect, Color("#030405"))
		draw_rect(rect, Color("#ff6b63", 0.28), false, 2.0)
		return

	var base := Color("#20272b")
	if tile == Tile.WATER:
		base = Color("#1d2b36")
	elif tile == Tile.SHORT:
		base = Color("#332821")
	elif tile == Tile.VENT:
		base = Color("#183033")
	elif tile == Tile.CRACK:
		base = Color("#2d2b25")
	draw_rect(rect, base)
	draw_rect(rect, Color(1, 1, 1, 0.08), false, 1.0)
	match tile:
		Tile.CRACK:
			_draw_crack(rect)
		Tile.VENT:
			_draw_vent(rect)
		Tile.SHORT:
			_draw_short(rect)
		Tile.WATER:
			_draw_water(rect)
		Tile.DOOR:
			_draw_door(rect)
	if active_vent_rows.has(cell.y) and tile != Tile.WALL and tile != Tile.HOLE:
		var lane: Dictionary = active_vent_rows[cell.y]
		if lane.has("cells") and lane["cells"].has(cell):
			_draw_airflow_overlay(rect, lane["dir"], lane["vent_cell"] == cell)


func _draw_crack(rect: Rect2) -> void:
	var p := rect.position
	var s := rect.size.x
	var pts := [
		p + Vector2(s * 0.2, s * 0.28),
		p + Vector2(s * 0.48, s * 0.5),
		p + Vector2(s * 0.36, s * 0.76),
		p + Vector2(s * 0.74, s * 0.62),
	]
	draw_polyline(PackedVector2Array(pts), Color("#ffbe5c"), 2.5)


func _draw_vent(rect: Rect2) -> void:
	var glow := Color("#78f0e1", 0.22 + 0.08 * sin(pulse * 8.0))
	draw_rect(rect.grow(-rect.size.x * 0.08), glow)
	for i in range(3):
		var y := rect.position.y + rect.size.y * (0.32 + i * 0.16)
		draw_line(Vector2(rect.position.x + rect.size.x * 0.2, y), Vector2(rect.position.x + rect.size.x * 0.8, y), Color("#62d6c4"), 2.5)
	for i in range(3):
		var x := rect.position.x + rect.size.x * (0.28 + i * 0.18)
		var top := rect.position.y + rect.size.y * 0.18 + sin(pulse * 9.0 + i) * 2.5
		draw_line(Vector2(x, rect.position.y + rect.size.y * 0.76), Vector2(x, top), Color("#d8fffb", 0.9), 1.8)
		draw_line(Vector2(x, top), Vector2(x - 4, top + 8), Color("#d8fffb", 0.9), 1.8)
		draw_line(Vector2(x, top), Vector2(x + 4, top + 8), Color("#d8fffb", 0.9), 1.8)


func _draw_airflow_overlay(rect: Rect2, dir: Vector2i, is_open_vent := false) -> void:
	var glow := Color("#78f0e1", 0.08 + 0.04 * sin(pulse * 8.0))
	draw_rect(rect.grow(-rect.size.x * 0.14), glow)
	var accent := Color("#d8fffb", 0.72)
	for i in range(3):
		var t := fmod(pulse * 2.2 + i * 0.26, 1.0)
		var start := rect.position + Vector2(rect.size.x * 0.16, rect.size.y * (0.28 + i * 0.17))
		var finish := rect.position + Vector2(rect.size.x * 0.84, rect.size.y * (0.24 + i * 0.17))
		if dir == Vector2i.LEFT:
			start = rect.position + Vector2(rect.size.x * 0.84, rect.size.y * (0.28 + i * 0.17))
			finish = rect.position + Vector2(rect.size.x * 0.16, rect.size.y * (0.24 + i * 0.17))
		var seg_start := start.lerp(finish, clampf(t - 0.18, 0.0, 1.0))
		var seg_end := start.lerp(finish, clampf(t + 0.22, 0.0, 1.0))
		draw_line(seg_start, seg_end, accent, 1.8)
	if is_open_vent:
		_draw_edge_vent(rect, dir)


func _draw_edge_vent(rect: Rect2, dir: Vector2i) -> void:
	var body := rect.grow(-rect.size.x * 0.12)
	var vent_w := body.size.x * 0.22
	var vent := Rect2(body.position, Vector2(vent_w, body.size.y))
	if dir == Vector2i.RIGHT:
		vent.position.x = body.end.x - vent_w
	draw_rect(vent, Color("#10282d"))
	draw_rect(vent, Color("#78f0e1", 0.9), false, 2.0)
	for i in range(3):
		var y := vent.position.y + vent.size.y * (0.28 + i * 0.2)
		draw_line(Vector2(vent.position.x + 4, y), Vector2(vent.end.x - 4, y), Color("#d8fffb", 0.9), 1.6)




func _draw_short(rect: Rect2) -> void:
	var p := rect.position
	var s := rect.size.x
	var pts := [
		p + Vector2(s * 0.34, s * 0.22),
		p + Vector2(s * 0.58, s * 0.45),
		p + Vector2(s * 0.45, s * 0.45),
		p + Vector2(s * 0.66, s * 0.78),
	]
	draw_polyline(PackedVector2Array(pts), Color("#ffbe5c"), 3.0)


func _draw_water(rect: Rect2) -> void:
	var fill := Color("#77a7ff")
	fill.a = 0.25
	var line := Color("#77a7ff")
	line.a = 0.75
	draw_circle(rect.get_center() + Vector2(0, rect.size.y * 0.08), rect.size.x * 0.28, fill)
	draw_arc(rect.get_center(), rect.size.x * 0.28, 0.0, TAU, 28, line, 2.0)


func _draw_door(rect: Rect2) -> void:
	var door := rect.grow(-rect.size.x * 0.17)
	draw_rect(door, Color("#d7a2ff", 0.25))
	draw_rect(door, Color("#d7a2ff"), false, 2.5)


func _draw_problems() -> void:
	for problem in problems:
		if problem["fixed"]:
			continue
		var data: Dictionary = TYPE_DATA[problem["type"]]
		var center := _cell_center(problem["pos"])
		var selected: bool = problem["pos"] == player
		var radius := cell_size * (0.23 + sin(pulse * 5.0) * 0.025)
		draw_circle(center, cell_size * 0.42, Color(0.03, 0.04, 0.04, 0.78))
		if selected:
			draw_circle(center, cell_size * 0.5, Color(data["color"], 0.18))
			draw_arc(center, cell_size * 0.48, 0.0, TAU, 48, Color("#f2f0e8"), 2.0)
		draw_arc(center, radius, 0.0, TAU, 40, data["color"], maxf(3.0, cell_size * 0.07))
		var font := ThemeDB.fallback_font
		draw_string(font, center + Vector2(-5, 7), data["label"].substr(0, 1), HORIZONTAL_ALIGNMENT_CENTER, -1, maxf(16.0, cell_size * 0.34), data["color"])


func _draw_consequence_markers() -> void:
	var font := ThemeDB.fallback_font
	for marker in consequence_markers:
		var life: float = marker["life"]
		var color: Color = marker["color"]
		color.a = clampf(life / 2.2, 0.0, 1.0)
		var center := _cell_center(marker["pos"])
		var radius := cell_size * (0.46 + sin(pulse * 9.0) * 0.04)
		draw_arc(center, radius, 0.0, TAU, 36, color, 4.0)
		draw_line(center + Vector2(-cell_size * 0.28, 0), center + Vector2(cell_size * 0.28, 0), color, 2.0)
		draw_line(center + Vector2(0, -cell_size * 0.28), center + Vector2(0, cell_size * 0.28), color, 2.0)
		var text_pos := center + Vector2(-cell_size * 0.6, -cell_size * 0.58)
		draw_rect(Rect2(text_pos + Vector2(-5, -15), Vector2(cell_size * 1.45, 22)), Color(0.03, 0.04, 0.04, color.a * 0.75))
		draw_string(font, text_pos, marker["label"], HORIZONTAL_ALIGNMENT_LEFT, cell_size * 1.6, 12, color)


func _draw_entities() -> void:
	_draw_player()
	for drone in drones:
		var center := _cell_center(drone["pos"])
		var size := cell_size * 0.44
		draw_rect(Rect2(center - Vector2(size, size) * 0.5, Vector2(size, size)), Color("#ff6b63"))
		draw_rect(Rect2(center - Vector2(size * 0.22, size * 0.08), Vector2(size * 0.44, size * 0.16)), Color("#210c0a"))
	for spark in sparks:
		var center := _cell_center(spark["pos"])
		var s := cell_size
		var pts := [
			center + Vector2(-s * 0.22, 0),
			center + Vector2(-s * 0.04, -s * 0.16),
			center + Vector2(s * 0.08, s * 0.14),
			center + Vector2(s * 0.24, -s * 0.04),
		]
		draw_polyline(PackedVector2Array(pts), Color("#ffbe5c"), 3.0)


func _draw_player() -> void:
	player_lerp = minf(1.0, player_lerp + 0.18)
	var ease := 1.0 - pow(1.0 - player_lerp, 3.0)
	var draw_cell := Vector2(player_from).lerp(Vector2(player), ease)
	var center := board_origin + (draw_cell + Vector2(0.5, 0.5)) * cell_size
	var radius := cell_size * 0.28
	draw_circle(center, radius, Color("#dffff8"))
	draw_rect(Rect2(center + Vector2(-radius * 0.7, -radius * 0.15), Vector2(radius * 1.4, radius * 0.38)), Color("#111718"))
	draw_rect(Rect2(center + Vector2(radius * 0.18, -radius * 0.08), Vector2(radius * 0.38, radius * 0.12)), Color("#77a7ff"))


func _draw_particles() -> void:
	var board_rect := Rect2(board_origin - Vector2(8, 8), Vector2(COLS, ROWS) * cell_size + Vector2(16, 16))
	for particle in particles:
		if not board_rect.has_point(particle["pos"]):
			continue
		var alpha: float = clampf(particle["life"] * 2.0, 0.0, 1.0)
		var color: Color = particle["color"]
		color.a = alpha
		draw_rect(Rect2(particle["pos"] - Vector2(particle["size"], particle["size"]) * 0.5, Vector2(particle["size"], particle["size"])), color)


func _draw_tooltip() -> void:
	if phase != "playing":
		return
	var problem := _problem_at(player)
	if problem.is_empty():
		return
	var data: Dictionary = TYPE_DATA[problem["type"]]
	var risk := _risk_for_type(problem["type"])
	var text := "REPAIR WILL CAUSE: %s" % data["preview"]
	var font := ThemeDB.fallback_font
	var font_size := 16
	var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var width := minf(get_viewport_rect().size.x * 0.72, maxf(text_size.x + 26.0, 360.0))
	var height := 72.0
	var center := _cell_center(problem["pos"])
	var pos := Vector2(clampf(center.x - width * 0.5, 14.0, get_viewport_rect().size.x - width - 14.0), maxf(108.0, center.y - cell_size * 0.95))
	var rect := Rect2(pos, Vector2(width, height))
	draw_rect(rect, Color(0.03, 0.04, 0.04, 0.86))
	draw_rect(rect, data["color"], false, 1.5)
	draw_string(font, pos + Vector2(13, 22), "%s  /  RISK %s" % [data["label"], risk], HORIZONTAL_ALIGNMENT_LEFT, width - 22, 16, data["color"])
	draw_string(font, pos + Vector2(13, 45), text, HORIZONTAL_ALIGNMENT_LEFT, width - 22, font_size, Color("#f2f0e8"))
	draw_string(font, pos + Vector2(13, 66), "SPACE / ENTER: repair     ARROWS / WASD: walk away", HORIZONTAL_ALIGNMENT_LEFT, width - 22, 13, Color("#a9b4b4"))


func _draw_vignette() -> void:
	var size := get_viewport_rect().size
	var intensity := clampf(0.28 + fallout / 260.0 + level_index * 0.03, 0.28, 0.72)
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, 34)), Color(0, 0, 0, intensity * 0.6))
	draw_rect(Rect2(Vector2.ZERO, Vector2(34, size.y)), Color(0, 0, 0, intensity * 0.45))
	draw_rect(Rect2(Vector2(size.x - 34, 0), Vector2(34, size.y)), Color(0, 0, 0, intensity * 0.45))
	draw_rect(Rect2(Vector2(0, size.y - 34), Vector2(size.x, 34)), Color(0, 0, 0, intensity * 0.6))
	if screen_flash > 0.0:
		var flash := screen_flash_color
		flash.a = screen_flash * 0.18
		draw_rect(Rect2(Vector2.ZERO, size), flash)
	if alert_timer > 0.0 and phase == "playing":
		_draw_fullscreen_alert(size)


func _draw_fullscreen_alert(size: Vector2) -> void:
	var alpha := clampf(alert_timer / 2.4, 0.0, 1.0)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.09, 0.0, 0.01, 0.28 * alpha))
	for i in range(7):
		var stripe_h := 28.0
		var y := 86.0 + i * 72.0 + sin(pulse * 10.0 + i) * 4.0
		draw_rect(Rect2(0, y, size.x, stripe_h), Color(alert_color.r, alert_color.g, alert_color.b, 0.18 * alpha))
	var frame := Rect2(Vector2(110, size.y * 0.39), Vector2(size.x - 220, 138))
	draw_rect(frame, Color("#1d0509", 0.82 * alpha))
	draw_rect(frame, Color(alert_color.r, alert_color.g, alert_color.b, 0.95 * alpha), false, 4.0)
	var font := ThemeDB.fallback_font
	draw_string(font, frame.position + Vector2(34, 44), "ALERT", HORIZONTAL_ALIGNMENT_LEFT, frame.size.x - 68, 38, Color(1, 0.97, 0.97, alpha))
	draw_string(font, frame.position + Vector2(34, 78), last_alert_title.to_upper(), HORIZONTAL_ALIGNMENT_LEFT, frame.size.x - 68, 24, Color(1.0, 0.82, 0.4, alpha))
	draw_string(font, frame.position + Vector2(34, 112), last_alert_body, HORIZONTAL_ALIGNMENT_LEFT, frame.size.x - 68, 18, Color(1, 0.9, 0.91, alpha))
