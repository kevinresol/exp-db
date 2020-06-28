package exp.db.util;

import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.Json;
import tink.pure.List;
import exp.db.Database;

using sys.io.File;

@:allow(exp.db.util)
class TypeBuilder {
	public static function build(file:String, pack:Array<String>) {
		var path = Context.resolvePath(file);
		var rep = Json.parse(path.getContent());
		var schema = parseDatabaseRepresentation(rep);
		buildDatabase(schema, pack);
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
	
	public static function buildDatabase(database:DatabaseSchema, pack:Array<String>) {
		var pos = Context.currentPos();
		
		var db = macro class Database {}
		db.pack = pack;
		db.kind = TDStructure;
		
		var tablePack = pack.concat(['tables']);
		var typePack = pack.concat(['types']);
		
		// define custom types before tables 
		// see: https://github.com/HaxeFoundation/haxe/issues/9657
		for(type in database.types) {
			Context.defineType(type.toTypeDefintionWithPack(typePack));
		}
		
		for(table in database.tables) {
			var hasId = table.columns.exists(c -> c.type == Identifier);
			var typeName = capitalize(table.name);
			var ct = TPath({pack: tablePack, name: typeName});
			
			db.fields.push({
				name: table.name,
				kind: FVar(hasId ? macro:Map<String, $ct> : macro:Array<$ct>, null),
				pos: pos,
			});
			
			var tbl = macro class $typeName {}
			tbl.pack = tablePack;
			tbl.kind = TDStructure;
			
			for(column in table.columns) {
				tbl.fields.push({
					name: column.name,
					kind: FVar(valueTypeToComplexType(column.type, typePack), null),
					pos: pos,
				});
			}
			
			Context.defineType(tbl);
		}
		
		Context.defineType(db);
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
				columnsToComplexType(columns, pack);
			case Ref(table):
				macro:Dynamic;
			case Custom(name):
				TPath({pack: pack, name: name});
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