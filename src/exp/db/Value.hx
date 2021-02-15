package exp.db;

import tink.pure.Vector;

enum Value {
	Identifier(v:String);
	Integer(v:Int);
	Text(v:String);
	Boolean(v:Bool);
	Enumeration(v:String);
	SubTable(rows:Vector<Row>);
	Ref(id:String);
	Custom(v:CustomValue);
}