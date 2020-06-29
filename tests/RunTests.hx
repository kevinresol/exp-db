package ;

import tink.unit.*;
import tink.testrunner.*;

class RunTests {

	static function main() {
		switch foo.Database.parse(sys.io.File.getContent('tests/content.json')) {
			case Success(db):
				trace(db.events);
			case Failure(e):
				trace(e);
		}
		
		Runner.run(TestBatch.make([
			new ParserTest(),
		])).handle(Runner.exit);
	}
	
}