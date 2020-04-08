//
//  Plot.swift
//  corona
//
//  Created by Ivo Vacek on 02/04/2020.
//  Copyright © 2020 Ivo Vacek. All rights reserved.
//


// TODO need to be rewritten (structured and simplyfied)

import SwiftUI

struct Plot: View {
    let values: (susceptible: [Double], infectious: [Double], isolated: [Double], hospitalized: [Double], infectionrate: [Double], identified: [Double], mortality: [Double], mortalityRate: [Double])
    let size: Int
    let max: Double
    let isoDates = ["2020-04-01T00:00:00+0000",
                    "2020-05-01T00:00:00+0000",
                    "2020-06-01T00:00:00+0000",
                    "2020-07-01T00:00:00+0000",
                    "2020-08-01T00:00:00+0000",
                    "2020-09-01T00:00:00+0000",
                    "2020-10-01T00:00:00+0000",
                    "2020-11-01T00:00:00+0000",
                    "2020-12-01T00:00:00+0000",
                    "2021-01-01T00:00:00+0000"
    ]
    
    fileprivate func month(proxy: GeometryProxy, isoDates: [String]) -> Path {
        Path { (path) in
            var x = CGFloat.zero
            for isoDate in isoDates where x < proxy.size.width {
                let dateFormatter = ISO8601DateFormatter()
                let ref = dateFormatter.date(from: "2020-03-06T00:00:00+0000")!
                let to = dateFormatter.date(from: isoDate)!
                let days = Calendar.current.dateComponents([.day], from: ref, to: to).day!
                x = proxy.size.width / CGFloat(self.size - 1) * CGFloat(days)
                path.move(to: .init(x: x, y: 0))
                path.addLine(to: .init(x: x, y: proxy.size.height / 20))
            }
        }
    }
    
    func daysFrom(isoDate: String, date: Date) -> Int {
        let isoDate = "2020-03-06T00:00:00+0000"
        let dateFormatter = ISO8601DateFormatter()
        let ref = dateFormatter.date(from:isoDate)!
        return Calendar.current.dateComponents([.day], from: ref, to: date).day!
    }
    
    fileprivate func markday(proxy: GeometryProxy, day: Int, color: Color) -> some View {
        // april
        ZStack {
            Path { (path) in
                let x = proxy.size.width / CGFloat(self.size - 1) * CGFloat(day)
                path.move(to: .init(x: x, y: 0))
                path.addLine(to: .init(x: x, y: proxy.size.height))
            }.stroke(lineWidth: 0.5).foregroundColor(color)
        }
    }
    
    var body: some View {
        VStack {
            GeometryReader { proxy in
                ZStack {
                    
                    // x grid
                    Path { (path) in
                        let step = proxy.size.width / CGFloat(self.size - 1)
                        stride(from: CGFloat.zero, through: proxy.size.width, by: step * 7).forEach { (x) in
                            // pondelok
                            if x + 3 * step < proxy.size.width {
                            path.move(to: .init(x: x + 3 * step, y: 0))
                            path.addLine(to: .init(x: x + 3 * step, y: proxy.size.height))
                            }
                        }
                    }.stroke(lineWidth: 0.5).foregroundColor(Color.secondary)
 
                    // month marker
                    self.month(proxy: proxy, isoDates: self.isoDates).stroke(lineWidth: 5).foregroundColor(Color.green)
                    
                    // today marker
                    self.markday(proxy: proxy, day: self.daysFrom(isoDate: "2020-03-06T00:00:00+0000", date: Date()), color: .green)
                    
                    
                    // y grid
                    Path { (path) in
                        stride(from: CGFloat.zero, through: proxy.size.height, by: proxy.size.height / CGFloat(10)).forEach { (y) in
                            path.move(to: .init(x: 0, y: y))
                            path.addLine(to: .init(x: proxy.size.width, y: y))
                        }
                    }.stroke(lineWidth: 0.5).foregroundColor(Color.secondary)
                    
                    // infectious
                    Path { (path) in
                        path.move(to: .init(x: 0, y: proxy.size.height))
                        path.addLines(
                            self.values.infectious.enumerated().map({ (v) -> CGPoint in
                                CGPoint(x: Double(v.offset) * Double(proxy.size.width) / Double(self.size - 1), y: Double(proxy.size.height) - v.element * Double(proxy.size.height)/self.max)
                            })
                        )
                    }.stroke(lineWidth: 1).foregroundColor(Color.red)
                    
                    // early isolated
                    Path { (path) in
                        path.move(to: .init(x: 0, y: proxy.size.height))
                        path.addLines(
                            self.values.isolated.enumerated().map({ (v) -> CGPoint in
                                CGPoint(x: Double(v.offset) * Double(proxy.size.width) / Double(self.size - 1), y: Double(proxy.size.height) - v.element * Double(proxy.size.height)/self.max)
                            })
                        )
                    }.stroke(lineWidth: 1).foregroundColor(Color.blue)
                    
                    // hospitalized (not realy! it is infectious not early isolated)
                    
                    Path { (path) in
                        path.move(to: .init(x: 0, y: proxy.size.height))
                        path.addLines(
                            self.values.hospitalized.enumerated().map({ (v) -> CGPoint in
                                CGPoint(x: Double(v.offset) * Double(proxy.size.width) / Double(self.size - 1), y: Double(proxy.size.height) - v.element * Double(proxy.size.height)/self.max)
                            })
                        )
                    }.stroke(lineWidth: 1).foregroundColor(Color.orange)
                    
                    // identified
                    Path { (path) in
                        path.move(to: .init(x: 0, y: proxy.size.height))
                        path.addLines(
                            self.values.identified.enumerated().map({ (v) -> CGPoint in
                                CGPoint(x: Double(v.offset) * Double(proxy.size.width) / Double(self.size - 1), y: Double(proxy.size.height) - v.element * Double(proxy.size.height)/self.max)
                            })
                        )
                    }.stroke(Color.yellow, style: StrokeStyle.init(lineWidth: 1, lineCap: .square, lineJoin: .bevel, miterLimit: 0, dash: [10, 10], dashPhase: 0))
                    
                    // mortality
                    Path { (path) in
                        path.move(to: .init(x: 0, y: proxy.size.height))
                        path.addLines(
                            self.values.mortality.enumerated().map({ (v) -> CGPoint in
                                CGPoint(x: Double(v.offset) * Double(proxy.size.width) / Double(self.size - 1), y: Double(proxy.size.height) - v.element * Double(proxy.size.height)/self.max)
                            })
                        )
                    }.foregroundColor(Color.red.opacity(0.3))//.stroke(Color.red, style: StrokeStyle.init(lineWidth: 1, lineCap: .square, lineJoin: .bevel, miterLimit: 0, dash: [10, 10], dashPhase: 0))
                    
                    // susceptible
                    Path { (path) in
                        path.move(to: .init(x: 0, y: proxy.size.height))
                        path.addLines(
                            self.values.susceptible.enumerated().map({ (v) -> CGPoint in
                                CGPoint(x: Double(v.offset) * Double(proxy.size.width) / Double(self.size - 1), y: Double(proxy.size.height) - v.element * Double(proxy.size.height)/self.max)
                            })
                        )
                    }.stroke(lineWidth: 1).foregroundColor(Color.green)
                    
                }
            }
        }
    }
}


struct PlotInfectionRate: View {
    let values: (susceptible: [Double], infectious: [Double], isolated: [Double], hospitalized: [Double], infectionrate: [Double], identified: [Double], mortality: [Double], mortalityRate: [Double])
    let max: Double
    
    func daysFrom(isoDate: String, date: Date) -> Int {
        let isoDate = "2020-03-06T00:00:00+0000"
        let dateFormatter = ISO8601DateFormatter()
        let ref = dateFormatter.date(from:isoDate)!
        return Calendar.current.dateComponents([.day], from: ref, to: date).day!
    }
    
    fileprivate func markday(proxy: GeometryProxy, day: Int, color: Color) -> some View {
        // april
        ZStack {
            Path { (path) in
                let x = proxy.size.width / CGFloat(self.values.susceptible.count - 1) * CGFloat(day)
                path.move(to: .init(x: x, y: 0))
                path.addLine(to: .init(x: x, y: proxy.size.height))
            }.stroke(lineWidth: 0.5).foregroundColor(color)
        }
    }
    
    var body: some View {
        VStack {
            GeometryReader { proxy in
                ZStack {
                    // x grid
                    Path { (path) in
                        let step = proxy.size.width / CGFloat(self.values.susceptible.count - 1)
                        stride(from: CGFloat.zero, through: proxy.size.width, by: step * 7).forEach { (x) in
                            // pondelok
                            if x + 3 * step < proxy.size.width {
                                path.move(to: .init(x: x + 3 * step, y: 0))
                                path.addLine(to: .init(x: x + 3 * step, y: proxy.size.height))
                            }
                        }
                    }.stroke(lineWidth: 0.5).foregroundColor(Color.secondary)
                    
                    // today marker
                    self.markday(proxy: proxy, day: self.daysFrom(isoDate: "2020-03-06T00:00:00+0000", date: Date()), color: .green)
                    
                    // y grid
                    Path { (path) in
                        stride(from: CGFloat.zero, through: proxy.size.height, by: proxy.size.height / CGFloat(10)).forEach { (y) in
                            path.move(to: .init(x: 0, y: y))
                            path.addLine(to: .init(x: proxy.size.width, y: y))
                        }
                    }.stroke(lineWidth: 0.5).foregroundColor(Color.secondary)
                    
                    // ref line (ref == 1.0)
                    Path { (path) in
                        path.move(to: .init(x: 0, y: proxy.size.height / 2))
                        path.addLine(to: .init(x: proxy.size.width, y: proxy.size.height / 2))
                    }.stroke(Color.yellow, style: StrokeStyle.init(lineWidth: 0.5, lineCap: .square, lineJoin: .bevel, miterLimit: 0, dash: [10, 10], dashPhase: 0))
                    
                    // infectionrate
                    Path { (path) in
                        path.move(to: .init(x: 0, y: proxy.size.height))
                        let enumeration = self.values.infectionrate[1...].enumerated()
                        let points = enumeration.map({ (v) -> CGPoint in
                            CGPoint(x: Double(v.offset) * Double(proxy.size.width) / Double(self.values.infectionrate.count - 1), y: Double(proxy.size.height) - (v.element - 0.75) * Double(proxy.size.height)/self.max)
                        })
                            
                        path.addLines(points)
                    }.stroke(lineWidth: 1).foregroundColor(Color.pink)
                    
                    // mortality
                    Path { (path) in
                        let enumeration = self.values.mortalityRate.enumerated()
                        let v = enumeration.compactMap { (e) -> (Int, Double)? in
                            if (e.element == Double.infinity) || e.offset < 10 {
                                return nil
                            } else {
                                return e
                            }
                        }
                        let points = v.map({ (v) -> CGPoint in
                            CGPoint(x: Double(v.0) * Double(proxy.size.width) / Double(self.values.mortality.count - 1), y: Double(proxy.size.height) - (v.1) * Double(proxy.size.height) / 10)
                        })
                        
                        path.move(to: .init(x: 0, y: proxy.size.height))
                        path.addLines(points)
                    }.stroke(lineWidth: 1).foregroundColor(Color.primary)
                    
                }
            }
        }
    }
}
