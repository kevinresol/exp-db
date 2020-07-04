package exp.db.app.util;

import haxe.macro.Expr;
import tink.pure.List;

using tink.CoreApi;
using Lambda;

class ValueParser {
	
	static final printer = new haxe.macro.Printer();
	
	/**
	 * Parse spreadsheet raw strings
	 * e.g. 123 can be text or integer depending of the value type
	 */
	public static function parseRawString(type:ValueType, v:String, getCustomType:String->Outcome<CustomType, Error>):Outcome<Value, Error> {
		return Error.catchExceptions(() -> switch type {
			case Identifier:
				Identifier(v);
				
			case Integer:
				if(~/\D/.match(v)) 
					throw 'Invalid integer';
				else
					Integer(v.length == 0 ? 0 : Std.parseInt(v));
				
			case Text:
				Text(v);
				
			case Boolean:
				Boolean(v == '0' || v == 'false' || v == '' ? false : true);
				
			case Enumeration(list):
				if(list.exists(i -> i == v)) 
					Enumeration(v);
				else
					throw 'Invalid Value "$v". Expected ' + list.toArray().join(', ');
				
			case SubTable(columns):
				// TODO: check value against table schema
				exp.db.Value.SubTable(tink.Json.parse(v));
				
			case Ref(table):
				 // TODO: verify the id actually exists in the target table
				Ref(v);
				
			case Custom(name):
				parseHaxeString(type, v, getCustomType).sure();
				
		});
	}
	
	/**
	 * Parse Haxe syntax strings
	 * e.g. 123 is integer, "123" is string
	 */
	public static function parseHaxeString(type:ValueType, v:String, getCustomType:String->Outcome<CustomType, Error>):Outcome<Value, Error> {
		return Error.catchExceptions(() -> {
			var expr = new haxeparser.HaxeParser(byte.ByteData.ofString(v), '').expr();
			parseExpr(type, expr, getCustomType).sure();
		});
	}
	
	public static function parseExpr(type:ValueType, expr:Expr, getCustomType:String->Outcome<CustomType, Error>):Outcome<Value, Error> {
		return Error.catchExceptions(() -> switch [type, expr.expr] {
			case [Identifier, EConst(CIdent(v))]: Identifier(v);
			case [Integer, EConst(CInt(v))]: Integer(Std.parseInt(v));
			case [Text, EConst(CString(v, _))]: Text(v);
			case [Boolean, EConst(CIdent(v = 'true' | 'false'))]: Boolean(v == 'true');
			case [Custom(name), _]: Custom(parseCustom(getCustomType(name).sure(), expr, getCustomType).sure());
			case _: throw 'Unsupported type or type mismatch (${type.getName()}, ${printer.printExpr(expr)})';
		});
	}
	 
	public static function parseCustom(type:CustomType, e:Expr, getCustomType:String->Outcome<CustomType, Error>):Outcome<CustomValue, Error> {
		
		function check(ctor, numArgs, f:CustomType.Field->CustomValue) {
			switch type.fields.first(f -> f.name == ctor) {
				case None:
					throw 'Field "$ctor" is not part of ${type.name}';
				case Some(field) if(field.args.length != numArgs):
					throw 'Expected ${field.args.length} arguments but got ${numArgs}';
				case Some(field):
					return f(field);
			}
		}
		
		return Error.catchExceptions(() -> switch e {
			case macro $i{ctor}($a{args}):
				check(ctor, args.length, field -> {
					var fargs = field.args.toArray();
					{
						name: ctor,
						args: [for(i in 0...fargs.length)
							parseExpr(fargs[i].type, args[i], getCustomType).sure()
						]
					}
				});
				
			case macro $i{ctor}:
				check(ctor, 0, field -> {name: ctor, args: null});
				
			case _: throw 'unsupported syntax';
		});
	}
}