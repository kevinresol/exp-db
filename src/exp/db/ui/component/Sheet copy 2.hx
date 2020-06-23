package exp.db.ui.component;

import exp.db.data.Database;
import exp.db.data.Value;
import exp.db.data.ValueType;
import haxe.DynamicAccess;
import mui.core.*;
import mui.core.styles.Styles.*;

	
@:react.hoc(withStyles(styles))
class Sheet extends View {
	@:attr var columns:ObservableArray<Column>;
	@:attr var rows:ObservableArray<ObservableMap<String, Value>>;
	
	@:react.injected var classes:{
		table:String,
	};
	
	static function styles(theme) return {
		table: {
			
		},
	}
	
	function render() '
		<MaterialTable
			title="Demo Title"
			columns=${[for(column in columns.values()) {title: column.name, field: column.name}]}
			data=${[for(row in rows.values()) toObject(row)]}
			options=${{
				paging: false,
				headerStyle: { position: 'sticky', top: '0' },
			}}
			editable=${{
				onRowAdd: onRowAdd,
				onRowUpdate: onRowUpdate,
				onRowDelete: (oldData) -> {
					trace(haxe.Json.stringify(oldData, '  '));
					js.lib.Promise.resolve();
				},
			}}
		/>
	';
	
	override function viewDidMount() {
		var i:Dynamic = 12;
		var s:Dynamic = '12';
		trace(i == s);
		
	}
	
	function onRowAdd(data:DynamicAccess<String>) {
		rows.push(new ObservableMap([for(column in columns.values()) column.name => parseValue(column.type, data[column.name])]));
		
		return js.lib.Promise.resolve();
	}
	
	function onRowUpdate(nu:DynamicAccess<String>, old:DynamicAccess<String>) {
		for(column in columns.values()) {
			var n = nu[column.name];
			var o = old[column.name];
			if(n != o) {
				var i:Int = (cast old['tableData']).id;
				rows.get(i).set(column.name, parseValue(column.type, n));
			}
		}
		return js.lib.Promise.resolve();
	}
	
	function parseValue(type:ValueType, value:String):Value {
		return switch type {
			case Identifier: null;
			case Integer: Integer(Std.parseInt(value));
			case Text: Text(value);
			case Ref(table): null;
			case Custom(v): null;
		}
	}
	
	function toObject(map:ObservableMap<String, Value>) {
		var o:DynamicAccess<Dynamic> = {}
		for(key in map.keys()) o.set(key, switch map.get(key) {
			case Identifier(v): v;
			case Integer(v): v;
			case Text(v): v;
			case Ref(v): v;
			case Custom(v): null;
		});
		return o;
	}
}