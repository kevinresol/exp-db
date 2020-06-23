package exp.db.app.ui.component;

import mui.core.*;
import mui.core.styles.Styles.*;
import mui.icon.Add as AddIcon;

@:react.hoc(withStyles(styles))
class TopBar extends View {
	
	@:attr var onAdd:Void->Void = null;
	@:attr var elevated:Bool = false;
	
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
					
				</Typography>
				<IconButton >
					<AddIcon onClick=${onAdd}/>
				</IconButton>
			</Toolbar>
		</AppBar>
	';
}