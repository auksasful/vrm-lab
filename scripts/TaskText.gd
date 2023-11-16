extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	self.bbcode_enabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.bbcode_text = "[center]" + Global.CurrentTaskText + "[/center]"
