//
//  UIView+Extensions.swift
//  BrainstormUsers
//
//  Created by Hovak Davtyan on 24.04.21.
//

import UIKit

extension UIView {
    var cornerRadius: CGFloat {
        get { layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    func applyLinerGradient(
        startColor: UIColor,
        endColor: UIColor,
        startPoint: CGPoint,
        endPoint: CGPoint
    ) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [startColor, endColor].map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        if let currentGradient = layer.sublayers?[0] as? CAGradientLayer {
            layer.replaceSublayer(currentGradient, with: gradientLayer)
        } else {
            layer.insertSublayer(gradientLayer, at: 0)
        }
    }
}
