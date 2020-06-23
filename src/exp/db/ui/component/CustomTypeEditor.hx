package exp.db.ui.component;

import mui.core.*;
import mui.core.styles.Styles.*;
import exp.db.data.CustomTypeModel;
import exp.db.data.ValueType;

class CustomTypeEditor extends View {
	
	@:attr var tables:PureList<String>;
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
	
	function render() '
		<Paper class=${ROOT}>
			<TextField
				autoFocus
				label="Syntax"
				multiline
				value=${value}
				onChange=${e -> {value = (cast e.target).value; coconut.react.Renderer.updateAll();}}
				fullWidth
			/>
			<pre>${...[for(type in types) printer.printTypeDefinition(type)]}</pre>
		</Paper>
	';
}