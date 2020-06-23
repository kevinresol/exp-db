package exp.db.ui.view;

import mui.core.*;
import exp.db.ui.component.*;
import exp.db.data.Database;
import exp.db.data.ValueType;

class TableView extends View {
	@:attr var database:Database;
	@:attr var table:TableData;
	
	@:state var showColumnAdder:Bool = false;
	
	static final MAIN = css('
		flex: 1;
		background-color: grey;
		overflow-y: scroll;
	');
	
	// function render() '<><Sheet ${...table}/></>';
	function render() '
		<>
			<TopBar onAdd=${showColumnAdder = true}/>
			<Paper class=${MAIN}>
				<Sheet ${...table}/>
				<ColumnAdder
					open=${showColumnAdder}
					columns=${table.columnNames}
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
	@:attr var columns:PureList<String>;
	@:attr var tables:PureList<String>;
	@:attr var onCancel:Void->Void = null;
	@:attr var onConfirm:Column->Void;
	
	@:state var type:ValueType = Integer;
	@:state var name:String = '';
	
	@:computed var validation:Option<Error> = {
		if(name.length == 0) {
			Some(new Error('Please input name'));
		} else if(columns.exists(v -> v == name)) {
			Some(new Error('Column name already exists'));
		} else switch type {
			case Ref(null): Some(new Error('Please select a referenced table'));
			case Custom(null): Some(new Error('Please select a custom type'));
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
					Cancel
				</Button>
				<Button disabled=${validation != None} onClick=${confirm} color=${Primary}>
					Confirm
				</Button>
			</DialogActions>
		</Dialog>
	';
	
	function confirm(_) {
		onConfirm({name: name, type: type});
		name = '';
	}
}

class ValueTypeSelector extends View {
	@:attr var tables:PureList<String>;
	@:controlled var type:ValueType;
	
	static var list:Array<ValueType> = [
		Identifier,
		Integer,
		Text,
		Ref(null),
		Custom(null),
	];
	
	function render() '
		<>
			<FormControl fullWidth margin=${Dense}>
				<InputLabel>Type</InputLabel>
				<Select
					value=${type.getIndex()}
					onChange=${e -> type = list[(cast e.target).value]}
				>
					<for ${v in list}>
						<MenuItem value=${v.getIndex()}>${v.getName()}</MenuItem>
					</for>
				</Select>
			</FormControl>
			<switch ${type}>
				<case ${Ref(v)}>
					<FormControl fullWidth margin=${Dense}>
						<InputLabel>Table</InputLabel>
						<Select
							value=${v == null ? '' : v}
							onChange=${e -> type = Ref((cast e.target).value)}
						>
							<for ${table in tables}>
								<MenuItem value=${table}>${table}</MenuItem>
							</for>
						</Select>
					</FormControl>
				<case ${_}>
			</switch>
		</>
	';
}