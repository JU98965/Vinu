//
//  EditorVC+Alert.swift
//  Vinu
//
//  Created by 신정욱 on 11/26/24.
//

import UIKit

extension EditorVC {
    func alertPopThisView() {
        self.presentAlert(
            title: String(localized: "알림"),
            message: String(localized: "작업 내용을 잃고 홈 화면으로 돌아갈까요?"),
            acceptTask: {
                self.navigationController?.popViewController(animated: true)
            })
    }
}
