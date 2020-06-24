package exp.db.app.ui.view;

import mui.core.*;
import mui.icon.Add as AddIcon;
import mui.icon.Save as SaveIcon;
import exp.db.app.ui.component.*;
import exp.db.app.data.DatabaseModel;
import exp.db.ValueType;

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
					<CustomTypeEditor
						tables=${database.tableNames}
						initialValue=${database.types}
						onSubmit=${types -> database.types = types}
					/>
				</if>
				<if ${table != null}>
					<TableView database=${database} table=${table}/>
				</if>
			</div>
			<BottomBar
				activeTable=${activeTable}
				showCustomTypeEditor=${showCustomTypeEditor}
				tables=${[for(name in database.tables.keys()) name]}
			>
				<IconButton>
					<AddIcon onClick=${_ -> {showCustomTypeEditor = true; activeTable = null;}}/>
				</IconButton>
				<IconButton>
					<SaveIcon onClick=${_ -> trace(tink.Json.stringify(database.toDatabase()))}/>
				</IconButton>
			</BottomBar>
		</div>
	';
}