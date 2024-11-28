//
//  PaddingUILabel.swift
//  Vinu
//
//  Created by 신정욱 on 9/20/24.
//

import UIKit

final class PaddingUILabel: UILabel {

    private let inset: UIEdgeInsets
    private var horizontalInset: CGFloat {
        inset.right + inset.left
    }
    private var verticalInset: CGFloat {
        inset.top + inset.bottom
    }
    
    // MARK: - Life Cycle
    init(padding: UIEdgeInsets) {
        self.inset = padding
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: inset))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        
        return CGSize(
            width: size.width + horizontalInset,
            height: size.height + verticalInset)
    }
    
    override var bounds: CGRect {
        didSet { preferredMaxLayoutWidth = bounds.width - (horizontalInset) }
    }
}
