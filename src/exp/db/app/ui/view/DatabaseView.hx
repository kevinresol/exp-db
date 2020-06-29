package exp.db.app.ui.view;

import mui.core.*;
import exp.db.app.ui.component.*;
import exp.db.app.data.DatabaseModel;
import exp.db.ValueType;

class DatabaseView extends View {
	@:attr var database:DatabaseModel;
	
	@:state var showTableAdder:Bool = false;
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
				<TableAdder
					open=${showTableAdder}
					tables=${database.tableNames}
					onCancel=${showTableAdder = false}
					onConfirm=${name -> {database.addTable(name); showTableAdder = false;}}
				/>
			</div>
			<BottomBar
				activeTable=${activeTable}
				showCustomTypeEditor=${showCustomTypeEditor}
				tables=${[for(name in database.tables.keys()) name]}
			>
				<Tooltip title="New Table">
					<IconButton onClick=${_ -> showTableAdder = true}>
						<FontAwesomeIcon name="plus-circle"/>
					</IconButton>
				</Tooltip>
				<Tooltip title="Edit Custom Types">
					<IconButton onClick=${_ -> {showCustomTypeEditor = true; activeTable = null;}}>
						<FontAwesomeIcon name="book-spells"/>
					</IconButton>
				</Tooltip>
				<Tooltip title="Export">
					<IconButton onClick=${export}>
						<FontAwesomeIcon name="download"/>
					</IconButton>
				</Tooltip>
			</BottomBar>
		</div>
	';
	
	function export() {
		Promise.ofJsPromise(js.Lib.require('electron').remote.dialog.showOpenDialog({
			properties: ['openDirectory', 'createDirectory'],
		}))
			.handle(function(o) switch o {
				case Success(o):
					if(!o.canceled) {
						sys.io.File.saveContent(haxe.io.Path.join([o.filePaths[0], 'schema.json']), tink.Json.stringify(database.getSchema()));
						sys.io.File.saveContent(haxe.io.Path.join([o.filePaths[0], 'content.json']), tink.Json.stringify(database.getContent()));
						
					}
				case Failure(e):
					trace(e);
			});

	}
} 