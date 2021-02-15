package exp.db.util;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.Json;
import tink.pure.Vector;
import exp.db.Database;
import exp.db.Table;

using tink.CoreApi;
using tink.MacroApi;
using sys.io.File;

@:allow(exp.db.util)
class TypeBuilder {
	public static function build(file:String, pack:String) {
		var path = Context.resolvePath(file);
		var rep = Json.parse(path.getContent());
		var schema = parseDatabaseRepresentation(rep);
		new TypeBuilder(schema, pack.split('.')).buildDatabase();
	}
	
	static function parseDatabaseRepresentation(v:DatabaseRepresentation):DatabaseSchema {
		return {
			tables: [for(table in v.tables) ({
				name: table.name,
				columns: [for(column in table.columns) ({
					name: column.name,
					type: column.type.toValueType(),
				}:Column)],
			}:TableSchema)],
			types: [for(type in v.types) new CustomType({
				name: type.name,
				fields: [for(field in type.fields) ({
					name: field.name,
					args: [for(arg in field.args) ({
						name: arg.name,
						type: arg.type.toValueType(),
					}:exp.db.CustomType.Argument)],
				}:exp.db.CustomType.Field)],
			})],
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
					var db:tink.core.Ref<Database> = (null:Database);
					db.value = ${EObjectDecl(init).at(pos)};
					db.value;
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
			var idName = switch table.columns.find(c -> c.type == Identifier) {
				case null: None;
				case c: Some(c.name);
			}
			var fieldName = uncapitalize(table.name);
			var ct = makeTableCt(table.name);
			
			// add field to database object
			dbo.fields.push({
				access: [AFinal],
				name: fieldName,
				kind: FVar(idName != None ? macro:haxe.ds.ReadOnlyMap<String, $ct> : macro:haxe.ds.ReadOnlyArray<$ct>, null),
				pos: pos,
			});
			
			// add init expr for parsing
			init.push({
				field: fieldName,
				expr: macro {
					var table = content.tables.find(v -> v.name == $v{table.name});
					${tableParser(table.columns, macro table.rows, macro db)};
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
				access: [AFinal],
				name: column.name,
				kind: FVar(valueTypeToComplexType(column.type), null),
				pos: pos,
			});
		}
		
		return def;
	}
	
	function buildTableParser(table:TableSchema):TypeDefinition {
		var pos = Context.currentPos();
		var parserName = capitalize(table.name) + 'Parser';
		var dbCt = makeDatabaseCt();
		
		var def = macro class $parserName {
			public static function parse(rows:tink.pure.Vector<exp.db.Row>, db:tink.core.Ref<$dbCt>) {
				return ${tableParser(table.columns, macro rows, macro db)};
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
		var dbCt = makeDatabaseCt();
		var typeCt = makeTypeCt(type.name);
		
		var def = macro class $parserName {
			public static function parse<Db>(value:exp.db.CustomValue, db:tink.core.Ref<$dbCt>):$typeCt {
				return ${customValueParser(type, macro value)}
			}
		}
		
		return def;
	}
	
	function getCustomType(name:String):CustomType {
		return schema.types.find(v -> v.name == name);
	}
	
	function tableParser(columns:Vector<Column>, rows:Expr, db:Expr):Expr {
		var rowCt = columnsToComplexType(columns);
		return macro {
			var rows = $rows;
			var list = [for(row in rows) (${rowParser(columns, macro row, db)}:$rowCt)];
			${switch columns.find(c -> c.type == Identifier) {
				case null: macro (list:haxe.ds.ReadOnlyArray<$rowCt>);
				case {name: id}: macro ([for(v in list) v.$id => v]:haxe.ds.ReadOnlyMap<String, $rowCt>);
			}}
		}
	}
	
	function rowParser(columns:Vector<Column>, row:Expr, db:Expr):Expr {
		var pos = Context.currentPos();
		return EObjectDecl([for(column in columns) {
			field: column.name,
			expr: valueParser(column.type, macro $row.get($v{column.name}), db),
		}]).at(pos);
	}
	
	function valueParser(type:ValueType, value:Expr, db:Expr):Expr {
		var pos = Context.currentPos();
		return switch type {
			case Identifier:
				macro exp.db.util.ValueParser.parseIdentifier($value);
			case Integer:
				macro exp.db.util.ValueParser.parseInteger($value);
			case Text:
				macro exp.db.util.ValueParser.parseText($value);
			case Boolean:
				macro exp.db.util.ValueParser.parseBoolean($value);
			case Enumeration(list):
				var expected = list.toArray().join(', ');
				var expr = ESwitch(macro str, [{values: [for(item in list) macro $v{item}], expr: macro cast str}], macro throw 'Unknown value "' + str + '". Expected ' + $v{expected}).at(pos);
				macro exp.db.util.ValueParser.parseEnumeration($value, str -> $expr);
			case SubTable(sub):
				macro exp.db.util.ValueParser.parseSubTable($value, rows -> ${tableParser(sub, macro rows, db)});
			case Ref(table):
				var fieldName = uncapitalize(table);
				macro exp.db.util.ValueParser.parseRef($value, id -> () -> $db.value.$fieldName[id]);
			case Custom(name):
				var parser = macro $p{typePack.concat(['Types', name + 'Parser'])};
				macro exp.db.util.ValueParser.parseCustom($value, $parser.parse.bind(_, $db));
		}
	}
	
	function customValueParser(type:CustomType, value:Expr):Expr {
		var pos = Context.currentPos();
		var prefix = macro $p{typePack.concat(['Types', type.name])}
		return macro {
			var value = $value;
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
							var args = [for(i in 0...arr.length) valueParser(arr[i].type, macro arr[$v{i}], macro db)];
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
	
	
	function valueTypeToComplexType(type:ValueType):ComplexType {
		return switch type {
			case Identifier:
				macro:String;
			case Integer:
				macro:Int;
			case Text:
				macro:String;
			case Boolean:
				macro:Bool;
			case Enumeration(list):
				TPath({pack: ['enums'], name: 'Enums', params: [for(v in list) TPExpr(macro $v{v})]});
			case SubTable(columns):
				var ct = columnsToComplexType(columns);
				switch columns.find(c -> c.type == Identifier) {
					case null: macro:haxe.ds.ReadOnlyArray<$ct>;
					case _: macro:haxe.ds.ReadOnlyMap<String, $ct>;
				}
			case Ref(table):
				var ct = makeTableCt(table);
				macro:tink.core.Lazy<$ct>;
			case Custom(name):
				makeTypeCt(name);
		}
	}
	
	function columnsToComplexType(columns:Vector<Column>):ComplexType {
		var fields = [];
		var ret = TAnonymous(fields);
		for(column in columns) {
			fields.push({
				access: [AFinal],
				name: column.name,
				kind: FVar(valueTypeToComplexType(column.type), null),
				pos: Context.currentPos(),
			});
		}
		return ret;
	}
	
	inline function makeDatabaseCt():ComplexType {
		return TPath({pack: pack, name: 'Database'});
	}
	
	inline function makeTypeCt(name:String):ComplexType {
		return TPath({pack: typePack, name: 'Types', sub: name});
	}
	
	inline function makeTableCt(name:String):ComplexType {
		return TPath({pack: tablePack, name: 'Tables', sub: capitalize(name)});
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
			else if(this == 'Boolean') Boolean;
			else if(this.Enumeration != null) Enumeration((this.Enumeration.list:Array<String>));
			else if(this.Custom != null) Custom(this.Custom.name);
			else if(this.SubTable != null) SubTable(Vector.fromArray((this.SubTable.columns:Array<ColumnRepresentation>).map(TypeBuilder.parseColumnRepresentation)));
			else if(this.Ref != null) Ref(this.Ref.table);
			else throw 'TODO $this';
	}
}