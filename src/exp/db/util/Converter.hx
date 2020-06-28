package exp.db.util;

import haxe.macro.Expr;

class Converter {
	public function columnsToComplexType(columns:List<Column>, getCustomType:String->ComplexType):ComplexType {
		var ret = TAnonymous(fields);
		for(column in columns) {
			fields.push({
				name: column.name,
				kind: FVar(valueTypeToComplexType(column.type), null),
				pos: null,
			});
		}
		return ret;
	}
	
	public function valueTypeToComplexType(type:ValueType, getCustomType:String->ComplexType):ComplexType {
		return switch type {
			case Identifier:
				macro:Dynamic;
			case Integer:
				macro:Int;
			case Text:
				macro:String;
			case SubTable(columns):
				columnsToComplexType(columns, getCustomType);
			case Ref(table):
				macro:Dynamic;
			case Custom(name):
				macro:Dynamic;
		}
	}
	
	public function customTypeToComplexType(type:ValueType, getCustomType:String->ComplexType):ComplexType {
		return switch type {
			case Identifier:
				macro:Dynamic;
			case Integer:
				macro:Int;
			case Text:
				macro:String;
			case SubTable(columns):
				columnsToComplexType(columns, getCustomType);
			case Ref(table):
				macro:Dynamic;
			case Custom(name):
				macro:Dynamic;
		}
	}
}