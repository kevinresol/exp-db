package ;

import tink.unit.*;
import tink.testrunner.*;

class RunTests {
	static function main() {
		switch foo.Database.parse(sys.io.File.getContent('tests/content.json')) {
			case Success(db):
				var event = db.events['id_0'];
				switch event.e {
					case Grow(v): trace('grow $v');
					case Combined(e1, e2): trace('combined, $e1, $e2');
				}
				switch event.enm {
					case Aa: trace('a');
					case Bb: trace('b');
					case Cc: trace('c');
				}
				trace(event.r.get());
			case Failure(e):
				trace(e);
		}
		
		Runner.run(TestBatch.make([
			new ParserTest(),
		])).handle(Runner.exit);
	}
}