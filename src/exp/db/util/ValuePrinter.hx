package exp.db.util;

class ValuePrinter {
	public static function print(value:Value):String {
		return switch value {
			case Identifier(v): v;
			case Integer(v): '$v';
			case Text(v): v;
			case SubTable(rows): '${rows.length} row(s)...';
			case Ref(v): v;
			case Custom(_): printHaxeString(value);
		}
	}
	
	public static function printHaxeString(value:Value):String {
		return switch value {
			case Identifier(v): v;
			case Integer(v): '$v';
			case Text(v): '"$v"';
			case SubTable(rows): '#UNSUPPORTED';
			case Ref(v): '.$v';
			case Custom(v) if(v.args.length == 0): v.name;
			case Custom(v): '${v.name}(${[for(arg in v.args) printHaxeString(arg)].join(', ')})';
		}
	}
}