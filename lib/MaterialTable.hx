package;

import haxe.Constraints;
import haxe.extern.EitherType;
import react.ReactType;
import react.ReactComponent;
import js.lib.Promise;

@:jsRequire('material-table', 'default')
extern class MaterialTable extends ReactComponentOfProps<MaterialTableProps> {}

typedef Data = Dynamic; // TODO: parametrize

typedef MaterialTableProps = {
	?actions: Array<Action>,
	?columns: Array<Column>,
	?components:Components,
	?data:EitherType<Function, Array<Data>>,
	?detailPanel:EitherType<Function, Array<DetailPanel>>,
	?editable:Dynamic,
	?icons:Icons,
	?isLoading:Bool,
	?localization:Localization,
	?onChangePage:Function,
	?onChangeRowsPerPage:Function,
	?onChangeColumnHidden:Function,
	?onColumnDragged:Function,
	?onGroupRemoved:Function,
	?onOrderChange:Function,
	?onRowClick:Function,
	?onSelectionChange:Function,
	?onTreeExpandChange:Function,
	?onSearchChange:Function,
	?options:Options,
	?parentChildData:Function,
	?style:tink.domspec.Style,
	?tableRef:Dynamic,
	?title:ReactSingleFragment,
}

typedef Action = {
	?disabled:Bool,
	?hidden:Bool,
	?icon:ReactType,
	?iconProps:Dynamic,
	?isFreeAction:Bool,
	?onClick:Function,
	?tooltip:String,
}

typedef Column = {
	?cellStyle:tink.domspec.Style,
	?currencySetting:Dynamic,
	?customFilterAndSearch:Function,
	?customSort:Function,
	?defaultFilter:Dynamic,
	?defaultGroupOrder:Int,
	?defaultGroupSort:Sort,
	?defaultSort:Sort,
	?disableClick:Bool,
	?editable:Editable,
	?editComponent:Function,
	?emptyValue:ReactSingleFragment,
	?export:Bool,
	?field:String,
	?filtering:Bool,
	?filterCellStyle:tink.domspec.Style,
	?filterComponent:ReactSingleFragment,
	?filterPlaceholder:String,
	?grouping:Bool,
	?headerStyle:tink.domspec.Style,
	?hidden:Bool,
	?initialEditValue:Dynamic,
	?lookup:Dynamic,
	?readonly:Bool,
	?removable:Bool,
	?render:Data->ReactSingleFragment,
	?searchable:Bool,
	?sorting:Bool,
	?title:String,
	?type:String,
}

typedef Components = {
	?Action:ReactType,
	?Actions:ReactType,
	?Body:ReactType,
	?Cell:ReactType,
	?Container:ReactType,
	?EditField:ReactType,
	?EditRow:ReactType,
	?FilterRow:ReactType,
	?Groupbar:ReactType,
	?Header:ReactType,
	?OverlayLoading:ReactType,
	?Pagination:ReactType,
	?Row:ReactType,
	?Toolbar:ReactType,
}

typedef DetailPanel = {
	?disabled:Bool,
	?icon:ReactSingleFragment,
	?openIcon:ReactSingleFragment,
	?tooltip:String,
	?iconProps:Dynamic,
	?isFreeAction:Bool,
	?render:Function,
}

typedef EditableOptions = {
	?isEditable:Data->Bool,
	?isEditHidden:Data->Bool,
	?isDeletable:Data->Bool,
	?isDeleteHidden:Data->Bool,
	?onRowAddCancelled:Data->Void,
	?onRowUpdateCancelled:Data->Void,
	?onRowAdd:Data->Promise<Any>,
	?onRowUpdate:Data->Promise<Any>,
	?onRowDelete:Data->Promise<Any>,
}

typedef Icons = {
	?Add:ReactType,
	?Check:ReactType,
	?Clear:ReactType,
	?Delete:ReactType,
	?DetailPanel:ReactType,
	?Edit:ReactType,
	?Export:ReactType,
	?Filter:ReactType,
	?FirstPage:ReactType,
	?LastPage:ReactType,
	?NextPage:ReactType,
	?PreviousPage:ReactType,
	?ResetSearch:ReactType,
	?Search:ReactType,
	?SortArrow:ReactType,
	?ThirdStateCheck:ReactType,
	?ViewColumn:ReactType,
}

typedef Localization = {
	?body:{
		?emptyDataSourceMessage:String,
		?addTooltip:String,
		?deleteTooltip:String,
		?editTooltip:String,
		?filterRow:{
			?filterPlaceHolder:String,
			?filterTooltip:String,
		},
		?editRow:{
			?deleteText:String,
			?cancelTooltip:String,
			?saveTooltip:String,
		},
	},
	?grouping:{
		?placeholder:String,
		?groupedBy:String,
	},
	?header:{
		?actions:String,
	},
	?pagination:{
		?labelDisplayedRows:String,
		?labelRowsSelect:String,
		?labelRowsPerPage:String,
		?firstAriaLabel:String,
		?firstTooltip:String,
		?previousAriaLabel:String,
		?previousTooltip:String,
		?nextAriaLabel:String,
		?nextTooltip:String,
		?lastAriaLabel:String,
		?lastTooltip:String,
	},
	?toolbar: {
		?addRemoveColumns:String,
		?nRowsSelected:String,
		?showColumnsTitle:String,
		?showColumnsAriaLabel:String,
		?exportTitle:String,
		?exportAriaLabel:String,
		?exportName:String,
		?searchTooltip:String,
		?searchPlaceholder:String,
	},
}

typedef Options = {
	?actionsCellStyle:tink.domspec.Style,
	?actionsColumnIndex:Int,
	?addRowPosition:AddRowPosition,
	?columnsButton:Bool,
	?cspNonce:String,
	?debounceInterval:Int,
	?detailPanelColumnAlignment:Alignment,
	?detailPanelType:DetailPanelType,
	?doubleHorizontalScroll:Bool,
	?emptyRowsWhenPaging:Bool,
	?exportAllData:Bool,
	?exportButton:Bool,
	?exportDelimiter:String,
	?exportFileName:String,
	?exportCsv:Function,
	?filtering:Bool,
	?filterCellStyle:tink.domspec.Style,
	?fixedColumns:{?left:Int, ?right:Int},
	?grouping:Bool,
	?header:Bool,
	?headerStyle:tink.domspec.Style,
	?loadingType:LoadingType,
	?maxBodyHeight:EitherType<String, Float>,
	?minBodyHeight:EitherType<String, Float>,
	?initialPage:Int,
	?padding:Padding,
	?paging:Bool,
	?pageSize:Int,
	?pageSizeOptions:Array<Int>,
	?paginationType:PaginationType,
	?rowStyle:tink.domspec.Style,
	?showEmptyDataSourceMessage:Bool,
	?showFirstLastPageButtons:Bool,
	?showSelectAllCheckbox:Bool,
	?showTextRowsSelected:Bool,
	?search:Bool,
	?searchAutoFocus:Bool,
	?searchFieldAlignment:String,
	?searchFieldStyle:tink.domspec.Style,
	?searchFieldVariant:String,
	?searchText:String,
	?selection:Bool,
	?selectionProps:Dynamic,
	?sorting:Bool,
	?tableLayout:TableLayout,
	?toolbar:Bool,
	?showTitle:Bool,
	?toolbarButtonAlignment:Alignment,
	?draggable:Bool,
	?thirdSortClick:Bool,
}

enum abstract Editable(String) {
	var Always = 'always';
	var Never = 'never';
	var OnUpdate = 'onUpdate';
	var OnAdd = 'onAdd';
}
enum abstract Sort(String) {
	var Desc = 'desc';
	var Asc = 'asc';
}
enum abstract Alignment(String) {
	var Left = 'left';
	var Right = 'right';
}
enum abstract TableLayout(String) {
	var Auto = 'auto';
	var Fixed = 'fixed';
}
enum abstract AddRowPosition(String) {
	var First = 'first';
	var Last = 'last';
}
enum abstract DetailPanelType(String) {
	var Single = 'single';
	var Multiple = 'multiple';
}
enum abstract LoadingType(String) {
	var Overlay = 'overlay';
	var Linear = 'linear';
}
enum abstract Padding(String) {
	var Default = 'default';
	var Dense = 'dense';
}
enum abstract PaginationType(String) {
	var Normal = 'normal';
	var Stepped = 'stepped';
}