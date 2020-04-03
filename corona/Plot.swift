//
//  Plot.swift
//  corona
//
//  Created by Ivo Vacek on 02/04/2020.
//  Copyright © 2020 Ivo Vacek. All rights reserved.
//

import SwiftUI

struct Plot: View {
    let values: [Double]
    let max: Double
    
    var body: some View {
        VStack {
            GeometryReader { proxy in
                ZStack {
                    // x grid
                    Path { (path) in
                        stride(from: CGFloat.zero, through: proxy.size.width, by: proxy.size.width / CGFloat((self.values.count - 1) / 10)).forEach { (x) in
                            path.move(to: .init(x: x, y: 0))
                            path.addLine(to: .init(x: x, y: proxy.size.height))
                        }
                    }.stroke(lineWidth: 0.2).foregroundColor(Color.secondary)
                    
                    // y grid
                    Path { (path) in
                        stride(from: CGFloat.zero, through: proxy.size.height, by: proxy.size.height / CGFloat(10)).forEach { (y) in
                            path.move(to: .init(x: 0, y: y))
                            path.addLine(to: .init(x: proxy.size.width, y: y))
                        }
                    }.stroke(lineWidth: 0.2).foregroundColor(Color.secondary)
                    
                    Path { (path) in
                        path.move(to: .init(x: 0, y: proxy.size.height))
                        path.addLines(
                            self.values.enumerated().map({ (v) -> CGPoint in
                                CGPoint(x: Double(v.offset) * Double(proxy.size.width) / Double(self.values.count - 1), y: Double(proxy.size.height) - v.element * Double(proxy.size.height)/self.max)
                            })
                        )
                    }.stroke(lineWidth: 1).foregroundColor(Color.red)
                }
            }
        }
    }
}


struct Plot_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
