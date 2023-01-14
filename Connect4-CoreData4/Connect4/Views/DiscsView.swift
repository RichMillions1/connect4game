//
//  BubbleView.swift
//  Connect4
//
//  Created by Weimin Sun on 05/12/2022.
//

import UIKit

class DiscsView: UIView {
    var column: Int
    init(frame: CGRect, borderColor: UIColor, contentColor: UIColor, text: String, column:Int = 1) {
        self.column = column
        super.init(frame: frame)
        backgroundColor = .clear
//        layer.cornerRadius = frame.size.width / 2.0
//        layer.borderColor = UIColor.black.cgColor
//        layer.borderWidth = 10
        let lineWidth: CGFloat = 5
        let maskPath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width/2.0, y: frame.size.width/2.0), radius: frame.size.width/2.0 - lineWidth, startAngle: 0, endAngle: Double.pi * 2, clockwise: true)
        let shapeLayer = CAShapeLayer()
        //mask.fillRule = .evenOdd
        shapeLayer.strokeColor = borderColor.cgColor //Round border colour
        shapeLayer.fillColor = contentColor.cgColor // Colour of the centre of the circle
        shapeLayer.lineWidth = lineWidth
        shapeLayer.path = maskPath.cgPath
        self.layer.addSublayer(shapeLayer)
       
        let label = UILabel()
        label.frame = self.bounds
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.text = text
        self.addSubview(label)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
 
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .ellipse
    }

}
