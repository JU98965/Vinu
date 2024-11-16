//
//  ExpoterStatus.swift
//  Vinu
//
//  Created by 신정욱 on 11/17/24.
//

import UIKit

enum ExpoterStatus {
    case waiting
    case exporting(progress: Double)
    case completed
    case failed
    case cancelled
}
