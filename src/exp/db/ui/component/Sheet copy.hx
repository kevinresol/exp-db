package exp.db.ui.component;

import exp.db.data.Database;
import exp.db.data.Value;
import mui.core.*;
import mui.core.styles.Styles.*;

	
@:react.hoc(withStyles(styles))
class Sheet extends View {
	@:attr var columns:ObservableArray<Column>;
	@:attr var rows:ObservableArray<ObservableMap<String, Value>>;
	
	@:react.injected var classes:{
		table:String,
	};
	
	static function styles(theme) return {
		table: {
			
		},
	}
	
	function render() '
		<Table class=${classes.table} stickyHeader size=${Small}>
			<TableHead>
				<TableRow>
					<for ${column in columns.values()}>
						<TableCell>${column.name}</TableCell>
					</for>
				</TableRow>
			</TableHead>
			<TableBody>
				<for ${row in rows.values()}>
					<TableRow>
						<for ${column in columns.values()}>
							<let value=${row.get(column.name)}>
								<TableCell>
									<TextField size=${Small} margin=${None} value=${Std.string(value)} />
								</TableCell>
							</let>
						</for>
					</TableRow>
				</for>
			</TableBody>
		</Table>
	';
}