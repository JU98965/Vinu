//
//  UIColor.swift
//  Vinu
//
//  Created by 신정욱 on 10/1/24.
//


import UIKit

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hex & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hex & 0xff) >> 0) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    static var chuLightGray: UIColor {
        UIColor(hex: 0xEBEBEB)
    }
    
    static var backWhite: UIColor {
        UIColor(hex: 0xF8F8F8)
    }
    
    static var textGray: UIColor {
        UIColor(hex: 0x767A80)
    }
    
    static var tintBlue: UIColor {
        UIColor(hex: 0x7AACF9)
    }
}
