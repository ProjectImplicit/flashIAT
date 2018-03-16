/**
* XMLConstructNode, Version 0.9.7 BETA
* A data Object element used to build XMLConstruct representation of an XML.
* Updates at: http://www.indivision.net
*
* @author: Joseph Miller
* @version: 0.9.7
*/
class org.implicit.util.XMLConstructNode {
	public var attributes:Object;
	public var _value:String;
	private var nodeName:String;
	public function XMLConstructNode() {
	}
	// 
	//*
	//* Creates a node array if one doesn't already exist (and attaches __resolve method). Adds new node to array.
	//* 
	//* @param	nName	Name for new node
	//* @param	sObj	Node object to add
	//*
	public function appendChild(nName:String, sObj:XMLConstructNode):Void {
		if (!(this[nName] instanceof Array)) {
			this[nName] = [];
			this[nName].__resolve = getFirstElement;
		}
		sObj.nodeName = nName;
		this[nName].unshift(sObj);
	}
	//
	//*
	//* Creates attribute object if doesn't exist. Adds attribute to this XMLConstructNode.
	//* 
	//* @param	aName	Name for new attribute
	//* @param	aData	Value for attribute to add
	//*
	public function addAttribute(aName:String, aData:String):Void {
		if (attributes == undefined) {
			attributes = {};
		}
		attributes[aName] = aData;
	}
	//
	//*
	//* Returns XMLNode representation of this node.
	//*
	private function toXMLNode():XMLNode {
		var doc:XML, c:String, textNode:XMLNode, node:XMLNode;
		doc = new XML();
		node = doc.createElement(nodeName);
		for (c in attributes) {
			node.attributes[c] = attributes[c];
		}
		doc.appendChild(node);
		textNode = doc.createTextNode(_value);
		node.appendChild(textNode);
		return node;
	}
	//
	//*
	//* Function resolved to if node is referred to as any Object other than an Array. Returns appropriate Array value.
	//* 
	//* @param	f	Name representation of an XML node
	//*
	private function getFirstElement(f:String) {
		return this[0][f];
	}
	//
	//*
	//* Recursive method that spiders through this instance and all of its child XMLConstructNodes and returns the data in XML format.
	//* 
	//* @param	xObj	XMLConstructNode / current location in XMLConstruct
	//* @param	doc		XML / current position of return XML as it is built
	//*
	private function parseConstruct(xObj:XMLConstructNode, doc:XML):XML {
		var a:String, n:String, aObj:Array, nObj:XMLConstructNode, nName:String, nNode:XMLNode;
		for (a in xObj) {
			aObj = xObj[a];
			if (aObj instanceof Array) {
				for (n in aObj) {
					nObj = aObj[n];
					if (nObj instanceof XMLConstructNode) {
						doc.appendChild(nObj.toXMLNode());
						doc.lastChild.appendChild(parseConstruct(nObj, new XML()));
					}
				}
			}
		}
		return doc;
	}
	//
	//*
	//* Initiates parseConstruct on this instance and returns XML.
	//*
	public function toXML():XML {
		return parseConstruct(this, new XML());
	}
}