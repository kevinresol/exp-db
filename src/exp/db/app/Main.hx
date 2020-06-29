package exp.db.app;

import haxe.macro.Expr.TypeDefKind;
import coconut.react.*;
import exp.db.app.ui.*;
import exp.db.app.data.DatabaseModel;
import exp.db.Database;
import exp.db.Value;
import exp.db.Column;
import exp.db.CustomType;
import tink.state.*;
import tink.pure.List.fromArray as list;
import tink.core.ext.Outcomes;

using haxe.io.Path;
using sys.io.File;
using tink.CoreApi;

class Main {
	static function main() {
		Promise.ofJsPromise(js.Lib.require('electron').remote.dialog.showOpenDialog({properties: ['openDirectory']}))
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
			.handle(function(o) switch o {
				case Success(data):
					var database = DatabaseModel.fromDatabase({
						tables: [for(table in data.schema.tables) {
							name: table.name,
							columns: table.columns,
							rows: data.content.tables.first(v -> v.name == table.name).map(v -> v.rows).orNull(),
						}],
						types: data.schema.types,
					});
					
					var div = js.Browser.document.createDivElement();
					js.Browser.document.body.appendChild(div);
					Renderer.mount(div, '<AppContainer database=${database}/>');
					
				case Failure(e):
					trace(e);
			});
		
		// var database = new DatabaseModel({
		// 	types: [new CustomType({
		// 		name: 'Event',
		// 		fields: [{
		// 			name: 'Combined',
		// 			args: [{
		// 				name: 'e1',
		// 				type: exp.db.ValueType.Custom('Event'),
		// 			}, {
		// 				name: 'e2',
		// 				type: exp.db.ValueType.Custom('Event'),
		// 			}],
		// 		}, {
		// 			name: 'Grow',
		// 			args: [{
		// 				name: 'value',
		// 				type: exp.db.ValueType.Integer,
		// 			}],
		// 		}],
		// 	})],
		// });
		
		// database.addTable('events');
		// var table = database.tables.get('events');
		// table.columns.push({name: 'id', type: Identifier});
		// table.columns.push({name: 'sub', type: SubTable(list([{name: 'foo', type: exp.db.ValueType.Integer}]))});
		// table.columns.push({name: 'title', type: Integer});
		// table.columns.push({name: 'description', type: Text});
		// for(i in 0...25) 
		// 	table.rows.push(new ObservableMap<String, Content>(['id' => Identifier('id_$i'), 'sub' => SubTable([]), 'title' => Integer(i), 'description' => Text('My Game')]));
		
		// database.addTable('foo');
		// var table = database.tables.get('foo');
		// table.columns.push({name: 'title2', type: Integer});
		// table.columns.push({name: 'description2', type: Text});
		// table.columns.push({name: 'foo', type: Text});
		// for(i in 0...50) 
		// 	table.rows.push(new ObservableMap<String, Content>(['title2' => Integer(i+10), 'description2' => Text('My Game'), 'foo' => Text('jj$i')]));
		
		
		
	}
}