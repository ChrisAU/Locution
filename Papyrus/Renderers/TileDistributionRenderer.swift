//
//  TileDistributionRenderer.swift
//  Papyrus
//
//  Created by Chris Nevin on 14/05/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit
import PapyrusCore

struct TileDistributionRenderer {
    private let inset: CGFloat = 5
    private let perRow: Int = 7
    private let padding: CGFloat = 4
    
    var tileViews: [TileView]?
    var shapeLayer: CAShapeLayer?
    
    mutating func render(inView view: UIView, filterBlank: Bool = true, distribution: LetterDistribution, delegate: TileViewDelegate? = nil) {
        shapeLayer?.removeFromSuperlayer()
        tileViews?.forEach({ $0.removeFromSuperview() })
        
        let containerRect = CGRectInset(view.bounds, inset, inset)
        let tileSize = ceil(containerRect.size.width / CGFloat(perRow))
        let sorted = distribution.letterPoints.sort({ $0.0 < $1.0 })
        let tiles = filterBlank ? sorted.filter({ $0.0 != Bag.blankLetter }) : sorted
        let lastRow = Int(tiles.count / perRow)
        let path = UIBezierPath()
        tileViews = tiles.enumerate().map { (index, value) -> TileView in
            let row = index > 0 ? Int(index / perRow) : 0
            let col = index - row * perRow
            var x = CGFloat(col) * tileSize + padding / 2
            if lastRow == row {
                x += CGFloat(perRow * (lastRow + 1) - tiles.count) * tileSize / 2
            }
            let tileRect = CGRect(
                x: inset + x,
                y: inset + CGFloat(row) * tileSize + padding / 2,
                width: tileSize - padding,
                height: tileSize - padding)
            
            let pathRect = CGRectInset(tileRect, -padding, -padding)
            let radii = CGSize(width: inset, height: inset)
            if row == 0 && col == 0 {
                path.appendPath(UIBezierPath(roundedRect: pathRect, byRoundingCorners: .TopLeft, cornerRadii: radii))
            } else if row == 0 && col == perRow - 1 {
                path.appendPath(UIBezierPath(roundedRect: pathRect, byRoundingCorners: .TopRight, cornerRadii: radii))
            } else if (row == lastRow && col == 0) {
                path.appendPath(UIBezierPath(roundedRect: pathRect, byRoundingCorners: .BottomLeft, cornerRadii: radii))
            } else if (row == lastRow - 1 && col == 0) {
                path.appendPath(UIBezierPath(roundedRect: pathRect, byRoundingCorners: .BottomLeft, cornerRadii: radii))
            } else if (row == lastRow && index == tiles.count - 1) || (row == lastRow - 1 && col == perRow - 1) {
                path.appendPath(UIBezierPath(roundedRect: pathRect, byRoundingCorners: .BottomRight, cornerRadii: radii))
            } else {
                path.appendPath(UIBezierPath(rect: pathRect))
            }
            return TileView(frame: tileRect, tile: value.0, points: 0, onBoard: false, delegate: delegate)
        }
        
        let shape = CAShapeLayer()
        shape.path = path.CGPath
        shape.fillColor = UIColor.whiteColor().colorWithAlphaComponent(0.6).CGColor
        shape.shadowOffset = CGSize(width: 1, height: 1)
        shape.shadowColor = UIColor.blackColor().CGColor
        shape.shadowOpacity = 0.3
        shape.shadowRadius = 4
        view.backgroundColor = .clearColor()
        view.layer.addSublayer(shape)
        shapeLayer = shape
        
        tileViews?.forEach({ tileView in
            view.addSubview(tileView)
        })
    }
}