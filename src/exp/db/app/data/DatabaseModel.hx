package exp.db.app.data;

import exp.db.*;

class DatabaseModel implements Model {
	@:constant var tables:ObservableMap<String, TableModel> = @byDefault new ObservableMap([]);
	@:editable var types:List<CustomType> = @byDefault null;
	
	@:computed var tableNames:List<String> = [for(table in tables.keys()) table];
	@:computed var typeNames:List<String> = types.map(t -> t.name);
	
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