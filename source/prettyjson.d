module kprop.helper.prettyjson;
import std.json;
import std.range:repeat;
import std.conv:to;

/**
	Laeeth Isharc / Kaleidic Associates 2015

	Pretty printer for JSON (D Programming Language)
*/

string prettyPrint(JSONValue json, int indentLevel=0, string prefix="")
{
	import std.range:appender;
	auto ret=appender!string;
	ret.put('\t'.repeat(indentLevel));
	ret.put(prefix);
	//ret.put(' '.repeat(indentLevel*8));
	final switch(json.type) with(JSON_TYPE)
	{
		case NULL:
			ret.put("<null>\n");
			return ret.data;
		case STRING:
			ret.put(json.str~"\n");
			return ret.data;
		case INTEGER:
			ret.put(json.integer.to!string~"\n");
			return ret.data;
		case UINTEGER:
			ret.put(json.uinteger.to!string~"\n");
			return ret.data;
		case FLOAT:
			ret.put(json.floating.to!string~"\n");
			return ret.data;
		case TRUE:
			ret.put("true\n");
			return ret.data;
		case FALSE:
			ret.put("false\n");
			return ret.data;
		case OBJECT:
			ret.put("{\n");
			foreach(key,value;json.object)
				ret.put(value.prettyPrint(indentLevel+1,key~" : "));
			ret.put('\t'.repeat(indentLevel));
			ret.put("}\n");
		return ret.data;
		case ARRAY:
			ret.put("[\n");
			foreach(key;json.array)
				ret.put(prettyPrint(key,indentLevel+1));
			ret.put('\t'.repeat(indentLevel));
			ret.put("]\n");
			return ret.data;
	}
	assert(0);
}

