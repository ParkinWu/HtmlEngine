//
//  DOM.swift
//  HtmlEngine
//
//  Created by pzwu on 16/7/11.
//  Copyright © 2016年 pzwu. All rights reserved.
//

import UIKit
func == (lhs: DOM.Value, rhs: DOM.Value) -> Bool {
    switch (lhs, rhs) {
    case (DOM.Value.Keyword(let a), DOM.Value.Keyword(let b)) where a == b:
        return true
    case (DOM.Value.Length(let a, DOM.Unit.Px), DOM.Value.Length(let b, DOM.Unit.Px)) where a == b:
        return true
    case (DOM.Value.ColorValue(let a), DOM.Value.ColorValue(let b)) where a == b:
        return true
    default:
        return false
    }
   
}

func == (lhs: DOM.Color, rhs: DOM.Color) -> Bool {
    return lhs.a == rhs.a && lhs.b == rhs.b && lhs.g == rhs.g && lhs.r == rhs.r

}
class DOM: NSObject {
    struct Node: CustomStringConvertible {
        var children: Array<Node>
        var nodeType: NodeType
        
        var level:Int = 0
        
        init(children: Array<Node>, nodeType: NodeType) {
            self.children = children
            self.nodeType = nodeType
            self.level = 0
        }
        var description: String {
            get {
                var s = ""
                var level = self.level
                while level > 0 {
                    s = s + "\t"
                    level -= 1
                }
                
                s += "children: ["
                for var child in children {
                    child.level = self.level + 1
                    s += "\n\(child)"
                }
                level = self.level
                while level > 0 {
                    s = s + "\t"
                    level -= 1
                }
                s += "]\n"
                level = self.level
                while level > 0 {
                    s = s + "\t"
                    level -= 1
                }
                s += "nodeType: \(nodeType)\n"
                return s
            }
        }
    }
    
    
    enum NodeType {
        case Text(String)
        case Element(ElementData)
    }
    
    struct ElementData {
        var tagName: String
        var attributes: AttrMap
        
        func id() -> String? {
            return self.attributes["id"]
        }
        
        func classes() -> Set<String> {
            switch self.attributes["class"] {
            case .Some(let classList):
                return Set(classList.characters.split(" ").map(String.init))
            case .None:
                return Set<String>()
            }
        }
        
    }
    
    typealias AttrMap = Dictionary<String, String>
    
    
    
    
    class func text(data: String) -> Node {
        return Node(children: [], nodeType: .Text(data))
    }
    
    class func elem(name: String, attrs: AttrMap, children: Array<Node>) -> Node {
        return Node(children: children, nodeType: .Element(ElementData(tagName: name, attributes: attrs)))
    }
    
    //MARK: - CSS
    struct StyleSheet {
        var rules: [Rule]
    }
    
    struct Rule {
        var selectors: [Selector]
        var declarations: [Declaration]
        
        
    }
    
    enum Selector {
        case Simple(SimpleSelector)
//        var selector:SimpleSelector
        
        func specificity() -> Specificity {
            
            if case let Selector.Simple(simple) = self {
                var a = simple.id?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
                let b = simple.cls.count
                var c = simple.tagName?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
                if a == nil { a = 0 }
                if c == nil { c = 0 }
                return a! * 100 + b * 10 + c!
            }
            return 0
            
            
            
        }
    }
    
    typealias Specificity = Int
    
    struct Declaration {
        var name: String
        var value: Value
    }
    
    enum Value: Equatable {
        case Keyword(String)
        case Length(Float, Unit)
        case ColorValue(Color)
        
        func toPx() -> Float {
            switch self {
            case let Value.Length(f, _):
                return f
            default:
                return 0.0
            }
        }
    }
    
    enum Unit {
        case Px
    }
    
    struct Color: Equatable {
        var r: UInt8
        var g: UInt8
        var b: UInt8
        var a: UInt8
        
        
    }
    
    struct SimpleSelector {
        var tagName: String?
        var id: String?
        var cls: [String]
        
    }
}
