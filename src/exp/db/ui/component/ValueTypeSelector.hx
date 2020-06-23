package exp.db.ui.component;

import mui.core.*;
import exp.db.data.ValueType;

class ValueTypeSelector extends View {
	@:attr var tables:PureList<String>;
	@:controlled var type:ValueType;
	
	static var list:Array<ValueType> = [
		Identifier,
		Integer,
		Text,
		Ref(null),
		Custom(null),
	];
	
	function render() '
		<>
			<FormControl fullWidth margin=${Dense}>
				<InputLabel>Type</InputLabel>
				<Select
					value=${type.getIndex()}
					onChange=${e -> type = list[(cast e.target).value]}
				>
					<for ${v in list}>
						<MenuItem value=${v.getIndex()}>${v.getName()}</MenuItem>
					</for>
				</Select>
			</FormControl>
			<switch ${type}>
				<case ${Ref(v)}>
					<FormControl fullWidth margin=${Dense}>
						<InputLabel>Table</InputLabel>
						<Select
							value=${v == null ? '' : v}
							onChange=${e -> type = Ref((cast e.target).value)}
						>
							<for ${table in tables}>
								<MenuItem value=${table}>${table}</MenuItem>
							</for>
						</Select>
					</FormControl>
				<case ${_}>
			</switch>
		</>
	';
}