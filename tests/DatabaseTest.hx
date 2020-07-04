package;

import foo.data.Database;
import foo.data.tables.Tables;
import foo.data.types.Types;

using tink.CoreApi;

@:asserts
class DatabaseTest {
	var db:Database;
	
	public function new() {}

	@:setup
	public function setup() {
		return 
			switch Database.parse(sys.io.File.getContent('tests/content.json')) {
				case Success(db):
					this.db = db;
					Promise.NOISE;
				case Failure(e):
					Promise.reject(e);
			}
	}
	
	public function run() {
		var event = db.events['id_0'];
		asserts.assert(event != null, 'Get entry by id');
		asserts.assert(event.e.match(Grow(1)));
		asserts.assert(event.enm == Aa);
		asserts.assert(event.r.get().id == 'id_0');
		return asserts.done();
	}
}