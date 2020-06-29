package exp.db.util;

import exp.db.*;
import tink.pure.List;

using tink.CoreApi;

class ValueParser {
	public static function parseInteger(v:Value):Int {
		switch v {
			case Integer(v): return v;
			case v: throw 'unexpected value for type "Integer": $v';
		}
	}
	
	public static function parseText(v:Value):String {
		switch v {
			case Text(v): return v;
			case v: throw 'unexpected value for type "Text": $v';
		}
	}
	
	public static function parseIdentifier(v:Value):String {
		switch v {
			case Identifier(v): return v;
			case v: throw 'unexpected value for type "Identifier": $v';
		}
	}
	
	public static function parseSubTable<T>(v:Value, f:List<Row>->T):T {
		switch v {
			case SubTable(v): return f(v);
			case v: throw 'unexpected value for type "SubTable": $v';
		}
	}
	
	public static function parseRef<T>(v:Value, f:String->Lazy<T>):Lazy<T> {
		switch v {
			case Ref(v): return f(v);
			case v: throw 'unexpected value for type "SubTable": $v';
		}
	}
	
	public static function parseCustom<T, Db>(v:Value, f:CustomValue->T):T {
		switch v {
			case Custom(v): return f(v);
			case v: throw 'unexpected value for type "Custom": $v';
		}
	}
}