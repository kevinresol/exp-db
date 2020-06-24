package exp.db;

import tink.pure.List;

enum Value {
	Identifier(v:String);
	Integer(v:Int);
	Text(v:String);
	SubTable(rows:List<Row>);
	Ref(id:String);
	Custom(v:CustomValue);
}

typedef CustomValue = {
	final name:String;
	final args:List<Value>;
}