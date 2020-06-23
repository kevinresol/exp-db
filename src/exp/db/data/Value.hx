package exp.db.data;

enum Value {
	Identifier(v:String);
	Integer(v:Int);
	Text(v:String);
	Ref(id:String);
	Custom(v:CustomValue);
}

typedef CustomValue = {
	final name:String;
	final args:List<Value>;
}