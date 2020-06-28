package ;

import tink.unit.*;
import tink.testrunner.*;

class RunTests {

	static function main() {
		var db:foo.Database = null;
		var e:foo.types.Event;
		
		Runner.run(TestBatch.make([
			new ParserTest(),
		])).handle(Runner.exit);
	}
	
}