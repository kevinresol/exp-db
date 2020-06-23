package exp.db.app.ui;

import mui.core.*;
import exp.db.app.data.DatabaseModel;
import exp.db.app.ui.component.*;
import exp.db.app.ui.view.*;

class AppContainer extends View {
	@:attr var database:DatabaseModel;
	
	function render() '
		<>
			<CssBaseline />
			<DatabaseView database=${database}/>
		</>
	';
}

