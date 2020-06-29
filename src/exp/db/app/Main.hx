package exp.db.app;

import haxe.macro.Expr.TypeDefKind;
import coconut.react.*;
import exp.db.app.ui.*;
import exp.db.app.data.AppModel;

using haxe.io.Path;
using sys.io.File;
using tink.CoreApi;

class Main {
	static function main() {
		var app = new AppModel();
		var div = js.Browser.document.createDivElement();
		js.Browser.document.body.appendChild(div);
		Renderer.mount(div, '<AppContainer app=${app}/>');
		
	}
}