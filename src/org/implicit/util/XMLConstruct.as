import org.implicit.util.XMLConstructNode;

/**
* XMLConstruct, Version 0.9.7 BETA
* A recursive method for converting XML into a dot-syntax / multi-dimensional array structure.
* Updates at: http://www.indivision.net
*
* @author: Joseph Miller
* Based on work by: Max Ziebell, J. Milkins and others at http://proto.layer51.com/
* @version: 0.9.7
*/
class org.implicit.util.XMLConstruct extends XMLConstructNode {
	// The default extension ("firstChild") used to clip root of XML to avoid redundant path element
	private var rootVal:String = "firstChild";
	public var onLoad:Function; 
	//
	public function XMLConstruct(input:XML) {
		super();
		if (input != undefined) {
			parse(input);
		}
	}

	//
	//*
	//* Getter for stripRoot value
	//* returns true if set to strip root XML level
	//*
	public function get stripRoot():Boolean {
		if (rootVal == "firstChild") {
			return true;
		} else {
			return false;
		}
	}
	//
	//*
	//* Setter for stripRoot value
	//*
	//* @param	z	true or false determining whether or not root level is stripped from return Object
	//* true = strip root XML level from return Object
	//* false = leave return Object with root
	//*
	public function set stripRoot(z:Boolean):Void {
		if (z == true) {
			rootVal = "firstChild";
		} else {
			rootVal = undefined;
		}
	}
	//
	//*
	//* Builds Object from XML using parseNode and places data on this instance.
	//* 
	//* @param	input	XML Object or String with XML formatting
	//*
	public function parse(input:XML):Void {
		var pXML:XML, pObj:XMLConstructNode, c:String, tArr:Array;
		pObj = parseNode(input[rootVal], new XMLConstructNode());
		// Clear any previous nodes/attributes from this instance (without removing Functions i.e. 'onLoad' event function):
		for (c in this) {
			if (this[c] instanceof Array) {
				delete this[c];
			}
		}
		attributes = undefined;
		// Add nodes/attributes to this instance:
		// In order to allow toXML routine to return nodes in correct order, it was necessary to push nodes into an Array
		// before adding them to this object. Looking for more elegant solution for this.
		tArr = [];
		for (c in pObj) {
			if (c == "attributes") {
				for (var a in pObj[c]) {
					addAttribute(a, pObj[c][a]);
				}
			} else {
				tArr.push(c);
				//this[c] = pObj[c];
				//addNode(c, pObj[c]);
			}
		}
		for (c in tArr) {
			this[tArr[c]] = pObj[tArr[c]];
		}
	}
	//
	//*
	//* Recursive method that spiders through an XML and returns a same-structured multi-dimensional Array of Objects.
	//* 
	//* @param	xObj	XMLNode Object / current location in XML
	//* @param	obj		Multi-Dimensional Array Object / current position of return Object as it is built
	//*
	private function parseNode(xObj:XMLNode, obj:XMLConstructNode):XMLConstructNode {
		var c:String, nName:String, nType:Number, cNode:XMLNode;
		// Attributes:
		var xa:Object = xObj.attributes;
		for (c in xa) {
			obj.addAttribute(c, xa[c]);
		}
		// Child Nodes:
		for (c in xObj.childNodes) {
			cNode = xObj.childNodes[c];
			nName = cNode.nodeName;
			nType = cNode.nodeType;
			if (nType == 3) {
				obj._value = cNode.nodeValue;
			} else if (nType == 1 && nName != null) {
				var sObj = parseNode(cNode, new XMLConstructNode());
				obj.appendChild(nName, sObj);
			}
		}
		return obj;
	}
	//
	//*
	//* Loads XML file, parses XML into Array Object. Notifies listeners via dispatchEvent and runs onLoad function.
	//*
	//* @param	file		path to XML file or script returning XML data
	//*
	public function load(file:String) {
		var thisObj:XMLConstruct = this;
		var tXML:XML = new XML();
		tXML.ignoreWhite = true;
		tXML.load(file);
		tXML.onLoad = function(success:Boolean) {
			if (success){
				thisObj.parse(tXML);
				//thisObj.onLoad(success);
				thisObj.onLoad({type:"onLoad", target:thisObj, success:success});
			}
			else{		
				thisObj.onLoad(false);
				}
		};
	}
}