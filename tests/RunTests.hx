package ;

import tink.unit.*;
import tink.testrunner.*;

class RunTests {

	static function main() {
		switch foo.Database.parse(sys.io.File.getContent('tests/content.json')) {
			case Success(db):
				switch db.events['id_0'].e {
					case Grow(v): trace('grow $v');
					case Combined(e1, e2): trace('combined, $e1, $e2');
				}
			case Failure(e):
				trace(e);
		}
		
		Runner.run(TestBatch.make([
			new ParserTest(),
		])).handle(Runner.exit);
	}
	
}