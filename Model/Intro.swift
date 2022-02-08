//
//  Intro.swift
//  LiquidSwipeSwiftBook
//
//  Created by Эдуард on 07.02.2022.
//

import SwiftUI

struct Intro: Identifiable {
    var id = UUID().uuidString
    var title: String
    var subTitle: String
    var description: String
    var pic: String
    var color: Color
    var offset: CGSize = .zero
}
