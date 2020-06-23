package exp.db;

enum ValueType {
	Identifier;
	Integer;
	Text;
	// SubTable;
	Ref(table:String);
	Custom(name:String);
}

