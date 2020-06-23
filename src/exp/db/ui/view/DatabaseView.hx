package exp.db.ui.view;

import mui.core.*;
import exp.db.ui.component.*;
import exp.db.data.DatabaseModel;
import exp.db.data.ValueType;

class DatabaseView extends View {
	@:attr var database:DatabaseModel;
	
	@:state var showCustomTypeEditor:Bool = false;
	@:state var activeTable:String = 'events';
	@:computed var table:TableModel = database.tables.get(activeTable);
	
	static final ROOT = css('
		width: 100vw;
		height: 100vh;
		display: flex;
		flex-direction: column;
	');
	
	static final CONTAINER = css('
		flex: 1;
		display: flex;
		flex-direction: column;
		overflow-y: scroll;
	');
	
	// function render() '<><Sheet ${...table}/></>';
	function render() '
		<div class=${ROOT}>
			<div class=${CONTAINER}>
				<if ${showCustomTypeEditor}>
					<CustomTypeEditor tables=${database.tableNames} />
				</if>
				<if ${table != null}>
					<TableView database=${database} table=${table}/>
				</if>
			</div>
			<BottomBar
				activeTable=${activeTable}
				showCustomTypeEditor=${showCustomTypeEditor}
				tables=${[for(name in database.tables.keys()) name]}
			/>
		</div>
	';
}