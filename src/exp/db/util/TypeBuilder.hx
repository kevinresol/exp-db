package exp.db.util;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.Json;
import tink.pure.List;
import exp.db.Database;
import exp.db.Table;

using tink.CoreApi;
using tink.MacroApi;
using sys.io.File;

@:allow(exp.db.util)
class TypeBuilder {
	public static function build(file:String, pack:Array<String>) {
		var path = Context.resolvePath(file);
		var rep = Json.parse(path.getContent());
		var schema = parseDatabaseRepresentation(rep);
		new TypeBuilder(schema, pack).buildDatabase();
	}
	
	static function parseDatabaseRepresentation(v:DatabaseRepresentation):DatabaseSchema {
		return {
			tables: List.fromArray([for(table in v.tables) {
				name: table.name,
				columns: List.fromArray([for(column in table.columns) {
					name: column.name,
					type: column.type.toValueType(),
				}]),
			}]),
			types: List.fromArray([for(type in v.types) new CustomType({
				name: type.name,
				fields: List.fromArray([for(field in type.fields) {
					name: field.name,
					args: List.fromArray([for(arg in field.args) {
						name: arg.name,
						type: arg.type.toValueType(),
					}]),
				}]),
			})]),
		}
	}
	
	static function parseColumnRepresentation(column:ColumnRepresentation):Column {
		return {
			name: column.name,
			type: column.type.toValueType(),
		}
	}
	
	
	
	final schema:DatabaseSchema;
	final pack:Array<String>;
	final tablePack:Array<String>;
	final typePack:Array<String>;
	
	function new(schema, pack) {
		this.schema = schema;
		this.pack = pack;
		this.tablePack = pack.concat(['tables']);
		this.typePack = pack.concat(['types']);
	}
	
	function buildDatabase() {
		var pos = Context.currentPos();
		
		
		var init = [];
		var underlying = TPath({pack: pack, name: 'Database', sub: 'DatabaseObject'});
		var db = macro class Database {
			public static function parse(v:String):Outcome<Database, Error> {
				return Error.catchExceptions(() -> {
					var content:exp.db.Database.DatabaseContent = tink.Json.parse(v);
					${EObjectDecl(init).at(pos)}
				});
			}
		}
		db.pack = pack;
		db.kind = TDAbstract(underlying, [underlying], [underlying]);
		db.meta = [{name: ':forward', pos: pos}];
		
		var dbo = macro class DatabaseObject {}
		dbo.pack = pack;
		dbo.kind = TDStructure;
		
		
		for(table in schema.tables) {
			var idName = table.columns.first(c -> c.type == Identifier).map(c -> c.name);
			var fieldName = uncapitalize(table.name);
			var typeName = capitalize(table.name);
			var ct = TPath({pack: tablePack, name: 'Tables', sub: typeName});
			
			// add field to database object
			dbo.fields.push({
				name: fieldName,
				kind: FVar(idName != None ? macro:Map<String, $ct> : macro:Array<$ct>, null),
				pos: pos,
			});
			
			// add init expr for parsing
			init.push({
				field: fieldName,
				expr: macro {
					var table = content.tables.first(v -> v.name == $v{table.name}).force();
					${tableParser(table.columns, macro table.rows)};
				}
			});
		}
		
		// define custom types before tables 
		// see: https://github.com/HaxeFoundation/haxe/issues/9657
		var defs = [];
		for(v in schema.types) {
			defs.push(buildCustomType(v));
			defs.push(buildCustomParser(v));
		}
		Context.defineModule(typePack.concat(['Types']).join('.'), defs);
		
		var defs = [];
		for(v in schema.tables) {
			defs.push(buildTable(v));
			defs.push(buildTableParser(v));
		}
		Context.defineModule(tablePack.concat(['Tables']).join('.'), defs);
		
		Context.defineModule(pack.concat(['Database']).join('.'), [db, dbo], [], [{pack: ['tink'], name: 'CoreApi'}]);
	}
	
	function buildTable(table:TableSchema):TypeDefinition {
		var pos = Context.currentPos();
		var typeName = capitalize(table.name);
		
		// define table type
		var def = macro class $typeName {}
		def.pack = tablePack;
		def.kind = TDStructure;
		
		for(column in table.columns) {
			def.fields.push({
				name: column.name,
				kind: FVar(valueTypeToComplexType(column.type, typePack), null),
				pos: pos,
			});
		}
		
		return def;
	}
	
	function buildTableParser(table:TableSchema):TypeDefinition {
		var pos = Context.currentPos();
		var parserName = capitalize(table.name) + 'Parser';
		var tableCt = TPath({pack: tablePack, name: 'Tables', sub: capitalize(table.name)});
		
		var def = macro class $parserName {
			public static function parse(rows:tink.pure.List<exp.db.Row>) {
				return ${tableParser(table.columns, macro rows)};
			}
		}
		
		return def;
	}
	
	function buildCustomType(type:CustomType):TypeDefinition {
		return type.toTypeDefintionWithPack(typePack, 'Types');
	}
	
	function buildCustomParser(type:CustomType):TypeDefinition {
		var pos = Context.currentPos();
		var parserName = type.name + 'Parser';
		var typeCt = TPath({pack: typePack, name: 'Types', sub: type.name});
		
		var def = macro class $parserName {
			public static function parse(value:exp.db.CustomValue):$typeCt {
				return ${customValueParser(type, macro value)}
			}
		}
		
		return def;
	}
	
	function getCustomType(name:String):CustomType {
		return schema.types.first(v -> v.name == name).force();
	}
	
	function tableParser(columns:List<Column>, rows:Expr):Expr {
		return macro {
			var rows = $rows;
			var list = [for(row in rows) ${rowParser(columns, macro row)}];
			${switch columns.first(c -> c.type == Identifier).map(c -> c.name) {
				case Some(id): macro [for(v in list) v.$id => v];
				case None: macro list;
			}}
		}
	}
	
	function rowParser(columns:List<Column>, row:Expr):Expr {
		var pos = Context.currentPos();
		return EObjectDecl([for(column in columns) {
			field: column.name,
			expr: valueParser(column.type, macro $row.get($v{column.name})),
		}]).at(pos);
	}
	
	function valueParser(type:ValueType, value:Expr):Expr {
		return switch type {
			case Identifier:
				macro exp.db.util.ValueParser.parseIdentifier($value);
			case Integer:
				macro exp.db.util.ValueParser.parseInteger($value);
			case Text:
				macro exp.db.util.ValueParser.parseText($value);
			case SubTable(sub):
				(macro exp.db.util.ValueParser.parseSubTable($value, rows -> ${tableParser(sub, macro rows)})).log();
			case Ref(_):
				macro throw "TODO";
			case Custom(name):
				var parser = macro $p{typePack.concat(['Types', name + 'Parser'])};
				macro exp.db.util.ValueParser.parseCustom($value, $parser.parse);
			
		}
	}
	
	function customValueParser(type:CustomType, value:Expr):Expr {
		var pos = Context.currentPos();
		var prefix = macro $p{typePack.concat(['Types', type.name])}
		return macro {
			var value = $value;
			trace(Std.string(value));
			${ESwitch(macro value.name, [
				for(field in type.fields) {
					var name = field.name;
					if(field.args.length == 0) {
						values: [macro $v{name}],
						expr: macro $prefix.$name
					} else {
						values: [macro $v{name}],
						expr: {
							var arr = field.args.toArray();
							var args = [for(i in 0...arr.length) valueParser(arr[i].type, macro arr[$v{i}])];
							macro {
								var arr = value.args.toArray();
								$prefix.$name($a{args});
							}
						}
					}
				}
			], macro throw 'unknown custom value "' + value.name + '"').at(pos)};
		};
	}
	
	
	static function valueTypeToComplexType(type:ValueType, pack:Array<String>):ComplexType {
		return switch type {
			case Identifier:
				macro:String;
			case Integer:
				macro:Int;
			case Text:
				macro:String;
			case SubTable(columns):
				var ct = columnsToComplexType(columns, pack);
				switch columns.first(c -> c.type == Identifier) {
					case Some(_): macro:Map<String, $ct>;
					case None: macro:Array<$ct>;
				}
			case Ref(table):
				macro:Dynamic;
			case Custom(name):
				TPath({pack: pack, name: 'Types', sub: name});
		}
	}
	
	static function columnsToComplexType(columns:List<Column>, pack:Array<String>):ComplexType {
		var fields = [];
		var ret = TAnonymous(fields);
		for(column in columns) {
			fields.push({
				name: column.name,
				kind: FVar(valueTypeToComplexType(column.type, pack), null),
				pos: Context.currentPos(),
			});
		}
		return ret;
	}
	
	static function uncapitalize(v:String):String {
		return v.charAt(0).toLowerCase() + v.substr(1);
	}
	
	static function capitalize(v:String):String {
		return v.charAt(0).toUpperCase() + v.substr(1);
	}
}

private typedef DatabaseRepresentation = {
	tables:Array<{
		name:String,
		columns:Array<ColumnRepresentation>,
	}>,
	types:Array<{
		name:String,
		fields:Array<{
			name:String,
			args:Array<{
				name:String,
				type:TypeRepresentation,
			}>,
		}>,
	}>,
}

private typedef ColumnRepresentation = {
	name:String,
	type:TypeRepresentation,
}

private abstract TypeRepresentation(Dynamic) {
	// manually parse tink_json representation
	// TODO: may be we should find a way to somehow use tink_json in macro
	public function toValueType():ValueType {
		return
			if(this == 'Identifier') Identifier;
			else if(this == 'Integer') Integer;
			else if(this == 'Text') Text;
			else if(this.Custom != null) Custom(this.Custom.name);
			else if(this.SubTable != null) SubTable(List.fromArray((this.SubTable.columns:Array<ColumnRepresentation>).map(TypeBuilder.parseColumnRepresentation)));
			else throw 'TODO $this';
	}
}