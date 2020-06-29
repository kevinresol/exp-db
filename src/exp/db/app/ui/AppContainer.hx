package exp.db.app.ui;

import mui.core.*;
import exp.db.app.data.AppModel;
import exp.db.app.ui.component.*;
import exp.db.app.ui.view.*;

class AppContainer extends View {
	@:attr var app:AppModel;
	
	function render() '
		<>
			<CssBaseline />
			<if ${app.database != null}>
				<DatabaseView database=${app.database}/>
			<else>
				<Button variant=${Contained} color=${Primary} onClick=${app.newDatabase}>New</Button>
				<Button variant=${Contained} color=${Primary} onClick=${app.openDatabase}>Load</Button>
			</if>
		</>
	';
}

