//
//  Plot.swift
//  corona
//
//  Created by Ivo Vacek on 02/04/2020.
//  Copyright © 2020 Ivo Vacek. All rights reserved.
//

import SwiftUI

struct Plot: View {
    let values: (susceptible: [Double], infectious: [Double], isolated: [Double], hospitalized: [Double], infectionrate: [Double])
    let max: Double
    
    var body: some View {
        VStack {
            GeometryReader { proxy in
                ZStack {
                    // x grid
                    Path { (path) in
                        let step = proxy.size.width / CGFloat(self.values.susceptible.count - 1)
                        stride(from: CGFloat.zero, through: proxy.size.width, by: step * 7).forEach { (x) in
                            // piatok
                            path.move(to: .init(x: x, y: 0))
                            path.addLine(to: .init(x: x, y: proxy.size.height))
                            // nedela
                            path.move(to: .init(x: x + 2 * step, y: 0))
                            path.addLine(to: .init(x: x + 2 * step, y: proxy.size.height))
                        }
                    }.stroke(lineWidth: 0.2).foregroundColor(Color.secondary)
                    
                    // today
                    Path { (path) in
                        let isoDate = "2020-03-06T00:00:00+0000"
                        let dateFormatter = ISO8601DateFormatter()
                        let ref = dateFormatter.date(from:isoDate)!
                        let days = Calendar.current.dateComponents([.day], from: ref, to: Date()).day!
                        let x = proxy.size.width / CGFloat(self.values.susceptible.count - 1) * CGFloat(days)
                        
                        path.move(to: .init(x: x, y: 0))
                        path.addLine(to: .init(x: x, y: proxy.size.height))
                    }.stroke(lineWidth: 0.5).foregroundColor(Color.green)
                    
                    // y grid
                    Path { (path) in
                        stride(from: CGFloat.zero, through: proxy.size.height, by: proxy.size.height / CGFloat(10)).forEach { (y) in
                            path.move(to: .init(x: 0, y: y))
                            path.addLine(to: .init(x: proxy.size.width, y: y))
                        }
                    }.stroke(lineWidth: 0.2).foregroundColor(Color.secondary)
                    
                    // infectious
                    Path { (path) in
                        path.move(to: .init(x: 0, y: proxy.size.height))
                        path.addLines(
                            self.values.infectious.enumerated().map({ (v) -> CGPoint in
                                CGPoint(x: Double(v.offset) * Double(proxy.size.width) / Double(self.values.infectious.count - 1), y: Double(proxy.size.height) - v.element * Double(proxy.size.height)/self.max)
                            })
                        )
                    }.stroke(lineWidth: 1).foregroundColor(Color.red)
                    
                    // early isolated
                    Path { (path) in
                        path.move(to: .init(x: 0, y: proxy.size.height))
                        path.addLines(
                            self.values.isolated.enumerated().map({ (v) -> CGPoint in
                                CGPoint(x: Double(v.offset) * Double(proxy.size.width) / Double(self.values.isolated.count - 1), y: Double(proxy.size.height) - v.element * Double(proxy.size.height)/self.max)
                            })
                        )
                    }.stroke(lineWidth: 1).foregroundColor(Color.blue)
                    
                    // hospitalized
                    
                    Path { (path) in
                        path.move(to: .init(x: 0, y: proxy.size.height))
                        path.addLines(
                            self.values.hospitalized.enumerated().map({ (v) -> CGPoint in
                                CGPoint(x: Double(v.offset) * Double(proxy.size.width) / Double(self.values.hospitalized.count - 1), y: Double(proxy.size.height) - v.element * Double(proxy.size.height)/self.max)
                            })
                        )
                    }.stroke(lineWidth: 1).foregroundColor(Color.orange)
                    
                    // susceptible
                    Path { (path) in
                        path.move(to: .init(x: 0, y: proxy.size.height))
                        path.addLines(
                            self.values.susceptible.enumerated().map({ (v) -> CGPoint in
                                CGPoint(x: Double(v.offset) * Double(proxy.size.width) / Double(self.values.susceptible.count - 1), y: Double(proxy.size.height) - v.element * Double(proxy.size.height)/self.max)
                            })
                        )
                    }.stroke(lineWidth: 1).foregroundColor(Color.green)
                    
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
