package exp.db.app;

import coconut.react.*;
import exp.db.app.ui.*;
import exp.db.app.data.CustomTypeModel;
import exp.db.app.data.DatabaseModel;
import exp.db.Value;
import tink.state.*;

class Main {
	static function main() {
		var database = new DatabaseModel();
		database.addTable('events');
		
		database.customTypes.push(new CustomTypeModel({
			name: 'Event',
			fields: new ObservableArray([
				new FieldModel({
					name: 'Combined',
					args: new ObservableArray([
						new ArgumentModel({
							name: 'e1',
							type: Custom('Event'),
						}),
						new ArgumentModel({
							name: 'e2',
							type: Custom('Event'),
						}),
					]),
				}),
			]),
		}));
		
		var table = database.tables.get('events');
		table.columns.push({name: 'id', type: Identifier});
		table.columns.push({name: 'title', type: Integer});
		table.columns.push({name: 'description', type: Text});
		for(i in 0...25) 
			table.rows.push(new ObservableMap<String, Content>(['id' => Identifier('id_$i'),'title' => Integer(i), 'description' => Text('My Game')]));
		
		database.addTable('foo');
		var table = database.tables.get('foo');
		table.columns.push({name: 'title2', type: Integer});
		table.columns.push({name: 'description2', type: Text});
		table.columns.push({name: 'foo', type: Text});
		for(i in 0...50) 
			table.rows.push(new ObservableMap<String, Content>(['title2' => Integer(i+10), 'description2' => Text('My Game'), 'foo' => Text('jj$i')]));
		
		
		
		var div = js.Browser.document.createDivElement();
		js.Browser.document.body.appendChild(div);
		Renderer.mount(div, '<AppContainer database=${database}/>');
	}
}