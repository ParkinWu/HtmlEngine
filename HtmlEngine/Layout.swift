//
//  Layout.swift
//  HtmlEngine
//
//  Created by pzwu on 16/8/4.
//  Copyright © 2016年 pzwu. All rights reserved.
//

import UIKit
func == (lhs: Layout.BoxType, rhs: Layout.BoxType) -> Bool {
    switch (lhs, rhs) {
    case (Layout.BoxType.BlockNode(_), Layout.BoxType.BlockNode(_)):
        return true
    case (Layout.BoxType.InlineNode(_), Layout.BoxType.InlineNode(_)):
        return true
    case (Layout.BoxType.AnonymousBlock, Layout.BoxType.AnonymousBlock):
        return true
    default:
        return false
    }
}
class Layout: NSObject {
    struct Rect {
        var x: Float = 0
        var y: Float = 0
        var width: Float = 0
        var height: Float = 0
        
        func extendedBy(edge: EdgeSize) -> Rect {
            return Rect(x: self.x , y: self.y, width: self.width + edge.left + edge.right, height: self.height + edge.top + edge.bottom)
        }
        
    }
    
    struct EdgeSize {
        var left: Float = 0
        var right: Float = 0
        var top: Float = 0
        var bottom: Float = 0
    }
    
    struct Dimensions {
        var content: Rect = Rect()
        var padding: EdgeSize = EdgeSize()
        var margin: EdgeSize = EdgeSize()
        var border: EdgeSize = EdgeSize()
        
        func paddingBox() -> Rect {
            return self.content.extendedBy(self.padding)
        }
        
        func borderBox() -> Rect {
            return self.paddingBox().extendedBy(self.border)
        }
        
        func marginBox() -> Rect {
            return self.borderBox().extendedBy(self.margin)
        }
        
        
    }
    
    enum BoxType:Equatable {
        case BlockNode(StyledNode)
        case InlineNode(StyledNode)
        case AnonymousBlock
        
    }
    
    class LayoutBox {
        var dimensions: Dimensions = Dimensions()
        var boxType: BoxType
        var children: [LayoutBox] = []
        
        init(boxType: BoxType) {
            self.boxType = boxType
        }
        
        func getStyleNode() -> StyledNode {
            switch self.boxType {
            case .BlockNode(let node):
                return node
            case .InlineNode(let node):
                return node
            case .AnonymousBlock:
                assert(false)
                
            }
        }
        
        func layout(containerBlock: Dimensions, neighborBlock: Dimensions) {
            switch self.boxType {
            case .BlockNode(_):
                layoutBlock(containerBlock, neighborBlock: neighborBlock)
                break
            case .InlineNode(_):
                break
            case .AnonymousBlock:
                break
            }
        }
        func getInlineContainer() -> LayoutBox {
            switch self.boxType {
            case .InlineNode(_):
                return self
            case .BlockNode(_):
                let boxType = self.children.last?.boxType
                if boxType == nil || boxType! != BoxType.AnonymousBlock {
                    self.children.append(LayoutBox(boxType: .AnonymousBlock))
                }
                return self.children.last!
            case .AnonymousBlock:
                assert(false)
            }
            
        }
        func layoutBlock(containerBlock: Dimensions, neighborBlock: Dimensions) {
            calculateBlockWidth(containerBlock)
            
            calculateBlockPosition(containerBlock, neighborBlock: neighborBlock)
            
            layoutBlockChildren()
            
            calculateBlockHeight(containerBlock)
            
        }
        func calculateBlockWidth(containerBlock: Dimensions) {
            let style = self.getStyleNode()
            let auto = DOM.Value.Keyword("auto")
            var width = style.value("width").unwrapOr(auto)
            
            let zero = DOM.Value.Length(0.0, DOM.Unit.Px)
            var marginLeft = style.lookup("margin-left", fallbackName: "margin", defaultValue: zero)
            var marginRight = style.lookup("margin-right", fallbackName: "margin", defaultValue: zero)
            let paddingLeft = style.lookup("padding-left", fallbackName: "padding", defaultValue: zero)
            let paddingRight = style.lookup("padding-right", fallbackName: "padding", defaultValue: zero)
            
            let borderLeft = style.lookup("border-left-width", fallbackName: "border-width", defaultValue: zero)
            let borderRight = style.lookup("border-right-width", fallbackName: "border-width", defaultValue: zero)
            
            let total = [marginLeft, marginRight, paddingLeft, paddingRight, borderLeft, borderRight].map({ $0.toPx() }).foldLeft(0, op: { $0 + $1 })
            
            if width != auto && total > containerBlock.content.width {
                if marginLeft == auto {
                    marginLeft = DOM.Value.Length(0, DOM.Unit.Px)
                }
                if marginRight == auto {
                    marginRight = DOM.Value.Length(0, DOM.Unit.Px)
                }
            }
            
            let underflow = containerBlock.content.width - total
            switch (width == auto, marginLeft == auto, marginRight == auto) {
            case (false, false, false):
                marginRight = DOM.Value.Length(marginRight.toPx() + underflow, DOM.Unit.Px)
                break
            case (false, false, true):
                marginRight = DOM.Value.Length(underflow, DOM.Unit.Px)
                break
            case (false, true, false):
                marginLeft = DOM.Value.Length(underflow, DOM.Unit.Px)
                break
            
            case (false, true, true):
                marginRight = DOM.Value.Length(underflow / 2.0, DOM.Unit.Px)
                marginLeft = DOM.Value.Length(underflow / 2.0, DOM.Unit.Px)
                break
            case (true, _, _):
                if marginLeft == auto { marginLeft = DOM.Value.Length(0, DOM.Unit.Px) }
                if marginRight == auto { marginRight = DOM.Value.Length(0, DOM.Unit.Px) }
                if underflow >= 0 {
                    width = DOM.Value.Length(underflow, DOM.Unit.Px)
                } else {
                    width = DOM.Value.Length(0, DOM.Unit.Px)
                    marginRight = DOM.Value.Length(marginRight.toPx() + underflow, DOM.Unit.Px)
                }
                break
            default:
                assert(false)
                break
            
            }
            
            self.dimensions.content.width = width.toPx()
            self.dimensions.margin.left = marginLeft.toPx()
            self.dimensions.margin.right = marginRight.toPx()
            self.dimensions.padding.left = paddingLeft.toPx()
            self.dimensions.padding.right = paddingRight.toPx()
            self.dimensions.border.left = borderLeft.toPx()
            self.dimensions.border.right = borderRight.toPx()
            
            
        }
        
        func calculateBlockPosition(containerBlock: Dimensions, neighborBlock: Dimensions) {
            let style = getStyleNode()
            let zero = DOM.Value.Length(0.0, DOM.Unit.Px)
            self.dimensions.margin.top = style.lookup("margin-top", fallbackName: "margin", defaultValue: zero).toPx()
            self.dimensions.margin.bottom = style.lookup("margin-bottom", fallbackName: "margin", defaultValue: zero).toPx()
            
            self.dimensions.border.top = style.lookup("border-top-width", fallbackName: "border-width", defaultValue: zero).toPx()
            self.dimensions.border.bottom = style.lookup("border-bottom-width", fallbackName: "border-width", defaultValue: zero).toPx()
            
            self.dimensions.padding.top = style.lookup("padding-top", fallbackName: "padding", defaultValue: zero).toPx()
            self.dimensions.padding.bottom = style.lookup("padding-bottom", fallbackName: "padding", defaultValue: zero).toPx()
            
            self.dimensions.content.x = 
                self.dimensions.margin.left
            
            self.dimensions.content.y =
                self.dimensions.margin.top + neighborBlock.borderBox().y + neighborBlock.borderBox().height + neighborBlock.margin.bottom
            
            
        }
        
        func layoutBlockChildren() {
            var lastestChildDimensions = Dimensions()
            for child in self.children {
                child.layout(self.dimensions, neighborBlock: lastestChildDimensions)
                self.dimensions.content.height += child.dimensions.marginBox().height
                lastestChildDimensions = child.dimensions
                
            }
        }
        
        func calculateBlockHeight(containerBlock: Dimensions) {
            let style = getStyleNode()
            
            switch style.value("height") {
            case .Some(DOM.Value.Length(let h, DOM.Unit.Px)):
                self.dimensions.content.height = h
                break
            default:
                break
            }
            
            
            
            
        }
    }
    
    class func layoutTree(node: StyledNode, containerBlock: Dimensions) -> LayoutBox {
        var container = containerBlock
        container.content.height = 0
        let rootBox = buildLayoutTree(node)
        rootBox.layout(container, neighborBlock: Dimensions())
        return rootBox
        
    }
    
    class func buildLayoutTree(node: StyledNode) -> LayoutBox {
        
        let boxType: BoxType?
        switch node.display() {
        case .Block:
            boxType = BoxType.BlockNode(node)
            break
        case .Inline:
            boxType = BoxType.InlineNode(node)
        case .None:
            boxType = BoxType.InlineNode(node)
        }
        
        let rootBox = LayoutBox(boxType: boxType!)
        
        for child in node.children {
            switch child.display() {
            case .Block:
                rootBox.children.append(buildLayoutTree(child))
                break
            case .Inline:
                let container = rootBox.getInlineContainer()
                container.children.append(buildLayoutTree(child))
                break
            case .None:
                break
            }
        }
        
        return rootBox
    }
}
