package exp.db;

import tink.pure.List;

enum ValueType {
	Identifier;
	Integer;
	Text;
	SubTable(columns:List<Column>);
	Ref(table:String);
	Custom(name:String);
}

