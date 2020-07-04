package exp.db.app.data;

import tink.core.ext.Outcomes;
import tink.core.ext.Promises;
import exp.db.Database;
import haxe.io.Path;

using sys.io.File;
using tink.CoreApi;

class AppModel implements Model {
	@:observable var database:DatabaseModel = null;
	@:observable var savePath:String = null;
	
	@:transition
	function newDatabase() {
		return {database: new DatabaseModel()}
	}
	
	@:transition
	function openDatabase() {
		return selectDirectory()
			.next(path -> {
				Outcomes.multi({
					schema: tink.Json.parse((Path.join([path, 'schema.json']).getContent():DatabaseSchema)),
					content: tink.Json.parse((Path.join([path, 'content.json']).getContent():DatabaseContent)),
					path: Success(path),
				});
			})
			.next(data -> {
				savePath: data.path,
				database: DatabaseModel.fromDatabase({
					tables: [for(table in data.schema.tables) {
						name: table.name,
						columns: table.columns,
						rows: data.content.tables.first(v -> v.name == table.name).map(v -> v.rows).orNull(),
					}],
					types: data.schema.types,
				}),
			});
	}
	
	@:transition
	function saveDatabase() {
		return (savePath == null ? selectDirectory() : Promise.resolve(savePath))
			.next(path -> {
				Path.join([path, 'schema.json']).saveContent(formatJson(tink.Json.stringify(database.getSchema())));
				Path.join([path, 'content.json']).saveContent(formatJson(tink.Json.stringify(database.getContent())));
				@patch {savePath: path}
			});
	}
	
	static function selectDirectory() {
		return Promise.ofJsPromise(js.Lib.require('electron').remote.dialog.showOpenDialog({properties: ['openDirectory']}))
			.next(o -> !o.canceled ? Promise.resolve(o.filePaths[0]) : new Error('cancelled'));
	}
	
	static function formatJson(json:String):String {
		return js.Lib.require('prettier').format(json, {parser: 'json'});
	}
}