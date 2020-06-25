package exp.db.app.ui.view;

import mui.core.*;
import mui.icon.Add as AddIcon;
import exp.db.app.ui.component.*;
import exp.db.app.data.DatabaseModel;
import exp.db.ValueType;

class TableView extends View {
	@:attr var database:DatabaseModel;
	@:attr var table:TableModel;
	
	static final MAIN = css('
		flex: 1;
		background-color: grey;
		overflow-y: scroll;
	');
	
	// function render() '<><Sheet ${...table}/></>';
	function render() '
		<Paper class=${MAIN}>
			<Sheet ${...table} tableNames=${database.tableNames} typeNames=${database.typeNames} getCustomType=${getCustomType}/>
		</Paper>
	';
	
	function getCustomType(name) {
		return switch database.types.first(v -> v.name == name) {
			case Some(v): Success(v);
			case None: Failure(new Error('Type "$name" not found'));
		}
	}
}

