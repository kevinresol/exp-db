package exp.db.ui.component;

import mui.core.*;
import mui.core.styles.Styles.*;
import exp.db.data.CustomTypeModel;
import exp.db.data.ValueType;

class CustomTypeEditor extends View {
	
	@:attr var tables:PureList<String>;
	@:attr var onSubmit:PureList<CustomType>->Void = null;
	@:state var value:String = '';
	
	@:skipCheck @:computed var typedefs:Array<haxe.macro.Expr.TypeDefinition> = {
		try {
			var e = new haxeparser.HaxeParser(byte.ByteData.ofString(value), '').parse();
			e.decls.map(v -> haxeparser.DefinitionConverter.convertTypeDef([], v.decl)).filter(v -> v.kind == TDEnum);
		} catch(e:Dynamic) {
			trace(e);
			[];
		}
	}
	
	@:skipCheck @:computed var types:Array<CustomType> = [for(def in typedefs) (def:CustomType)];
	
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
					<for ${type in types}>
						<pre>${printer.printTypeDefinition(type)}</pre>
					</for>
				</Paper>
			</Grid>
		</Grid>
		
	';
}