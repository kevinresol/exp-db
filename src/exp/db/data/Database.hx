package exp.db.data;

class Database implements Model {
	@:constant var tables:ObservableMap<String, TableData> = new ObservableMap([]);
	@:computed var tableNames:List<String> = [for(table in tables.keys()) table];
	
	public function addTable(name:String) {
		if(!tables.exists(name)) tables.set(name, new TableData({name: name}));
	}
}

class TableData implements Model {
	@:editable var name:String;
	@:constant var columns:ObservableArray<Column> = new ObservableArray();
	@:constant var rows:ObservableArray<ObservableMap<String, Value>> = new ObservableArray();
	
	@:computed var columnNames:List<String> = [for(column in columns.values()) column.name];
}

typedef Column = {
	final name:String;
	final type:ValueType;
}