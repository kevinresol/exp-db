package exp.db.app.ui.component;

import mui.core.*;
import mui.core.styles.Styles.*;

@:react.hoc(withStyles(styles))
class TopBar extends View {
	
	@:attr var title:String = null;
	@:attr var elevated:Bool = false;
	@:attr var children:Children = null;
	
	@:react.injected var classes:{
		title:String,
	};
	
	static function styles(theme) return {
		title: {
			flexGrow: 1,
		}
	}
	
	// static final ROOT = css('
	// 	display: flex;
	// ');
	
	function render() '
		<AppBar elevation=${elevated ? null : 0} position=${Static} color=${Default}>
			<Toolbar variant=${Dense}>
				<Typography class=${classes.title}>
					${title}
				</Typography>
				${...children}
			</Toolbar>
		</AppBar>
	';
}