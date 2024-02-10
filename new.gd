extends Control

@onready var file_dialog = %FileDialog
@onready var wpm = %wpm
@onready var label = %Label
@onready var timer = %Timer
@onready var resumebutton = %resumebutton
@onready var filepathlabel = %filepathlabel
@onready var pausebutton = %pausebutton
@onready var texts = %texts

var is_playing := false

var filePath
var main_string = null
var word_count=0
var z:=0
var string_to_print

func _process(_delta):
	wpm.text = str(60/timer.wait_time)+" WPM"
	if string_to_print: label.text = string_to_print
	#completed the session
	if z+1 == word_count: 	
		resumebutton.visible = true
		pausebutton.visible = false
		z=0
		timer.stop()

func _on_timer_timeout():
	if main_string: next_word(main_string,z)

func _on_line_edit_2_text_submitted(new_text : String):
	main_string = new_text
	timer.start()
	word_count = main_string.get_slice_count(" ")

func next_word (text:String,index:int):
	z+=1
	string_to_print = text.get_slice(" ",index)

func _on_h_slider_value_changed(value):
	timer.wait_time = 1/value


func _on_file_dialog_file_selected(path):
	filepathlabel.text = path
	filePath = path
	if filePath:
		var file  = FileAccess.open(filePath,FileAccess.READ)
		var text  =  file.get_as_text()
		main_string = text
		texts.text = main_string
		word_count = main_string.get_slice_count(" ")

func _on_pausebutton_button_down():
	resumebutton.visible = true
	pausebutton.visible = false
	timer.paused = true

func _on_resumebutton_button_down():
	if main_string == null:
		file_dialog.popup()
		texts.visible = true
	pausebutton.visible = true
	resumebutton.visible = false
	texts.visible = false
	timer.paused = false
	timer.start()

func _on_stopbutton_button_down():
	resumebutton.visible = true
	pausebutton.visible = false
	z=0
	timer.stop()
	
func _on_startbutton_button_down():
	resumebutton.visible = true
	pausebutton.visible = false
	timer.stop()
	z=0
	file_dialog.popup()
