//
//  TileShader.swift
//  Papyrus
//
//  Created by Chris Nevin on 25/02/2016.
//  Copyright © 2016 CJNevin. All rights reserved.
//

import UIKit
import PapyrusCore

struct TileShader : Shader {
    var fillColor: UIColor?
    var textColor: UIColor?
    var strokeColor: UIColor?
    var strokeWidth: CGFloat?
    init(tile: Character, points: Int, highlighted: Bool) {
        // Based on state of tile, render differently.
        if highlighted {
            fillColor = .tileIlluminatedColor
        } else {
            fillColor = .tileColor
        }
        textColor = (points == 0 ? .grayColor() : .blackColor())
        strokeColor = .tileBorderColor
        strokeWidth = 0.5
    }
}