package exp.db.app.data;

import exp.db.ValueType;

class CustomTypeModel implements Model {
	@:editable var name:String;
	@:constant var fields:ObservableArray<FieldModel> = @byDefault new ObservableArray();
}

class FieldModel implements Model {
	@:editable var name:String;
	@:constant var args:ObservableArray<ArgumentModel> = @byDefault new ObservableArray();
}

class ArgumentModel implements Model {
	@:editable var name:String;
	@:editable var type:ValueType;
}