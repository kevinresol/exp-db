package exp.db;

import js.Node;
import js.Node.__dirname;
import electron.main.App;
import electron.main.BrowserWindow;

class Electron {

	static function main() {

		electron.main.App.on( ready, function(e) {

			var win = new BrowserWindow( {
				width: 1440, height: 900,
				webPreferences: {
					nodeIntegration: true
				}
			} );
			win.on( closed, function() {
				win = null;
			});
			win.loadFile( 'app.html' );
			//win.webContents.openDevTools();

			// var tray = new electron.main.Tray( '${__dirname}/icon-192.png' );
		});

		electron.main.App.on( window_all_closed, function(e) {
			if( Node.process.platform != 'darwin' ) electron.main.App.quit();
		});
	}

}