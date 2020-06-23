package exp.db.ui;

import mui.core.*;
import mui.core.styles.Styles.*;
import exp.db.data.Database;
import exp.db.ui.component.*;

class AppContainer extends View {
	@:attr var database:Database;
	
	@:state var activeTable:String = 'events';
	@:computed var table:TableData = database.tables.get(activeTable);
	
	static final ROOT = css('
		width: 100vw;
		height: 100vh;
		display: flex;
		flex-direction: column;
	');
	
	static final MAIN = css('
		flex: 1;
		background-color: grey;
	');
	
	// function render() '<><Sheet ${...table}/></>';
	function render() '
		<>
			<CssBaseline />
			<div class=${ROOT}>
				<Paper class=${MAIN}>
					<Sheet ${...table}/>
				</Paper>
				<BottomBar activeTable=${activeTable} tables=${[for(name in database.tables.keys()) name]}/>
			</div>
		</>
	';
}



