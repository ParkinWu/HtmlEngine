//
//  Printer.swift
//  HtmlEngine
//
//  Created by pzwu on 16/8/4.
//  Copyright © 2016年 pzwu. All rights reserved.
//

import UIKit

class Printer: NSObject {
    class func printLayoutBox(layoutBox: Layout.LayoutBox, containerView: UIView) {
        let thisView =  printView(layoutBox, containerView: containerView)
        printChildLayoutBox(layoutBox.children, containerView: thisView)
    }
    
    class func printView(layoutBox: Layout.LayoutBox, containerView: UIView) -> UIView {
        let view = UIView(frame: CGRectZero)
        containerView.addSubview(view)
        
        layoutView(layoutBox.dimensions, view: view)
        
        let style = layoutBox.getStyleNode()
        styleView(style, view: view)
        return view
    }
    class func layoutView(dimension: Layout.Dimensions, view: UIView) {        
        view.frame = CGRectMake(CGFloat(dimension.content.x), CGFloat(dimension.content.y), CGFloat(dimension.content.width), CGFloat(dimension.content.height))
    }
    class func styleView(styleNode: StyledNode, view: UIView) {
        let color = styleNode.value("background-color").unwrapOr(DOM.Value.ColorValue(DOM.Color(r: 255, g: 255, b: 255, a: 255)))
        setColor(color, view: view)
    }
    class func setColor(value: DOM.Value, view: UIView) {
        switch value {
        case .ColorValue(let color):
            view.backgroundColor = UIColor(red: CGFloat(color.r), green: CGFloat(color.g), blue: CGFloat(color.b), alpha: CGFloat(color.a))
            break
        default:
            break
        }
    }
    class func printChildLayoutBox(children: [Layout.LayoutBox], containerView: UIView) {
        for child in children {
            printLayoutBox(child, containerView: containerView)
        }
    }
}
