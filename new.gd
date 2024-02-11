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
@onready var timerupdatetimeleft = %timerupdatetimeleft
@onready var wordcountlabel = %wordcountlabel

var filePath
var main_string :String
var word_count=0.0
var z:=0.0
var string_to_print
var progress:float
var wordsperminte = 60
var timeLeft

func _on_timer_timeout():
	if string_to_print:
		label.text = string_to_print
	progress_bar.value =progress
	if main_string: next_word(main_string,z)
	if z-1 == word_count:
		texts.visible = true
		resumebutton.visible = true
		pausebutton.visible = false
		z=0
		timer.stop()

func next_word (text:String,index:int):
	string_to_print = text.get_slice(" ",index)
	z+=1
	progress =  z/word_count *100
	updateWordCount()

func _on_h_slider_value_changed(value):
	wordsperminte = 60/timer.wait_time
	timer.wait_time = 1/value
	wpm.text = str(wordsperminte)+" WPM"
	updateTimeLeftIndicator()

func _on_file_dialog_file_selected(path):
	texts.visible = true
	filepathlabel.text = path
	filePath = path
	if filePath:
		var file  = FileAccess.open(filePath,FileAccess.READ)
		main_string  =  file.get_as_text()
		texts.text = main_string
		format_string()
		updateTimeLeftIndicator()
		updateWordCount()
	timerupdatetimeleft.start()

func format_string():
	if main_string.contains("\n"):
		main_string =  main_string.replace("\n"," ")
	if main_string.contains("\r"):
		main_string =  main_string.replace("\r"," ")
	if main_string.contains(","):
		main_string = main_string.replace(","," ")
	if main_string.contains("."):
		main_string =  main_string.replace("."," ")	
	if main_string.contains(";"):
		main_string =  main_string.replace(";"," ")	
	word_count = main_string.get_slice_count(" ")

func _on_pausebutton_button_down():
	resumebutton.visible = true
	pausebutton.visible = false
	texts.visible = true
	timer.paused = true
	timerupdatetimeleft.stop()

func _on_resumebutton_button_down():
	format_string()
	if main_string == null:
		file_dialog.popup()
	pausebutton.visible = true
	resumebutton.visible = false
	texts.visible = false
	timer.paused = false
	timer.start()
	timerupdatetimeleft.start()

func _on_stopbutton_button_down():
	progress = 0.0
	z=0
	texts.visible = true
	resumebutton.visible = true
	pausebutton.visible = false
	timer.stop()
	timerupdatetimeleft.stop()
	updateWordCount()
	
func _on_startbutton_button_down():
	resumebutton.visible = true
	pausebutton.visible = false
	timer.stop()
	z=0
	file_dialog.popup()

func _on_texts_text_changed():
	if texts.visible:
		main_string=texts.text
		word_count = main_string.get_slice_count(" ")
		updateTimeLeftIndicator()

func updateTimeLeftIndicator():
	if word_count:
		timeLeft = (word_count-z)/wordsperminte
		time_left.text =str(int(timeLeft)) +" mins  " + str(snapped((timeLeft - int(timeLeft))*60,1))+" seconds"

func updateWordCount():
	if word_count:
		wordcountlabel.text = str(word_count - z)+" words left"

func _on_time_left_timeout():
	updateTimeLeftIndicator()
