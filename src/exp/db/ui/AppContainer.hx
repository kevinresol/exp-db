package exp.db.ui;

import mui.core.*;
import exp.db.data.DatabaseModel;
import exp.db.ui.component.*;
import exp.db.ui.view.*;

class AppContainer extends View {
	@:attr var database:DatabaseModel;
	
	function render() '
		<>
			<CssBaseline />
			<!--
			<DatabaseView database=${database}/>
			-->
			<for ${custom in database.customTypes.values()}>
				<CustomTypeEditor tables=${database.tableNames} />
			</for>
		</>
	';
}

