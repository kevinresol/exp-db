package;

import exp.db.util.ValueParser;
import exp.db.Value;
import exp.db.ValueType;
import exp.db.CustomType;
import exp.db.CustomValue;
import tink.pure.List;


@:asserts
class ParserTest {
	var type = new CustomType({
		name: 'Event',
		fields: [
			{
				name: 'Link',
				args: [
					{name: 'v1', type: Integer},
					{name: 'v2', type: Custom('Event')},
				]
			},
			{
				name: 'Leaf',
				args: [
					{name: 'v1', type: Text},
				]
			},
		]
	});
	
	public function new() {}
	
	public function expr() {
		return switch exp.db.app.util.ValueParser.parseExpr(Custom('Event'), macro Link(1, Leaf('1')), _ -> Success(type)) {
			case Success(v):
				asserts.done();
			case Failure(e):
				asserts.fail(Std.string(e.data));
		}
	}
	
	@:variant(Integer, '1', v -> v.match(Integer(1)))
	@:variant(Text, '1', v -> v.match(Text('1')))
	public function raw(t:ValueType, v:String, matcher:Value->Bool) {
		return switch exp.db.app.util.ValueParser.parseRawString(t, v, _ -> Success(type)) {
			case Success(v):
				asserts.assert(matcher(v));
				asserts.done();
			case Failure(e):
				asserts.fail(Std.string(e.data));
		}
	}
	
	public function haxe() {
		return switch exp.db.app.util.ValueParser.parseHaxeString(Custom('Event'), 'Link(1, Leaf("1"))', _ -> Success(type)) {
			case Success(v):
				asserts.done();
			case Failure(e):
				asserts.fail(Std.string(e.data));
		}
	}
}