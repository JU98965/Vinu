//
//  CustomIntensityVisualEffectView.swift
//  Vinu
//
//  Created by 신정욱 on 11/5/24.
//

import UIKit

final class CustomIntensityVisualEffectView: UIVisualEffectView {
    // 나중에 초기화 해줘야 하는 친구
    private var animator: UIViewPropertyAnimator?

    init(effect: UIVisualEffect, intensity: CGFloat) {
        super.init(effect: nil)
        animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [unowned self] in self.effect = effect }
        animator?.fractionComplete = intensity
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
