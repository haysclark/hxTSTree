package ;

import ds.TSTree;
import flash.Lib;
import haxe.ds.ArraySort;
import haxe.ds.GenericStack;
import haxe.Log;
import haxe.Serializer;
import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import haxe.Unserializer;


using StringTools;

/**
 * ...
 * @author azrafe7
 */
class Tests extends TestCase
{

	var dict = ["in", "John", "gin", "inn", "pin", "longjohn", "apple", "fin", "pint", "inner", "an", "pit"];
	var tree:TSTree<String>;
	
	
	public function new()
	{
		super();
		
		tree = new TSTree<String>();		
		for (s in dict) tree.insert(s, s);
		
		tree.clear();
		tree.balancedBulkInsert(dict, dict);
		
	#if sys
		tree.writeDotFile("test_dict.dot");
	#end
    }
	
	public function testLength():Void 
	{
		assertEquals(dict.length, tree.numKeys);
		tree.remove(dict[0]);
		assertEquals(dict.length - 1, tree.numKeys);
		tree.insert(dict[0], dict[0]);
		assertEquals(tree.getAll().length, tree.getAllData().length);
		assertEquals(tree.getAllKeys().length, tree.getAllData().length);
	}
	
	public function testHasKey():Void 
	{
		assertFalse(tree.hasKey(""));
		assertFalse(tree.hasKey("party"));
		assertTrue(tree.hasKey("in"));
		assertTrue(tree.hasKey("inn"));
		assertFalse(tree.hasKey("john"));
	}
	
	public function testGetData():Void 
	{
		assertTrue(tree.getDataFor("John") == "John");
		assertTrue(tree.getDataFor("") == null);
		assertTrue(tree.getDataFor("pity") == null);
		assertTrue(tree.getDataFor("pit") == "pit");
		assertTrue(tree.getDataFor("in") == "in");
		tree.insert("in", "overwritten");
		assertTrue(tree.getDataFor("in") == "overwritten");
	}
	
	public function testPrefixSearch():Void 
	{
		assertTrue(tree.prefixSearch("").length == 0);
		assertEquals("[pin,pint,pit]", Std.string(tree.prefixSearch("p")));
		assertEquals("[in,inn,inner]", Std.string(tree.prefixSearch("in")));
	}
	
	public function testPatternSearch():Void 
	{
		assertTrue(tree.patternSearch("").length == 0);
		assertEquals("[fin,gin,pin]", Std.string(tree.patternSearch(".in")));
		assertEquals("[pin,pit]", Std.string(tree.patternSearch("p..")));
	}
	
	public function testDistanceSearch():Void 
	{
		assertTrue(tree.distanceSearch("", 3).length == 0);
		assertEquals("[]", Std.string(tree.distanceSearch("min", 0)));
		assertEquals("[pin]", Std.string(tree.distanceSearch("pin", 0)));
		assertEquals("[fin,gin,pin]", Std.string(tree.distanceSearch("min", 1)));
		assertEquals("[fin,gin,inn,pin,pit]", Std.string(tree.distanceSearch("min", 2)));
		assertEquals("[an,in]", Std.string(tree.distanceSearch("io", 5)));
		assertEquals("[an,in]", Std.string(tree.distanceSearch("_n", 1)));
	}
	
	public function testSortedOrder():Void 
	{
		var sorted = [].concat(dict);
		ArraySort.sort(sorted, function (keyA:String, keyB:String):Int
		{
			return keyA > keyB ? 1 : keyA < keyB ? -1 : 0;
		});
	
		assertEquals(sorted.toString(), tree.getAllKeys().toString());
	}
	
	public function testSerialization():Void 
	{
		var currTree:TSTree<String> = tree;
		
		var serializedStr = currTree.serialize();
		var unserializedTree = TSTree.unserialize(serializedStr);
		assertEquals(currTree.getAllKeys().toString(), unserializedTree.getAllKeys().toString());
		assertEquals(currTree.getAllData().toString(), unserializedTree.getAllData().toString());
		assertTrue(currTree.numKeys == unserializedTree.numKeys);
		assertTrue(currTree.numNodes == unserializedTree.numNodes);

		// test empty tree
		currTree = new TSTree();
		serializedStr = currTree.serialize();
		unserializedTree = TSTree.unserialize(serializedStr);
		assertEquals(currTree.getAllKeys().toString(), unserializedTree.getAllKeys().toString());
		assertEquals(currTree.getAllData().toString(), unserializedTree.getAllData().toString());
		assertTrue(currTree.numKeys == unserializedTree.numKeys);
		assertTrue(currTree.numNodes == unserializedTree.numNodes);
	}
	
	public function testPrevNext():Void 
	{
		/*
		assertEquals(null, tree.prevOf(""));
		assertEquals(null, tree.prevOf("pony"));
		assertEquals(null, tree.prevOf("John"));
		assertEquals("pin", tree.prevOf("pint"));
		*/
		
		/*
		assertEquals(null, tree.nextOf(""));
		assertEquals(null, tree.nextOf("pony"));
		assertEquals(null, tree.nextOf("pit"));
		assertEquals("pit", tree.nextOf("pint"));
		
		for (k in dict) trace(k + " -> " + tree.nextOf(k));
		*/
		//tree.nextOf("John");

	}
	
	static public function run():Void 
	{
		var runner = new CustomTestRunner();
		runner.add(new Tests());
		var success = runner.run();
	}
}


private class CustomTestRunner extends TestRunner {
	
#if flash
	var stringBuffer:StringBuf;
	
	override public function run():Bool 
	{
		var oldPrint = TestRunner.print;
		stringBuffer = new StringBuf();
		
		TestRunner.print = function (v:Dynamic):Void {
			stringBuffer.add(Std.string(v));
		};
		
		var result = super.run();
		flash.Lib.trace(stringBuffer.toString());
		TestRunner.print = oldPrint;
		
		return result;
	}
#end
}