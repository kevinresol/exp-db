package exp.db.app.ui.component;

import mui.core.*;
import exp.db.ValueType;

class ValueTypeSelector extends View {
	@:attr var tables:PureList<String>;
	@:attr var customs:PureList<String>;
	@:controlled var type:ValueType;
	
	static var list:Array<ValueType> = [
		Identifier,
		Integer,
		Text,
		Boolean,
		Enumeration(null),
		SubTable(null),
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
				<case ${Enumeration(list)}>
					<TextField
						autoFocus
						fullWidth
						margin=${Dense}
						label="List"
						value=${list.toArray().join(',')}
						onChange=${e -> {
							var str:String = (cast e.target).value;
							type = Enumeration(str.split(',').map(StringTools.trim));
							Renderer.updateAll();
						}}
					/>
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
				<case ${Custom(v)}>
					<FormControl fullWidth margin=${Dense}>
						<InputLabel>Type</InputLabel>
						<Select
							value=${v == null ? '' : v}
							onChange=${e -> type = Custom((cast e.target).value)}
						>
							<for ${type in customs}>
								<MenuItem value=${type}>${type}</MenuItem>
							</for>
						</Select>
					</FormControl>
				<case ${_}>
			</switch>
		</>
	';
}