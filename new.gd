extends Control

@onready var file_dialog = %FileDialog
@onready var wpm = %wpm
@onready var label = %Label
@onready var timer = %Timer
@onready var resumebutton = %resumebutton
@onready var filepathlabel = %filepathlabel
@onready var pausebutton = %pausebutton
@onready var texts = %texts
@onready var progress_bar = %ProgressBar
@onready var time_left = %timeLeft

var is_playing := false

var filePath
var main_string = null
var word_count=0.0
var z:=0.0
var string_to_print
var progress:float
var wordsperminte = 60
var timeLeft

func _on_timer_timeout():
	if string_to_print: label.text = string_to_print
	progress_bar.value =progress
	if main_string: next_word(main_string,z)
	if z-1 == word_count:
		texts.visible = true
		resumebutton.visible = true
		pausebutton.visible = false
		z=0
		timer.stop()
	updateTimeLeftIndicator()

func next_word (text:String,index:int):
	string_to_print = text.get_slice(" ",index)
	z+=1
	progress =  z/word_count *100

func _on_h_slider_value_changed(value):
	wordsperminte = 60/timer.wait_time
	timer.wait_time = 1/value
	wpm.text = str(wordsperminte)+" WPM"
	updateTimeLeftIndicator()

func _on_file_dialog_file_selected(path):
	filepathlabel.text = path
	filePath = path
	if filePath:
		var file  = FileAccess.open(filePath,FileAccess.READ)
		var text  =  file.get_as_text()
		main_string = text
		texts.text = main_string
		word_count = main_string.get_slice_count(" ")
	updateTimeLeftIndicator()

func _on_pausebutton_button_down():
	resumebutton.visible = true
	pausebutton.visible = false
	timer.paused = true

func _on_resumebutton_button_down():
	if main_string == null:
		file_dialog.popup()
	pausebutton.visible = true
	resumebutton.visible = false
	texts.visible = false
	timer.paused = false
	timer.start()

func _on_stopbutton_button_down():
	progress = 0.0
	texts.visible = true
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

func updateTimeLeftIndicator():
	if word_count:
		timeLeft = (word_count-z)/wordsperminte
		if timeLeft < 1.0:
			timeLeft*=60
			time_left.text = str(snapped(timeLeft,1))+"  seconds Left"
		else:
			time_left.text = str(snapped(timeLeft,0.1))+"  mins Left"

func _on_texts_text_changed():
	updateTimeLeftIndicator()
	if texts.visible:
		main_string=texts.text
		word_count = main_string.get_slice_count(" ")
