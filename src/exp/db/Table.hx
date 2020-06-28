package exp.db;

import tink.pure.List;

typedef Table = TableSchema & TableContent;
typedef TableSchema = Name & Schema;
typedef TableContent = Name & Content;

private typedef Name = {
	final name:String;
}
private typedef Schema = {
	final columns:List<Column>;
}
private typedef Content = {
	final rows:List<Row>;
}