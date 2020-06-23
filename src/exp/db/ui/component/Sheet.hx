package exp.db.ui.component;

import exp.db.data.Database;
import exp.db.data.Value;
import exp.db.data.ValueType;
import haxe.DynamicAccess;
import mui.core.*;
import mui.core.styles.Styles.*;
import DataSheet;

enum CellValue {
	Header(v:String);
	Invalid(v:String);
	Value(v:Value);
}
	
// @:react.hoc(withStyles(styles))
class Sheet extends View {
	@:attr var columns:ObservableArray<Column>;
	@:attr var rows:ObservableArray<ObservableMap<String, Value>>;
	
	@:skipCheck @:computed var header:Array<Cell<CellValue>> = {
		var ret = [{value: Header(''), readOnly: true}];
		for(column in columns.values())
			ret.push({
				value: Header(column.name),
				readOnly: true,
			});
		ret;
	}
	
	@:skipCheck @:computed var footer:Array<Cell<CellValue>> = {
		var ret:Array<Cell<CellValue>> = [{value: Header(''), readOnly: true}];
		for(column in columns.values())
			ret.push({value: Invalid('')});
		ret;
	}
	
	@:skipCheck @:computed var data:Array<Array<Cell<CellValue>>> = {
		trace('data');
		var ret = [header];
		for(r in 0...rows.length) {
			var row:Array<Cell<CellValue>> = [{value: Header('$r'), readOnly: true}];
			for(column in columns.values())
				row.push({
					value: switch rows.get(r).get(column.name) {
						case null: Invalid('');
						case v: Value(v);
					}
				});
			ret.push(row);
		}
		ret.push(footer);
		ret;
	}
	
	
	
	// @:react.injected var classes:{
	// 	table:String,
	// };
	
	// static function styles(theme) return {
	// 	table: {
			
	// 	},
	// }
	
	static final CONTAINER = css('
		& * {
			box-sizing: initial;
		}
		& .data-grid-container {
			& table.data-grid {
				margin: auto;
				width: 100%;
				
				& tr:first-child td:first-child {
					width: 40px;
				}
				
				& .cell {
					height: 24px;
					& > span.value-viewer {
						height: 21px;
					}
					& > input.data-editor {
						font-size: 0.875rem;
						height: 18px;
					}
				} 
			}
		}
	');
	
	function render() '
		<div class=${CONTAINER}>
		<DataSheet
			data=${data}
			valueRenderer=${(cell, i, j) -> valueToString(cell.value)}
			dataRenderer=${(cell, i, j) -> valueToString(cell.value)}
			onContextMenu=${onContextMenu}
			onCellsChanged=${onCellsChanged}
		/>
		</div>
	';
	
	function onContextMenu(event:js.html.Event, cell:Cell<CellValue>, row:Int, col:Int) {
		trace(event);
	}
	
	function onCellsChanged(changes:Array<Change<CellValue>>, additions:Array<Addition>) {
		
		function handle(v:Addition) {
			var c = v.col - 1; // minus header offset
			var r = v.row - 1; // minus header offset
			
			var column = columns.get(c);
			var row = switch rows.get(r) { // minus header offset
				case null:
					var row = new ObservableMap([]);
					rows.set(r, row);
					row;
				case row:
					row;
			}
			
			row.set(column.name, parseValue(column.type, v.value));
		}
		
		for(change in changes) handle(change);
		if(additions != null) for(addition in additions) handle(addition);
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
	
	function valueToString(value:CellValue):String {
		return switch value {
			case Header(v):
				v;
			case Invalid(v):
				v;
			case Value(v):
				switch v {
					case Identifier(v): v;
					case Integer(v): '$v';
					case Text(v): v;
					case Ref(v): v;
					case Custom(v): null;
				}
		}
	}
}