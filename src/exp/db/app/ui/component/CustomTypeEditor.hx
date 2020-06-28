package exp.db.app.ui.component;

import mui.core.*;
import mui.icon.Add as AddIcon;
import mui.core.styles.Styles.*;
import exp.db.ValueType;

class CustomTypeEditor extends View {
	
	@:attr var tables:PureList<String>;
	@:attr var onSubmit:PureList<CustomType>->Void = null;
	@:attr var initialValue:PureList<CustomType>;
	@:state var value:String = '';
	
	@:skipCheck @:computed var typedefs:Outcome<Array<haxe.macro.Expr.TypeDefinition>, Error> = {
		Error.catchExceptions(() -> {
			var e = new haxeparser.HaxeParser(byte.ByteData.ofString(value), '').parse();
			e.decls.map(v -> haxeparser.DefinitionConverter.convertTypeDef([], v.decl)).filter(v -> v.kind == TDEnum);
		});
	}
	
	@:skipCheck @:computed var types:Outcome<Array<CustomType>, Error> = typedefs.map(list -> [for(def in list) (def:CustomType)]);
	
	static final printer = new haxe.macro.Printer();
	
	static final ROOT = css('
		padding: 12px;
		margin: 12px;
	');
	
	static final INPUT = css('
		& textarea {
			font-family: monospace;
		}
	');
	
	function render() '
		<>
		<TopBar>
			<IconButton disabled=${!types.isSuccess()} onClick=${_ -> onSubmit(types.sure())}>
				<AddIcon/>
			</IconButton>
		</TopBar>
		<Grid container spacing=${Spacing_1}>
			<Grid item xs={6}>
				<Paper class=${ROOT}>
					<TextField
						class=${INPUT}
						autoFocus
						label="Syntax"
						multiline
						value=${value}
						onChange=${e -> {value = (cast e.target).value; coconut.react.Renderer.updateAll();}}
						fullWidth
					/>
					
				</Paper>
			</Grid>
			<Grid item xs={6}>
				<Paper class=${ROOT}>
					<switch ${types}>
						<case ${Success(list)}>
							<for ${type in list}>
								<pre>${printer.printTypeDefinition(type)}</pre>
							</for>
						<case ${Failure(e)}>
					</switch>
				</Paper>
			</Grid>
		</Grid>
		</>
	';
	
	override function viewDidMount() {
		value = [for(type in initialValue) printer.printTypeDefinition(type)].join('\n');
	}
}