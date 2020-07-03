package haxe.ds;

@:forward(exists, keys, iterator, keyValueIterator, toString)
abstract ReadOnlyMap<K, V>(Map<K, V>) from Map<K, V> {
	@:arrayAccess inline function get(key:K)
		return this[key];
	
	public inline function copy():ReadOnlyMap<K, V>
		return this.copy();
	
	@:to inline function toIterable():Iterable<V>
		return cast this;
}