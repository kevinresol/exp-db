package exp.db.ui;

import mui.core.*;
import exp.db.data.Database;
import exp.db.ui.component.*;
import exp.db.ui.view.*;

class AppContainer extends View {
	@:attr var database:Database;
	
	function render() '
		<>
			<CssBaseline />
			<DatabaseView database=${database}/>
		</>
	';
}

