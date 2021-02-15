package exp.db.app.ui;

import mui.core.*;
import exp.db.app.data.DatabaseModel;
import exp.db.app.ui.view.*;
import why.toast.MaterialUiSnackbar;


class AppContainer extends View {
	@:attr var onSave:Void->Void;
	@:attr var database:DatabaseModel;
	
	function render() '
		<>
			<CssBaseline />
			<DatabaseView database=${database} onSave=${onSave}/>
			<MaterialUiSnackbar ref=${v -> why.Toast.inst = v} renderChildren=${options -> options.title}/>
		</>
	';
}