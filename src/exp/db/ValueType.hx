package exp.db;

import tink.pure.List;
using tink.CoreApi;

@:using(exp.db.ValueType.ValueTypeTools)
enum ValueType {
	Identifier;
	Integer;
	Text;
	SubTable(columns:List<Column>);
	Ref(table:String);
	Custom(name:String);
}

class ValueTypeTools {
	public static function getDefaultValue(type:ValueType, rowNumber:Int):Value {
		return switch type {
			case Identifier: Identifier('id_$rowNumber');
			case Integer: Integer(0);
			case Text: Text('');
			case SubTable(columns): SubTable([]);
			case Ref(table): Ref('');
			case Custom(name): null;
		}
	}
	
	public static function validateValue(type:ValueType, value:Value, getCustomType:String->Outcome<CustomType, Error>):Outcome<Noise, Error> {
		return switch [type, value] {
			case [Identifier, Identifier(_)]
			| [Integer, Integer(_)]
			| [Text, Text(_)]
			| [SubTable(_), SubTable(_)]
			| [Ref(_), Ref(_)]: Success(Noise);
			case [Custom(name), Custom(cvalue)]:
				switch getCustomType(name) {
					case Success(ctype):
						validateCustomValue(ctype, cvalue, getCustomType);
					case Failure(e):
						Failure(e);
				}
			case _:
				Failure(new Error('Got ${value.getName()} but expected ${type.getName()}'));
		}
	}
	
	public static function validateCustomValue(type:CustomType, value:CustomValue, getCustomType:String->Outcome<CustomType, Error>):Outcome<Noise, Error> {
		return Error.catchExceptions(() -> {
			function check(ctor, numArgs, next:CustomType.Field->Void) {
				switch type.fields.first(f -> f.name == ctor) {
					case None:
						throw 'Field "$ctor" is not part of ${type.name}';
					case Some(field) if(field.args.length != numArgs):
						throw 'Expected ${field.args.length} arguments but got ${numArgs}';
					case Some(field):
						next(field);
				}
			}
			
			check(value.name, value.args.length, field -> {
				var fargs = field.args.toArray();
				var vargs = value.args.toArray();
				for(i in 0...fargs.length) validateValue(fargs[i].type, vargs[i], getCustomType).sure();
			});
			
			Noise;
		});
	}
}