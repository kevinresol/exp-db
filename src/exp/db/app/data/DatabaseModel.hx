package exp.db.app.data;

import exp.db.*;

class DatabaseModel implements Model {
	@:constant var tables:ObservableMap<String, TableModel> = new ObservableMap([]);
	@:constant var customTypes:ObservableArray<CustomTypeModel> = new ObservableArray();
	
	@:computed var tableNames:List<String> = [for(table in tables.keys()) table];
	
	public function addTable(name:String) {
		if(!tables.exists(name)) tables.set(name, new TableModel({name: name}));
	}
}

class TableModel implements Model {
	@:editable var name:String;
	@:constant var columns:ObservableArray<Column> = new ObservableArray();
	@:constant var rows:ObservableArray<ObservableMap<String, Content>> = new ObservableArray();
	
	@:computed var columnNames:List<String> = [for(column in columns.values()) column.name];
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