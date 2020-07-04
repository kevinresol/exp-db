package exp.db;

import tink.pure.List;
using tink.CoreApi;

@:using(exp.db.ValueType.ValueTypeTools)
enum ValueType {
	Identifier;
	Integer;
	Text;
	Boolean;
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
			case Boolean: Boolean(true);
			case SubTable(columns): SubTable([]);
			case Ref(table): Ref('');
			case Custom(name): null;
		}
	}
	
	/**
	 * Try to convert `value` into compatible form for the given `type`
	 */
	public static function convertValue(type:ValueType, value:Value):Outcome<Value, Error> {
		if(value == null) 
			value = Text(''); // seems fine to treat null as empty string for conversion purpose
		
		return switch [type, value] {
			case [Identifier, Identifier(v) | Integer('$_' => v) | Text(v) | Ref(v)]:
				Success(Identifier(v));
			case [Identifier, _]:
				Success(Identifier('')); // fallback default
			case [Integer, Identifier(Std.parseInt(_) => i) | Integer(i) | Text(Std.parseInt(_) => i) | Ref(Std.parseInt(_) => i)] if(i != null):
				Success(Integer(i));
			case [Integer, _]:
				Success(Integer(0)); // fallback default
			case [Text, Identifier(v) | Integer('$_' => v) | Text(v) | Ref(v)]:
				Success(Text(v));
			case [Text, _]:
				Success(Text('')); // fallback default
			case [Boolean, Identifier(_.length > 0 => v) | Integer(_ != 0 => v) | Text(_.length > 0 => v) | Ref(_.length > 0 => v)]:
				Success(Boolean(v));
			case [Boolean, _]:
				Success(Boolean(true)); // fallback default
			case [SubTable(_), SubTable(v)]:
				Success(SubTable(v));
			case [SubTable(_), _]:
				Success(SubTable([])); // fallback default
			case [Ref(_), Identifier(v) | Integer('$_' => v) | Text(v) | Ref(v)]:
				Success(Ref(v));
			case [Ref(_), _]:
				Success(Ref('')); // fallback default
			case [Custom(_), Custom(v)]:
				Success(Custom(v));
			case _:
				Failure(new Error('Cannot convert value'));
		}
	}
	
	public static function validateValue(type:ValueType, value:Value, getCustomType:String->Outcome<CustomType, Error>):Outcome<Noise, Error> {
		return switch [type, value] {
			case [Identifier, Identifier(_)]
			| [Integer, Integer(_)]
			| [Text, Text(_)]
			| [Boolean, Boolean(_)]
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