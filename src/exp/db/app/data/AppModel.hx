package exp.db.app.data;

import tink.core.ext.Outcomes;
import exp.db.Database;
import haxe.io.Path;

using sys.io.File;
using tink.CoreApi;

class AppModel implements Model {
	@:observable var database:DatabaseModel = null;
	
	@:transition
	function newDatabase() {
		return {database: new DatabaseModel()}
	}
	@:transition
	function openDatabase() {
		return Promise.ofJsPromise(js.Lib.require('electron').remote.dialog.showOpenDialog({properties: ['openDirectory']}))
			.next(o -> {
				if(!o.canceled) {
					Outcomes.multi({
						schema: tink.Json.parse((Path.join([o.filePaths[0], 'schema.json']).getContent():DatabaseSchema)),
						content: tink.Json.parse((Path.join([o.filePaths[0], 'content.json']).getContent():DatabaseContent)),
					});
				} else {
					Failure(new Error('cancelled'));
				}
			})
			.next(data -> {
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
}