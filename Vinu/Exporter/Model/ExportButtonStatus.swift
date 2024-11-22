//
//  ExportButtonStatus.swift
//  Vinu
//
//  Created by 신정욱 on 11/22/24.
//

import UIKit
import AVFoundation

struct ExportButtonStatus {
    // 내보내기 버튼이 두 번 눌리지 않도록 isHidden옵션이 필요함
    let isHidden: Bool
    let title: String
    
    init(expoterStatus: AVAssetExportSession.Status) {
        switch expoterStatus {
        case .exporting:
            self.isHidden = true
            self.title = ""
        case .completed, .failed:
            self.isHidden = false
            self.title = String(localized: "홈으로 돌아가기")
        case .cancelled:
            self.isHidden = false
            self.title = String(localized: "재시도")
        default:
            self.isHidden = false
            self.title = String(localized: "내보내기")
        }
    }
}
