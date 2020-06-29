package exp.db;

import tink.pure.List;

@:using(exp.db.ValueType.ValueTypeTools)
enum ValueType {
	Identifier;
	Integer;
	Text;
	SubTable(columns:List<Column>);
	Ref(table:String);
	Custom(name:String);
}

class ValueTypeTools {
	public static function getDefaultValue(type:ValueType, rowNumber:Int):Value {
		return switch type {
			case Identifier: Identifier('id_$rowNumber');
			case Integer: Integer(0);
			case Text: Text('');
			case SubTable(columns): SubTable([]);
			case Ref(table): null;
			case Custom(name): null;
		}
	}
}