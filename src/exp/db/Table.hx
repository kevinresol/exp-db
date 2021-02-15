package exp.db;

import tink.pure.Vector;

typedef Table = TableSchema & TableContent;
typedef TableSchema = Name & Schema;
typedef TableContent = Name & Content;

private typedef Name = {
	final name:String;
}
private typedef Schema = {
	final columns:Vector<Column>;
}
private typedef Content = {
	final rows:Vector<Row>;
}