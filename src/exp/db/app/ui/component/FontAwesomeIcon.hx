package exp.db.app.ui.component;

import mui.icon.Icon;
import mui.core.styles.Styles.*;

@:react.hoc(withStyles(styles))
class FontAwesomeIcon extends View {
	@:attr var name:String;
	
	@:react.injected var classes:{
		icon:String,
	};
	
	static function styles(theme) return {
		icon: {
			width: 'auto',
			height: 'auto',
			overflow: 'initial',
			fontSize: '1.25rem',
		},
	}
	
	function render() '
		<Icon class="fas fa-$name ${classes.icon}"/>
	';
	
}