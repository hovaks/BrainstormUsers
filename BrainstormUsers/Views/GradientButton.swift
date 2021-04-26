//
//  GradientButton.swift
//  BrainstormUsers
//
//  Created by Hovak Davtyan on 25.04.21.
//

import UIKit

final class GradientButton: UIButton {
    @IBInspectable var enabledStartColor: UIColor = .gradientEnabledStart { didSet { setColors() } }
    @IBInspectable var enabledEndColor: UIColor = .gradientEnabledEnd { didSet { setColors() } }
    @IBInspectable var disabledStartColor: UIColor = .gradientDisabled { didSet { setColors() } }
    @IBInspectable var disabledEndColor: UIColor = .gradientDisabled { didSet { setColors() } }

    override var isEnabled: Bool {
        didSet {
            guard oldValue != isEnabled else { return }
            setColors()
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setColors()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setColors()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setColors()
    }

    private func setColors() {
        let startColor = isEnabled ? enabledStartColor : disabledStartColor
        let endColor = isEnabled ? enabledEndColor : disabledEndColor
        applyLinerGradient(
            startColor: startColor, endColor: endColor,
            startPoint: .init(x: 0, y: 0.5), endPoint: .init(x: 1, y: 0.5)
        )
    }
}
