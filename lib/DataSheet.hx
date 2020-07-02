package;

import haxe.DynamicAccess;
import haxe.Constraints;
import haxe.extern.EitherType;
import react.ReactType;
import react.ReactComponent;
import js.lib.Promise;
import js.html.Event;
import js.html.MouseEvent;
import js.html.KeyboardEvent;

@:jsRequire('react-datasheet', 'default')
extern class DataSheet<Value> extends ReactComponentOfProps<DataSheetProps<Value>> {}

typedef Data<Value> = Array<Array<Cell<Value>>>;
typedef DataSheetProps<Value> = {
	?data:Data<Value>,
	?valueRenderer:(cell:Cell<Value>, row:Int, col:Int)->ReactSingleFragment,
	?dataRenderer:(cell:Cell<Value>, row:Int, col:Int)->String,
	?overflow:Overflow,
	?onCellsChanged:(changes:Array<Change<Value>>, additions:Array<Addition>)->Void,
	?onContextMenu:(event:MouseEvent, cell:Cell<Value>, row:Int, col:Int)->Void,
	?parsePaste:(value:String)->Array<Array<String>>,
	?isCellNavigable:(cell:Cell<Value>, row:Int, col:Int)->Bool,
	?disablePageClick:Bool,
	
	?attributesRenderer:Cell<Value>->DynamicAccess<String>,
	?sheetRenderer:ReactTypeOf<SheetRendererProps<Value>>,
	?rowRenderer:ReactTypeOf<RowRendererProps<Value>>,
	?cellRenderer:ReactTypeOf<CellRendererProps<Value>>,
	?valueViewer:ReactTypeOf<ValueViewerProps<Value>>,
	?dataEditor:ReactTypeOf<DataEditorProps<Value>>,
	?selected:Selection,
	?onSelect:Selection->Void,
}

typedef Selection = {
	start:Address,
	end:Address,
}

typedef Address = {
	i:Int,
	j:Int,
}

typedef Addition = {
	row:Int,
	col:Int,
	value:String,
}

typedef Change<Value> = {
	> Addition,
	cell:Cell<Value>,
}

typedef Cell<Value> = {
	value:Value,
	?readOnly:Bool,
	?disableEvents:Bool,
}

enum abstract Overflow(String) {
	var Wrap = 'wrap';
	var NoWrap = 'nowrap';
	var Clip = 'clip';
}

typedef SheetRendererProps<Value> = {
	data:Data<Value>,
	className:String,
	children:ReactSingleFragment,
}
typedef RowRendererProps<Value> = {
	row:Int,
	cells:Array<Cell<Value>>,
	children:ReactSingleFragment,
}
typedef CellRendererProps<Value> = {
	row:Int,
	col:Int,
	cell:Cell<Value>,
	className:String,
	style:tink.domspec.Style,
	selected:Bool,
	editing:Bool,
	updated:Bool,
	attributesRenderer:Cell<Value>->DynamicAccess<String>,
	onMouseDown:MouseEvent->Void,
	onMouseOver:MouseEvent->Void,
	onKeyUp:KeyboardEvent->Void,
	onDoubleClick:MouseEvent->Void,
	onContextMenu:MouseEvent->Void,
	children:ReactSingleFragment,
}
typedef ValueViewerProps<Value> = {
	cell:Cell<Value>,
	row:Int,
	col:Int,
	value:ReactSingleFragment,
}

typedef DataEditorProps<Value> = {
	> ValueViewerProps<Value>,
	onChange:String->Void,
	onCommit:(value:String, event:KeyboardEvent)->Void, // FIXME: second arg should be optional: https://github.com/MVCoconut/coconut.ui/issues/68
	onKeyDown:KeyboardEvent->Void,
	onRevert:Void->Void,
}