package exp.db.ui.component;

import mui.core.*;
import mui.core.styles.Styles.*;

@:react.hoc(withStyles(styles))
class BottomBar extends View {
	@:controlled var activeTable:String;
	@:attr var tables:PureList<String>;
	
	@:react.injected var classes:{
		tab:String,
	};
	
	static function styles(theme) return {
		tab: {
			minWidth: 50,
		},
	}
	
	// static final ROOT = css('
	// 	display: flex;
	// ');
	
	function render() '
		<AppBar position=${Static} color=${Default}>
			<Tabs
				value=${activeTable}
				onChange=${(e, value) -> {trace(value); activeTable = value;}}
				indicatorColor=${Primary}
				textColor=${Primary}
				variant=${Scrollable}
				scrollButtons=${Auto}
			>
				<for ${table in tables}>
					<Tab class=${classes.tab} label=${table} value=${table}/>
				</for>
			</Tabs>
		</AppBar>
	';
}