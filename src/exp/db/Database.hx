package exp.db;

import exp.db.Table;
import tink.pure.Vector;

typedef Database = {
	final tables:Vector<Table>;
	final types:Vector<CustomType>;
}

typedef DatabaseSchema = {
	final tables:Vector<TableSchema>;
	final types:Vector<CustomType>;
}

typedef DatabaseContent = {
	final tables:Vector<TableContent>;
}

