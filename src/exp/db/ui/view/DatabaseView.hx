package exp.db.ui.view;

import mui.core.*;
import exp.db.ui.component.*;
import exp.db.data.Database;
import exp.db.data.ValueType;

class DatabaseView extends View {
	@:attr var database:Database;
	
	@:state var activeTable:String = 'events';
	@:computed var table:TableData = database.tables.get(activeTable);
	
	static final ROOT = css('
		width: 100vw;
		height: 100vh;
		display: flex;
		flex-direction: column;
	');
	
	// function render() '<><Sheet ${...table}/></>';
	function render() '
		<div class=${ROOT}>
			<TableView ${...this}/>
			<BottomBar activeTable=${activeTable} tables=${[for(name in database.tables.keys()) name]}/>
		</div>
	';
}