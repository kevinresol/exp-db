package exp.db.ui.component;

import mui.core.*;
import mui.core.styles.Styles.*;
import mui.icon.Add as AddIcon;

@:react.hoc(withStyles(styles))
class BottomBar extends View {
	@:controlled var activeTable:String;
	@:controlled var showCustomTypeEditor:Bool;
	@:attr var tables:PureList<String>;
	
	@:react.injected var classes:{
		bar:String,
		tabs:String,
		tab:String,
	};
	
	static function styles(theme) return {
		bar: {
			flexDirection: 'row',
		},
		tabs: {
			flexGrow: 1,
		},
		tab: {
			minWidth: 50,
		},
	}
	
	function render() '
		<AppBar class=${classes.bar} position=${Static} color=${Default}>
			<Tabs
				class=${classes.tabs}
				value=${activeTable}
				onChange=${(e, value) -> {showCustomTypeEditor = false; activeTable = value;}}
				indicatorColor=${Primary}
				textColor=${Primary}
				variant=${Scrollable}
				scrollButtons=${Auto}
			>
				<for ${table in tables}>
					<Tab class=${classes.tab} label=${table} value=${table}/>
				</for>
			</Tabs>
			<Toolbar variant=${Dense}>
				<IconButton>
					<AddIcon onClick=${_ -> {showCustomTypeEditor = true; activeTable = null;}}/>
				</IconButton>
			</Toolbar>
		</AppBar>
	';
}