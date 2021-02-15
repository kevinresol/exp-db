package exp.db.app.data;

import exp.db.*;
import exp.db.Database;
import exp.db.Table;

using tink.CoreApi;

typedef Raw = {
	final schema:String;
	final content:String;
}
class DatabaseModel implements Model {
	@:constant var tables:ObservableMap<String, TableModel> = @byDefault new ObservableMap([]);
	@:editable var types:List<CustomType> = @byDefault null;
	
	@:computed var tableNames:List<String> = [for(table in tables.keys()) table];
	@:computed var typeNames:List<String> = types.map(t -> t.name);
	
	public function addTable(name:String) {
		if(!tables.exists(name)) tables.set(name, new TableModel({name: name}));
	}
	
	public static function fromRaw(raw:Raw) {
		return switch [tink.Json.parse((raw.schema:DatabaseSchema)), tink.Json.parse((raw.content:DatabaseContent))] {
			case [Failure(e), _]:
				Failure(new Error('Invalid schema data'));
			case [_, Failure(e)]:
				Failure(new Error('Invalid content data'));
			case [Success(schema), Success(content)]:
				Success(fromDatabase({
					tables: [for(table in schema.tables) {
						name: table.name,
						columns: table.columns,
						rows: content.tables.first(v -> v.name == table.name).map(v -> v.rows).orNull(),
					}],
					types: schema.types,
				}));
		}
	}
	
	public function toRaw():Raw {
		inline function format(json:String):String return js.Lib.require('prettier').format(json, {parser: 'json'});
		
		return {
			schema: format(tink.Json.stringify(getSchema())),
			content: format(tink.Json.stringify(getContent())),
		}
	}
	
	public static function fromDatabase(v:Database) {
		return new DatabaseModel({
			tables: new ObservableMap([for(table in v.tables) table.name => TableModel.fromTable(table)]),
			types: v.types,
		});
	}
	
	public function getSchema():DatabaseSchema {
		return {
			tables: [for(table in tables) table.getSchema()],
			types: types,
		}
		
	}
	
	public function getContent():DatabaseContent {
		return {
			tables: [for(table in tables) table.getContent()],
		}
	}
	
	public function toDatabase():Database {
		return {
			tables: [for(table in tables) table.toTable()],
			types: types,
		}
	}
}

class TableModel implements Model {
	@:editable var name:String;
	@:constant var columns:ObservableArray<Column> = @byDefault new ObservableArray();
	@:constant var rows:ObservableArray<ObservableMap<String, Content>> = @byDefault new ObservableArray();
	
	@:computed var columnNames:List<String> = [for(column in columns.values()) column.name];
	
	public static function fromTable(v:Table) {
		return new TableModel({
			name: v.name,
			columns: fromColumns(v.columns),
			rows: fromRows(v.rows),
		});
	}
	
	public function toTable():Table {
		return {
			name: name,
			columns: toColumns(columns),
			rows: toRows(rows),
		}
	}
	
	public function getSchema():TableSchema {
		return {
			name: name,
			columns: toColumns(columns),
		}
		
	}
	
	public function getContent():TableContent {
		return {
			name: name,
			rows: toRows(rows)
		}
	}
	
	public static function fromColumns(v:List<Column>):ObservableArray<Column> {
		return new ObservableArray(v.toArray());
	}
	
	public static function toColumns(v:ObservableArray<Column>):List<Column> {
		return v.toArray();
	}
	
	public static function fromRows(v:List<Row>):ObservableArray<ObservableMap<String, Content>> {
		return new ObservableArray([for(row in v) new ObservableMap([for(name => value in row) name => (value:Content)])]);
	}
	
	public static function toRows(v:ObservableArray<ObservableMap<String, Content>>):List<Row> {
		return [for(row in v.values()) ([for(key in row.keys()) key => row.get(key).value]:Row)];
	}
}


@:forward
abstract Content(ContentObject) from ContentObject to ContentObject {
	@:from public static inline function fromValue(v:Value):Content {
		return {
			value: v,
			interim: null,
		}
	}
}

typedef ContentObject = {
	final value:Value;
	final interim:{
		final value:String;
		final error:String;
	};
}