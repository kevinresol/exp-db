package exp.db.app.data;

import exp.db.*;

class DatabaseModel implements Model {
	@:constant var tables:ObservableMap<String, TableModel> = @byDefault new ObservableMap([]);
	@:editable var types:List<CustomType> = @byDefault null;
	
	@:computed var tableNames:List<String> = [for(table in tables.keys()) table];
	
	public function addTable(name:String) {
		if(!tables.exists(name)) tables.set(name, new TableModel({name: name}));
	}
	
	public static function fromDatabase(v:Database) {
		return new DatabaseModel({
			tables: new ObservableMap([for(table in v.tables) table.name => TableModel.fromTable(table)]),
			types: v.types,
		});
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
			columns: new ObservableArray(v.columns.toArray()),
			rows: new ObservableArray([for(row in v.rows) new ObservableMap([for(name => value in row) name => (value:Content)])]),
		});
	}
	
	public function toTable():Table {
		return {
			name: name,
			columns: columns.toArray(),
			rows: [for(row in rows.values()) ([for(key in row.keys()) key => row.get(key).value]:Row)],
		}
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
	final interim:String;
}