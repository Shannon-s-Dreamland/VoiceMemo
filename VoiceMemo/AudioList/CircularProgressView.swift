//
//  CircularProgressView.swift
//  VoiceMemo
//
//  Created by Shannon Wu on 12/26/15.
//  Copyright © 2015 Shannon's Dreamland. All rights reserved.
//

import UIKit

@IBDesignable
class CircularProgressView: UIView {
    // MARK: Types

    enum Style {
        case Play
        case Pause
        case Stop
        
        func path(layerBounds: CGRect) -> CGPath {
            switch self {
            case .Play:
                let path = UIBezierPath()
                path.moveToPoint(CGPoint(x: layerBounds.width / 5, y: 0))
                path.addLineToPoint(CGPoint(x: layerBounds.width, y: layerBounds.height / 2))
                path.addLineToPoint(CGPoint(x: layerBounds.width / 5, y: layerBounds.height))
                path.closePath()
                return path.CGPath
            case .Pause:
                var rect = CGRect(origin: CGPoint(x: layerBounds.width * 0.1, y: 0), size: CGSize(width: layerBounds.width * 0.2, height: layerBounds.height))
                let path = UIBezierPath(rect: rect)
                rect.offsetInPlace(dx: layerBounds.width * 0.6, dy: 0)
                path.appendPath(UIBezierPath(rect: rect))
                return path.CGPath
            case .Stop:
                let insetBounds = CGRectInset(layerBounds, layerBounds.width / 6, layerBounds.width / 6)
                let path = UIBezierPath(rect: insetBounds)
                return path.CGPath
            }
        }
    }

    // MARK: Properties
    
    lazy var backgroundLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.lineWidth = self.lineWidth
        layer.strokeColor = self.backgroundLayerStrokeColor.CGColor
        self.layer.addSublayer(layer)
        
        return layer
    }()
    
    lazy var progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = nil
        layer.lineWidth = self.lineWidth
        layer.strokeColor = self.tintColor.CGColor
        self.layer.insertSublayer(layer, above: self.backgroundLayer)
        
        return layer
    }()
    
    lazy var iconLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = self.tintColor.CGColor
        self.layer.addSublayer(layer)
        
        return layer
    }()
    
    var iconStyle: Style = .Play {
        didSet {
            iconLayer.path = iconStyle.path(iconLayer.bounds)
        }
    }
    
    
    var iconLayerBounds: CGRect {
        return iconLayer.bounds
    }

    @IBInspectable var lineWidth: CGFloat = 3 {
        didSet {
            backgroundLayer.lineWidth = lineWidth
            progressLayer.lineWidth = lineWidth
        }
    }
    
    @IBInspectable var iconLayerFrameRatio: CGFloat = 0.4 {
        didSet {
            iconLayer.frame = iconLayerFrame(iconLayerBounds, ratio: iconLayerFrameRatio)
            iconLayer.path = iconStyle.path(iconLayerBounds)
        }
    }

    @IBInspectable var backgroundLayerStrokeColor: UIColor = UIColor(white: 0.8, alpha: 1) {
        didSet {
            backgroundLayer.strokeColor = backgroundLayerStrokeColor.CGColor
        }
    }
    
    @IBInspectable var progressLayerStrokeColor: UIColor? {
        didSet {
            progressLayer.strokeColor = progressLayerStrokeColor?.CGColor ?? tintColor.CGColor
        }
    }

    @IBInspectable var progress: CGFloat = 0.0 {
        didSet {
            progressLayer.strokeEnd = progress
        }
    }
    
    // MARK: Functions
    
    func setProgress(progress: CGFloat, animated: Bool = true) {
        if animated {
            self.progress = progress
        } else {
            self.progress = progress
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = progress
            animation.duration = 0.0
            progressLayer.addAnimation(animation, forKey: nil)
        }
    }
    
    func iconLayerFrame(rect: CGRect, ratio: CGFloat) -> CGRect {
        let insetRatio = (1 - ratio) / 2.0
        return CGRectInset(rect, CGRectGetWidth(rect) * insetRatio, CGRectGetHeight (rect) * insetRatio)
    }
    
    func getSquareLayerFrame(rect: CGRect) -> CGRect {
        if rect.width != rect.height {
            let width = min(rect.width, rect.height)
            
            let originX = (rect.width - width) / 2
            let originY = (rect.height - width) / 2
            
            return CGRectMake(originX, originY, width, width)
        }
        return rect
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let squareRect = getSquareLayerFrame(layer.bounds)
        backgroundLayer.frame = squareRect
        progressLayer.frame = squareRect
        
        let innerRect = CGRectInset(squareRect, lineWidth / 2.0, lineWidth / 2.0)
        iconLayer.frame = iconLayerFrame(innerRect, ratio: iconLayerFrameRatio)
        
        let center = CGPointMake(squareRect.width / 2.0, squareRect.height / 2.0)
        let path = UIBezierPath(arcCenter: center, radius: innerRect.width / 2.0, startAngle: CGFloat(-M_PI_2), endAngle: CGFloat(-M_PI_2 + 2.0 * M_PI), clockwise: true)
        backgroundLayer.path = path.CGPath
        progressLayer.path = path.CGPath
        iconLayer.path = iconStyle.path(iconLayerBounds)
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        iconStyle = .Play
    }
    
}
