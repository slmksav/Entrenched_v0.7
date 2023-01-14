extends RichTextLabel
var category:String
var iserror=false
func _ready():
	update()
	var error=globals.console.connect("categorychange",self,"update")
	if error!=OK:
		globals.iprint(["couldnt connect to the console to check the category, error",error],"consolecode",true)
func update():
	if globals.console.categories.has(category):
		visible=globals.console.categories[category]
