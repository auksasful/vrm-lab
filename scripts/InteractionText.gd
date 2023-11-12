extends RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	# Ensure BBCode is enabled
	self.bbcode_enabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#self.text = Global.CurrentInteractionText


	# Set BBCode text with center alignment
	self.bbcode_text = "[center]" + Global.CurrentInteractionText + "[/center]"
