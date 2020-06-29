package exp.db.app.ui.component;

import mui.core.*;

class TableAdder extends View {
	@:attr var open:Bool;
	@:attr var tables:PureList<String>;
	@:attr var onCancel:Void->Void = null;
	@:attr var onConfirm:String->Void;
	
	@:state var name:String = '';
	
	@:computed var validation:Option<Error> = {
		if(name.length == 0) {
			Some(new Error('Please input name'));
		} else if(tables.exists(v -> v == name)) {
			Some(new Error('Table name already exists'));
		} else {
			None;
		}
	}
	
	function render() '
		<Dialog open=${open} onClose=${onCancel} maxWidth=${XS} fullWidth>
			<DialogTitle>Add Table</DialogTitle>
			<DialogContent>
				<TextField
					autoFocus
					margin=${Dense}
					label="Name"
					value=${name}
					onChange=${e -> name = (cast e.target).value}
					fullWidth
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
					Add
				</Button>
			</DialogActions>
		</Dialog>
	';
	
	function confirm(_) {
		onConfirm(name);
		name = '';
	}
}

