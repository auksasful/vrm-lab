extends Node

var CurrentTaskText = ''
var CurrentInteractionText = ''
var CurrentTaskNum = 0
var MaxTasksNum = 10

var animation_pullup_count = 0
var animation_dip_count = 0
var animation_pushup_count = 0
var animation_benchpress_count = 0
var animation_deadlift_count = 0
var animation_run_seconds = 0
var animation_sit_seconds = 0
var animation_drink_count = 0
var animation_dumbellpress_count = 0
var animation_bicepcurl_count = 0

var required_pullup_count = 5
var required_dip_count = 5
var required_pushup_count = 5
var required_benchpress_count = 5
var required_deadlift_count = 5
var required_run_seconds = 15
var required_sit_seconds = 10
var required_drink_count = 2
var required_dumbellpress_count = 5
var required_bicepcurl_count = 5



func CheckTaskDone():
	var TaskObject = null
	if CurrentTaskNum > 10:
		get_tree().quit()
		
	if CurrentTaskNum == 0:
		CurrentTaskNum += 1
		animation_pushup_count = 0
		
	CurrentTaskText = "Task (" + str(CurrentTaskNum) + "/" + str(MaxTasksNum) + "): "
	if CurrentTaskNum == 1:
		TaskObject = PushUpMat.new()
		CurrentTaskText += TaskObject.GetExerciseName()
		CurrentTaskText += ". Left to do: (" + str(animation_pushup_count) + "/" + str(required_pushup_count) + ")"
		
		if animation_pushup_count == required_pushup_count:
			CurrentTaskNum += 1
			animation_pullup_count = 0
			CurrentTaskText = "Task (" + str(CurrentTaskNum) + "/" + str(MaxTasksNum) + "): "
	if CurrentTaskNum == 2:
		TaskObject = PullUp.new()
		CurrentTaskText += TaskObject.GetExerciseName()
		CurrentTaskText += ". Left to do: (" + str(animation_pullup_count) + "/" + str(required_pullup_count) + ")"
		
		if animation_pullup_count == required_pullup_count:
			CurrentTaskNum += 1
			animation_dip_count = 0
			CurrentTaskText = "Task (" + str(CurrentTaskNum) + "/" + str(MaxTasksNum) + "): "
	if CurrentTaskNum == 3:
		TaskObject = Dip.new()
		CurrentTaskText += TaskObject.GetExerciseName()
		CurrentTaskText += ". Left to do: (" + str(animation_dip_count) + "/" + str(required_dip_count) + ")"
		
		if animation_dip_count == required_dip_count:
			CurrentTaskNum += 1
			animation_deadlift_count = 0
			CurrentTaskText = "Task (" + str(CurrentTaskNum) + "/" + str(MaxTasksNum) + "): "
	if CurrentTaskNum == 4:
		TaskObject = BigWeightParent.new()
		CurrentTaskText += TaskObject.GetExerciseName()
		CurrentTaskText += ". Left to do: (" + str(animation_deadlift_count) + "/" + str(required_deadlift_count) + ")"
		
		if animation_deadlift_count == required_deadlift_count:
			CurrentTaskNum += 1
			animation_drink_count = 0
			CurrentTaskText = "Task (" + str(CurrentTaskNum) + "/" + str(MaxTasksNum) + "): "
	if CurrentTaskNum == 5:
		TaskObject = WaterBottle.new()
		CurrentTaskText += TaskObject.GetExerciseName()
		CurrentTaskText += ". Left to do: (" + str(animation_drink_count) + "/" + str(required_drink_count) + ")"
		
		if animation_drink_count == required_drink_count:
			CurrentTaskNum += 1
			animation_sit_seconds = 0
			CurrentTaskText = "Task (" + str(CurrentTaskNum) + "/" + str(MaxTasksNum) + "): "
	if CurrentTaskNum == 6:
		TaskObject = Bench.new()
		CurrentTaskText += TaskObject.GetExerciseName()
		CurrentTaskText += ". Left to do: (" + str(animation_sit_seconds) + "/" + str(required_sit_seconds) + ")"
		
		if animation_sit_seconds == required_sit_seconds:
			CurrentTaskNum += 1
			animation_benchpress_count = 0
			CurrentTaskText = "Task (" + str(CurrentTaskNum) + "/" + str(MaxTasksNum) + "): "
	if CurrentTaskNum == 7:
		TaskObject = BenchPress.new()
		CurrentTaskText += TaskObject.GetExerciseName()
		CurrentTaskText += ". Left to do: (" + str(animation_benchpress_count) + "/" + str(required_benchpress_count) + ")"
		
		if animation_benchpress_count == required_benchpress_count:
			CurrentTaskNum += 1
			animation_bicepcurl_count = 0
			CurrentTaskText = "Task (" + str(CurrentTaskNum) + "/" + str(MaxTasksNum) + "): "
	if CurrentTaskNum == 8:
		TaskObject = Dumbells.new()
		CurrentTaskText += TaskObject.GetExerciseName()
		CurrentTaskText += ". Left to do: (" + str(animation_bicepcurl_count) + "/" + str(required_bicepcurl_count) + ")"
		
		if animation_bicepcurl_count == required_bicepcurl_count:
			CurrentTaskNum += 1
			animation_dumbellpress_count = 0
			CurrentTaskText = "Task (" + str(CurrentTaskNum) + "/" + str(MaxTasksNum) + "): "
	if CurrentTaskNum == 9:
		TaskObject = InclineBench.new()
		CurrentTaskText += TaskObject.GetExerciseName()
		CurrentTaskText += ". Left to do: (" + str(animation_dumbellpress_count) + "/" + str(required_dumbellpress_count) + ")"
		
		if animation_dumbellpress_count == required_dumbellpress_count:
			CurrentTaskNum += 1
			animation_run_seconds = 0
			CurrentTaskText = "Task (" + str(CurrentTaskNum) + "/" + str(MaxTasksNum) + "): "
	if CurrentTaskNum == 10:
		TaskObject = TreadMill.new()
		CurrentTaskText += TaskObject.GetExerciseName()
		CurrentTaskText += ". Left to do: (" + str(animation_run_seconds) + "/" + str(required_run_seconds) + ")"
		
		if animation_run_seconds >= required_run_seconds:
			CurrentTaskNum += 1
			CurrentTaskText = "Task (" + str(CurrentTaskNum) + "/" + str(MaxTasksNum) + "): "
