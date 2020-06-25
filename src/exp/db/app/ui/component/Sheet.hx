package exp.db.app.ui.component;

import exp.db.app.data.DatabaseModel;
import exp.db.Value;
import exp.db.ValueType;
import haxe.DynamicAccess;
import mui.core.*;
import mui.core.styles.Styles.*;
import DataSheet;
import tink.Anon.merge;

enum CellValue {
	Header(v:String);
	Invalid(v:String);
	Value(v:Value);
	Empty;
}
	
// @:react.hoc(withStyles(styles))
class Sheet extends View {
	@:attr var tableNames:PureList<String>;
	@:attr var typeNames:PureList<String>;
	@:attr var getCustomType:String->Outcome<CustomType, Error>;
	
	@:attr var columns:ObservableArray<Column>;
	@:attr var rows:ObservableArray<ObservableMap<String, Content>>;
	@:attr var depth:Int = 0;
	
	@:state var showColumnAdder:Bool = false;
	@:state var disablePageClick:Bool = false;
	
	@:skipCheck @:computed var header:Array<Cell<CellValue>> = {
		var ret = [{value: Header(''), readOnly: true, disableEvents: true}];
		for(column in columns.values())
			ret.push({
				value: Header('${column.name} (${column.type.getName()})'),
				readOnly: true, disableEvents: true,
			});
		ret;
	}
	
	@:skipCheck @:computed var footer:Array<Cell<CellValue>> = {
		var ret:Array<Cell<CellValue>> = [{value: Header(''), readOnly: true, disableEvents: true}];
		for(column in columns.values())
			ret.push({value: Empty});
		ret;
	}
	
	@:skipCheck @:computed var data:Array<Array<Cell<CellValue>>> = {
		var ret = [header];
		for(r in 0...rows.length) {
			var row:Array<Cell<CellValue>> = [{value: Header('$r'), readOnly: true, disableEvents: true}];
			for(column in columns.values())
				row.push({
					value: switch rows.get(r).get(column.name) {
						case null: Invalid('');
						case v if(v.interim != null): Invalid(v.interim);
						case v: Value(v.value);
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
	
	var ADD_COLUMN_BUTTON:coconut.react.RenderResult = coconut.react.Renderer.hxx('<button onclick=${showColumnAdder = true}>+col</button>');
	
	function render() '
		<div class=${CONTAINER}>
			<DataSheet
				data=${data}
				valueRenderer=${(cell, i, j) -> {
					if(i == 0 && j == 0) {
						ADD_COLUMN_BUTTON;
					} else {
						valueToString(cell.value);
					}
				}}
				disablePageClick=${disablePageClick}
				dataRenderer=${(cell, i, j) -> valueToString(cell.value)}
				onContextMenu=${onContextMenu}
				onCellsChanged=${onCellsChanged}
				dataEditor=${dataEditor}
				cellRenderer=${cellRenderer}
				isCellNavigable=${isCellNavigable}
			/>
			<ColumnAdder
				open=${showColumnAdder}
				columns=${[for(column in columns.values()) column]}
				tables=${tableNames}
				customs=${typeNames}
				onCancel=${showColumnAdder = false}
				onConfirm=${v -> {columns.push(v); showColumnAdder = false;}}
			/>
		</div>
	';
	
	static function onContextMenu(event:js.html.Event, cell:Cell<CellValue>, row:Int, col:Int) {
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
			
			row.set(column.name, switch parseValue(column.type, v.value) {
				case Success(v):
					trace(v);
					v;
				case Failure(e):
					trace(e);
					{value: switch row.get(column.name) {case null: null; case v: v.value;}, interim: v.value}
			});
		}
		
		for(change in changes) handle(change);
		if(additions != null) for(addition in additions) handle(addition);
	}
	
	function dataEditor(props:DataEditorProps<CellValue>):react.ReactComponent.ReactFragment {
		return switch columns.get(props.col - 1) {
			case column = {type: SubTable(c)}:
				var subTableColumns = TableModel.fromColumns(c);
				var subTableRows = TableModel.fromRows(switch props.cell.value {
					case Value(SubTable(rows)): rows;
					case _: null;
				});
				
				disablePageClick = true;
				
				function commit(v, e) {
					disablePageClick = false;
					columns.set(props.col - 1, merge(column, type = SubTable(TableModel.toColumns(subTableColumns))));
					props.onCommit(v, e);
				}
				
				@hxx '
					<SubTableEditor
						onCommit=${commit}
						columns=${subTableColumns}
						rows=${subTableRows}
						getCustomType=${getCustomType}
						tableNames=${tableNames}
						typeNames=${typeNames}
						depth=${depth + 1}
					/>
				';
			case _:
				react.ReactMacro.jsx('<input class="data-editor" autoFocus ${...props} onChange=${e -> props.onChange(e.target.value)}/>');
		}
	}
	
	static function cellRenderer(props:CellRendererProps<CellValue>) {
		var style = switch (props.cell.value:CellValue) {
			case Header(v): null;
			case Invalid(v): {backgroundColor: 'rgba(200, 0, 0, 0.3)'}
			case Value(v): null;
			case Empty: null;
		}
		
		return coconut.Ui.hxx('
			<td
				style=${js.lib.Object.assign({}, props.style, style)}
				class=${props.className}
				onContextMenu=${props.onContextMenu}
				onDoubleClick=${props.onDoubleClick}
				onKeyUp=${props.onKeyUp}
				onMouseDown=${props.onMouseDown}
				onMouseOver=${props.onMouseOver}
			>
				${props.children}
			</td>
		');
	}
	
	function parseValue(type:ValueType, value:String):Outcome<Value, Error> {
		return exp.db.util.ValueParser.parseRawString(type, value, getCustomType);
	}
	
	static function valueToString(value:CellValue):String {
		return switch value {
			case Header(v):
				v;
			case Invalid(v):
				v;
			case Empty:
				'';
			case Value(v):
				exp.db.util.ValuePrinter.print(v);
		}
	}
	
	static function isCellNavigable(cell, row, col) {
		return row != 0 && col != 0;
	}
}

@:react.hoc(withStyles(styles))
class SubTableEditor extends View {
	
	@:attr var onCommit:(value:String, event:js.html.KeyboardEvent)->Void;
	@:attr var tableNames:PureList<String>;
	@:attr var typeNames:PureList<String>;
	@:attr var getCustomType:String->Outcome<CustomType, Error>;
	@:attr var columns:ObservableArray<Column>;
	@:attr var rows:ObservableArray<ObservableMap<String, Content>>;
	@:attr var depth:Int;
	
	@:react.injected var classes:{
		modal:String,
		paper:String,
	}
	
	static function styles(theme) return {
		modal: {
			display: 'flex',
			flexDirection: 'column',
			alignItems: 'center',
		},
		paper: {
			overflowY: 'scroll',
		},
	}
	
	
	function render() '
		<Modal class=${classes.modal} open onClose=${commit}>
			<Paper class=${classes.paper} style=${{margin: depth * 24}}>
				<Sheet ${...this}/>
			</Paper>
		</Modal>
	';
	
	function commit() {
		try {
			var str = tink.Json.stringify(TableModel.toRows(rows));
			onCommit(str, null);
		} catch(e:Dynamic) {
			trace(e);
		}
	}
}