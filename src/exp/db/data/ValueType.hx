package exp.db.data;

enum ValueType {
	Identifier;
	Integer;
	Text;
	Ref(table:String);
	Custom(name:String);
}

@:forward
abstract CustomType(CustomTypeObject) from CustomTypeObject to CustomTypeObject {
	inline function new(obj) this = obj;
	@:from public static function fromTypeDefintion(def:haxe.macro.Expr.TypeDefinition):CustomType {
		var fields:Array<Field> = [];
		switch def.kind {
			case TDEnum:
				for(field in def.fields) {
					var args = [];
					switch field.kind {
						case FVar(_): // no args
						case FFun({args: list}):
							for(arg in list) {
								var type:ValueType = switch arg.type {
									case TPath({pack: [], name: 'Int'}): Integer;
									case TPath({pack: [], name: name}): Custom(name);
									case v: throw 'unsupported ComplexType: ' + new haxe.macro.Printer().printComplexType(v);
								}
								args.push({name: arg.name, type: type});
							}
						case FProp(_): throw 'assert';
					}
					fields.push({name: field.name, args: args});
				}
			case _:
				throw 'expected TDEnum';
		}
		return new CustomType({name: def.name, fields: fields});
	}
	@:to public function toTypeDefintion():haxe.macro.Expr.TypeDefinition {
		var name = this.name;
		var def = macro class $name {};
		def.kind = TDEnum;
		for(field in this.fields) {
			def.fields.push({
				name: field.name,
				pos: null,
				kind: if(field.args.length == 0)
						FVar(null, null);
					else
						FFun({
							expr: null,
							ret: null,
							args: [for(arg in field.args) {
								name: arg.name,
								type: switch arg.type {
									case Integer: TPath({pack: [], name: 'Int'});
									case Custom(v): TPath({pack: [], name: v});
									case _: throw "TODO";
								}
							}],
						}),
			});
		}
		return def;
	}
}
typedef CustomTypeObject = {
	final name:String;
	final fields:List<Field>;
}

typedef Field = {
	final name:String;
	final args:List<Argument>;
}

typedef Argument = {
	final name:String;
	final type:ValueType;
}