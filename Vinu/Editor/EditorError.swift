//
//  EditorError.swift
//  Vinu
//
//  Created by 신정욱 on 10/30/24.
//

import Foundation

enum EditorError: Error {
    case FailToGetElapsedTimeText(String)
    case selfDeallocated
}
