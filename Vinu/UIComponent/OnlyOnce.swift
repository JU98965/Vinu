//
//  OnlyOnce.swift
//  Vinu
//
//  Created by 신정욱 on 11/5/24.
//

import UIKit

/// 뷰를 구성하는 등의  단 한 번만 실행할 작업이 있을 때 사용하는 클래스
final class OnlyOnce {
    private var isExcuted = false
    
    func excute(_ excute: () -> Void) {
        guard !isExcuted else { return }
        isExcuted.toggle()
        excute()
    }
}
