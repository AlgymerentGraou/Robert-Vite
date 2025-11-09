extends Label


var defult_text = "Score : "

func _process(delta: float) -> void:
	self.text = (str(defult_text, str(GlobalScore.robert_score)))
