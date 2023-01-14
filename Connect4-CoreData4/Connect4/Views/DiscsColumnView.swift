//
//  DiscsColumnView.swift
//  Connect4
//
//  Created by Weimin Sun on 05/12/2022.
//

import UIKit
// The balls in each column are placed on this view

class DiscsColumnView: UIView {
    public var gravity = UIGravityBehavior()//Gravity effects
    public var collider = UICollisionBehavior()//Boundary collision effects
    public var animator: UIDynamicAnimator?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //gravity.angle = 2 Spin on descent
        self.animator = UIDynamicAnimator(referenceView: self)
        self.animator?.addBehavior(self.gravity)
        self.collider.translatesReferenceBoundsIntoBoundary =  true
        
        self.animator?.addBehavior(self.collider)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func addAnimationItem(discsView: DiscsView) {
        collider.addItem(discsView)
        gravity.addItem(discsView)
    }
    
    func removeAnimationItem(discsView: DiscsView) {
        collider.removeItem(discsView)
        gravity.removeItem(discsView)
    }
    
}
