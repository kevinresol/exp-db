package exp.db.data;

class Database implements Model {
	@:constant var tables:ObservableMap<String, TableData> = new ObservableMap([]);
	
	public function addTable(name:String) {
		if(!tables.exists(name)) tables.set(name, new TableData({name: name}));
	}
}

class TableData implements Model {
	@:editable var name:String;
	@:constant var columns:ObservableArray<Column> = new ObservableArray();
	@:constant var rows:ObservableArray<ObservableMap<String, Value>> = new ObservableArray();
}

typedef Column = {
	final name:String;
	final type:ValueType;
}