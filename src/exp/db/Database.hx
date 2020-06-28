package exp.db;

import exp.db.Table;
import tink.pure.List;

typedef Database = {
	final tables:List<Table>;
	final types:List<CustomType>;
}

typedef DatabaseSchema = {
	final tables:List<TableSchema>;
	final types:List<CustomType>;
}

typedef DatabaseContent = {
	final tables:List<TableContent>;
}

