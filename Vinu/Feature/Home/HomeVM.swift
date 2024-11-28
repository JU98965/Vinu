//
//  HomeVM.swift
//  Vinu
//
//  Created by 신정욱 on 9/18/24.
//

import Foundation
import RxSwift

final class HomeVM {
    private let bag = DisposeBag()

    struct Input {
        let tapNewProjectButton: Observable<Void>
    }
    
    struct Output {
        let presentPickerVC: Observable<Void>
    }

    func transform(input: Input) -> Output {
        return Output(presentPickerVC: input.tapNewProjectButton)
    }
}
