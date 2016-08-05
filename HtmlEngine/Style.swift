//
//  Style.swift
//  HtmlEngine
//
//  Created by pzwu on 16/8/1.
//  Copyright © 2016年 pzwu. All rights reserved.
//

import UIKit

enum Display {
    case Inline
    case Block
    case None
}

typealias MatchedRule = (DOM.Specificity, DOM.Rule)
typealias PropertyMap = Dictionary<String, DOM.Value>
class Style {
    
    
    class func styleTree(root: DOM.Node, stylesheet: DOM.StyleSheet) -> StyledNode {
        var propertyMap: PropertyMap? = nil
        
        switch root.nodeType {
        case DOM.NodeType.Element(let element):
            propertyMap = specialValues(element, stylesheet: stylesheet)
        case DOM.NodeType.Text(_):
            propertyMap = PropertyMap()
        }
        let styleNodes:[StyledNode] = root.children.map({ (child) in return styleTree(child, stylesheet: stylesheet)})
        
        return StyledNode(node: root,
                          specialValues: propertyMap!,
                          children: styleNodes)
    }
    
    class func specialValues(elem: DOM.ElementData, stylesheet: DOM.StyleSheet) -> PropertyMap {
        var values:[String: DOM.Value] = [:]
        var rules = matchingRules(elem, stylesheet: stylesheet)
        
        rules.sortInPlace( {$0.0 > $1.0})
        
        for (_, rule) in rules {
            for declaration in rule.declarations {
                values[declaration.name] = declaration.value
            }
        }
        
        return values
    }
    
    class func matchingRules(elem: DOM.ElementData, stylesheet: DOM.StyleSheet) -> [MatchedRule] {
        return stylesheet.rules.filterMap({ (rule) in return matchingRule(elem, rule: rule) })
    }
    
    class func matchingRule(elem: DOM.ElementData, rule: DOM.Rule) -> MatchedRule? {
        return rule.selectors
            .find({ (selector) in return matches(elem, selector: selector) })
            .map({ (selector) in return (selector.specificity(), rule) }).first
    }
    
    
    class func matches(elem: DOM.ElementData, selector: DOM.Selector) -> Bool {
        switch selector {
        case .Simple(let simpleSelector):
            return matcheSimpleSelector(elem, selector: simpleSelector)
        }
        
    }
    
    class func matcheSimpleSelector(elem: DOM.ElementData, selector: DOM.SimpleSelector) -> Bool {
        if selector.tagName.any({ (tagName) in tagName != elem.tagName }) {
            return false
        }
        
        if selector.id.any({ (id) in .Some(id) != elem.id()}) {
            return false
        }
        let eleClasses = elem.classes()
        if selector.cls.any({ (cls) in !eleClasses.contains(cls)}) {
            return false
        }
        return true
    }
}


struct  StyledNode {
    var node: DOM.Node
    var specialValues: PropertyMap
    var children: [StyledNode]
    
    func value(name: String) -> DOM.Value? {
        return self.specialValues[name]
    }
    
    func lookup(name: String, fallbackName: String, defaultValue: DOM.Value) -> DOM.Value {
        return self.value(name)
            .unwrapOrElse({ self.value(fallbackName)
            .unwrapOrElse({ return defaultValue }) })
    }
    func display() -> Display {
        switch self.value("display") {
        case .Some(DOM.Value.Keyword(let s)):
            switch s {
            case "block":
                return Display.Block
            case "none":
                return Display.None
            default:
                return Display.Inline
            }
        default:
            return Display.Inline
        }
    }
    
    

    
    
    
}


    
