package exp.db;

import tink.pure.List;

enum Value {
	Identifier(v:String);
	Integer(v:Int);
	Text(v:String);
	Boolean(v:Bool);
	SubTable(rows:List<Row>);
	Ref(id:String);
	Custom(v:CustomValue);
}