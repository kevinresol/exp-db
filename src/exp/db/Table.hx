package exp.db;

import tink.pure.List;

typedef TableSchema = {
	final name:String;
	final columns:List<Column>;
}
typedef TableContent = {
	final name:String;
	final rows:List<Row>;
}
