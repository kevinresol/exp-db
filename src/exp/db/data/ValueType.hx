package exp.db.data;

enum ValueType {
	Identifier;
	Integer;
	Text;
	Ref(table:String);
	Custom(v:CustomType);
}

typedef CustomType = {
	final name:String;
	final fields:List<Field>;
}

typedef Field = {
	final name:String;
	final args:List<Argument>;
}

typedef Argument = {
	final name:String;
	final type:ValueType;
}