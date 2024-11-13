//
//  AVMutableVideoComposition.swift
//  Vinu
//
//  Created by 신정욱 on 11/13/24.
//

import AVFoundation

extension AVMutableVideoComposition {
    // 영상의 HDR 효과를 켜고 끄기
    func allowHDR(_ isAllowed: Bool) {
        if isAllowed {
            self.colorPrimaries = nil
            self.colorTransferFunction = nil
            self.colorYCbCrMatrix = nil
        } else {
            self.colorPrimaries = AVVideoColorPrimaries_ITU_R_709_2
            self.colorTransferFunction = AVVideoTransferFunction_ITU_R_709_2
            self.colorYCbCrMatrix = AVVideoYCbCrMatrix_ITU_R_709_2
        }
    }
}
