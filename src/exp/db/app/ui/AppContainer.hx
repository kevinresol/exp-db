package exp.db.app.ui;

import mui.core.*;
import exp.db.app.data.AppModel;
import exp.db.app.ui.component.*;
import exp.db.app.ui.view.*;
import why.toast.MaterialUiSnackbar;
import electron.renderer.IpcRenderer;

class AppContainer extends View {
	@:attr var app:AppModel;
	
	function render() '
		<>
			<CssBaseline />
			<if ${app.database != null}>
				<DatabaseView database=${app.database} onSave=${save}/>
			<else>
				<Button variant=${Contained} color=${Primary} onClick=${app.newDatabase}>New</Button>
				<Button variant=${Contained} color=${Primary} onClick=${app.openDatabase}>Load</Button>
			</if>
			<MaterialUiSnackbar ref=${v -> why.Toast.inst = v} renderChildren=${options -> options.title}/>
		</>
	';
	
	override function viewDidMount() {
		untilUnmounted({
			IpcRenderer.on('command', function onCommand(event, data) {
				if(data == 'save') {
					if(app.database != null) save();
				}
			});
			IpcRenderer.removeListener.bind('command', onCommand);
		});
		
	}
	
	function save() {
		app.saveDatabase().handle(why.Toast.inst.outcome.bind(_, 'Database Saved', Short));
	}
}

