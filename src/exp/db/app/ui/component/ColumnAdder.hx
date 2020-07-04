package exp.db.app.ui.component;

import mui.core.*;
using StringTools;
class ColumnAdder extends View {
	@:attr var open:Bool;
	@:attr var columns:PureList<Column>;
	@:attr var tables:PureList<String>;
	@:attr var customs:PureList<String>;
	@:attr var onCancel:Void->Void = null;
	@:attr var onConfirm:Column->Void;
	@:attr var initial:Column = null;
	
	@:state var type:ValueType = Integer;
	@:state var name:String = '';
	
	static final ENUMERATION_REGEX = ~/^[A-Z][A-Za-z0-9_]*$/;
	
	@:computed var validation:Option<Error> = {
		if(name.length == 0) {
			Some(new Error('Please input name'));
		} else if(columns.exists(v -> v.name == name)) {
			Some(new Error('Column name already exists'));
		} else switch type {
			case Ref(null):
				Some(new Error('Please select a referenced table'));
			case Enumeration(list):
				if(list.length == 0)
					Some(new Error('Please input a list of enumeration'));
				else if(list.exists(v -> v == ''))
					Some(new Error('Empty enumeration entry'));
				else if(list.exists(v -> !ENUMERATION_REGEX.match(v)))
					Some(new Error('Invalid enumeration entry'));
				else if(hasDuplicate(list))
					Some(new Error('Duplicated enumeration entry'));
				else
					None;
			case Custom(null):
				Some(new Error('Please select a custom type'));
			case Identifier if(columns.exists(v -> v.type == Identifier)):
				Some(new Error('Only one Identifier column is allowed'));
			case _: None;
		}
	}
	
	function render() '
		<Dialog open=${open} onClose=${onCancel} maxWidth=${XS} fullWidth>
			<DialogTitle>Add Column</DialogTitle>
			<DialogContent>
				<TextField
					autoFocus
					margin=${Dense}
					label="Name"
					value=${name}
					onChange=${e -> {
						name = (cast e.target).value;
						Renderer.updateAll();
					}}
					fullWidth
				/>
				<ValueTypeSelector
					type=${type}
					tables=${tables}
					customs=${customs}
				/>
			</DialogContent>
			<DialogActions>
				<FormControl error=${validation != None}>
					<FormHelperText>${validation.map(e -> e.message).orNull()}</FormHelperText>
				</FormControl>
				<Button onClick=${onCancel} color=${Primary}>
					Close
				</Button>
				<Button disabled=${validation != None} onClick=${confirm} color=${Primary}>
					${initial == null ? 'Add' : 'Edit'}
				</Button>
			</DialogActions>
		</Dialog>
	';
	
	function confirm(_) {
		onConfirm({name: name, type: type});
		name = '';
	}
	
	function viewDidMount() {
		if(initial != null) {
			Callback.defer(() -> {
				name = initial.name;
				type = initial.type;
			});
		}
	}
	
	static function hasDuplicate(list:PureList<String>) {
		var map = new Map();
		for(v in list) if(map.exists(v)) return true else map[v] = true;
		return false;
	}
}

