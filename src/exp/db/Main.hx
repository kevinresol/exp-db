package exp.db;

import coconut.react.*;
import exp.db.ui.*;
import exp.db.data.*;
import exp.db.data.Value;
import tink.state.*;

class Main {
	static function main() {
		var database = new Database();
		database.addTable('events');
		var table = database.tables.get('events');
		table.columns.push({name: 'title', type: Integer});
		table.columns.push({name: 'description', type: Text});
		for(i in 0...25) 
			table.rows.push(new ObservableMap(['title' => Integer(i), 'description' => Text('My Game')]));
		
		database.addTable('foo');
		var table = database.tables.get('foo');
		table.columns.push({name: 'title2', type: Integer});
		table.columns.push({name: 'description2', type: Text});
		table.columns.push({name: 'foo', type: Text});
		for(i in 0...50) 
			table.rows.push(new ObservableMap(['title2' => Integer(i+10), 'description2' => Text('My Game'), 'foo' => Text('jj$i')]));
		
		
		
		var div = js.Browser.document.createDivElement();
		js.Browser.document.body.appendChild(div);
		Renderer.mount(div, '<AppContainer database=${database}/>');
	}
}