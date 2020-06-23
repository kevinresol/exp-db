package;

import haxe.Constraints;
import haxe.extern.EitherType;
import react.ReactType;
import react.ReactComponent;
import js.lib.Promise;
import js.html.Event;

@:jsRequire('react-datasheet', 'default')
extern class DataSheet<Value> extends ReactComponentOfProps<DataSheetProps<Value>> {}


typedef DataSheetProps<Value> = {
	?data:Array<Array<Cell<Value>>>,
	?valueRenderer:(cell:Cell<Value>, row:Int, col:Int)->ReactSingleFragment,
	?dataRenderer:(cell:Cell<Value>, row:Int, col:Int)->String,
	?overflow:Overflow,
	?onCellsChanged:(changes:Array<Change<Value>>, additions:Array<Addition>)->Void,
	?onContextMenu:(event:Event, cell:Cell<Value>, row:Int, col:Int)->Void,
	?parsePaste:(value:String)->Array<Array<String>>,
	?isCellNavigable:(cell:Cell<Value>, row:Int, col:Int)->Bool,
	
	?sheetRenderer:ReactType,
	?rowRenderer:ReactType,
	?cellRenderer:ReactType,
	?valueViewer:ReactType,
	?dataEditor:ReactType,
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
}

enum abstract Overflow(String) {
	var Wrap = 'wrap';
	var NoWrap = 'nowrap';
	var Clip = 'clip';
}