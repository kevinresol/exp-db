package exp.db;

import tink.pure.*;

typedef Table = {
	final name:String;
	final columns:List<Column>;
	final rows:List<Row>;
}
