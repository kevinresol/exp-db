package exp.db.app.ui.view;

import mui.core.*;
import mui.icon.Add as AddIcon;
import exp.db.app.ui.component.*;
import exp.db.app.data.DatabaseModel;
import exp.db.ValueType;

class TableView extends View {
	@:attr var database:DatabaseModel;
	@:attr var table:TableModel;
	
	@:state var showColumnAdder:Bool = false;
	@:computed var columns:PureList<Column> = [for(column in table.columns.values()) column];
	
	static final MAIN = css('
		flex: 1;
		background-color: grey;
		overflow-y: scroll;
	');
	
	// function render() '<><Sheet ${...table}/></>';
	function render() '
		<>
			<TopBar>
				<IconButton onClick=${_ -> showColumnAdder = true}>
					<AddIcon/>
				</IconButton>
			</TopBar>
			<Paper class=${MAIN}>
				<Sheet ${...table}/>
				<ColumnAdder
					open=${showColumnAdder}
					columns=${columns}
					tables=${database.tableNames}
					onCancel=${showColumnAdder = false}
					onConfirm=${table.columns.push}
				/>
			</Paper>
		</>
	';
}

class ColumnAdder extends View {
	@:attr var open:Bool;
	@:attr var columns:PureList<Column>;
	@:attr var tables:PureList<String>;
	@:attr var onCancel:Void->Void = null;
	@:attr var onConfirm:Column->Void;
	
	@:state var type:ValueType = Integer;
	@:state var name:String = '';
	
	@:computed var validation:Option<Error> = {
		if(name.length == 0) {
			Some(new Error('Please input name'));
		} else if(columns.exists(v -> v.name == name)) {
			Some(new Error('Column name already exists'));
		} else switch type {
			case Ref(null):
				Some(new Error('Please select a referenced table'));
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
					onChange=${e -> name = (cast e.target).value}
					fullWidth
				/>
				<ValueTypeSelector
					type=${type}
					tables=${tables}
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
		onConfirm({name: name, type: type});
		name = '';
	}
}

