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
    let values: (susceptible: [Double], infectious: [Double], isolated: [Double], hospitalized: [Double], infectionrate: [Double], identified: [Double], death: [Double], mortalityRate: [Double])
    let size: Int
    let max: Double
    let day: Int
    let isoDates = ["2020-04-01T00:00:00+0000",
                    "2020-05-01T00:00:00+0000",
                    "2020-06-01T00:00:00+0000",
                    "2020-07-01T00:00:00+0000",
                    "2020-08-01T00:00:00+0000",
                    "2020-09-01T00:00:00+0000",
                    "2020-10-01T00:00:00+0000",
                    "2020-11-01T00:00:00+0000",
                    "2020-12-01T00:00:00+0000",
                    "2021-01-01T00:00:00+0000",
                    "2021-02-01T00:00:00+0000",
                    "2021-03-01T00:00:00+0000",
                    "2021-04-01T00:00:00+0000",
                    "2021-05-01T00:00:00+0000",

    ]
    
    fileprivate func month(proxy: GeometryProxy, isoDates: [String]) -> some View {
        
        var xdays: [CGFloat] = []

        for isoDate in isoDates {
            let dateFormatter = ISO8601DateFormatter()
            let ref = dateFormatter.date(from: "2020-03-06T00:00:00+0000")!
            let to = dateFormatter.date(from: isoDate)!
            let days = Calendar.current.dateComponents([.day], from: ref, to: to).day!
            xdays.append(proxy.size.width / CGFloat(self.size - 1) * CGFloat(days))
        }
        let xdaysInRange = xdays.filter { (x) -> Bool in
            x < proxy.size.width
        }
        return ZStack {
            Path { (path) in
                for x in xdaysInRange {
                    path.move(to: .init(x: x, y: 0))
                    path.addLine(to: .init(x: x, y: proxy.size.height / 20))
                }
            }.stroke(lineWidth: 5).foregroundColor(Color.green)
            ForEach(0 ..< xdaysInRange.count) { (i) in
                Text("\((i + 3) % 12 + 1)")
                    .font(.system(size: 11, weight: .light, design: .monospaced))
                    .foregroundColor(Color.green)
                    .position(x: xdays[i], y:  -10)
            }
        }
    }
    
    func daysFrom(isoDate: String, date: Date) -> Int {
        let isoDate = "2020-03-06T00:00:00+0000"
        let dateFormatter = ISO8601DateFormatter()
        let ref = dateFormatter.date(from:isoDate)!
        return Calendar.current.dateComponents([.day], from: ref, to: date).day!
    }
    func date(offset: Int) -> String {
        let isoDate = "2020-03-06T00:00:00+0000"
        let dateFormatter = ISO8601DateFormatter()
        let ref = dateFormatter.date(from:isoDate)!
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: offset, to: ref)!
        let day = calendar.component(.day, from: date)
        return day.description
    }
    
    fileprivate func markday(proxy: GeometryProxy, day: Int, color: Color) -> some View {
        let x = proxy.size.width / CGFloat(self.size - 1) * CGFloat(day)
        return ZStack {
            Path { (path) in
                path.move(to: .init(x: x, y: 0))
                path.addLine(to: .init(x: x, y: proxy.size.height))
            }.stroke(lineWidth: 0.5).foregroundColor(color)
            
            Text(date(offset: day) + "(\(day))")
                .font(.system(size: 11, weight: .light, design: .monospaced))
                .foregroundColor(Color.green)
                .position(x: x, y:  proxy.size.height + 10)
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
                    self.month(proxy: proxy, isoDates: self.isoDates).id(UUID())
                    
                    // day marker
                    self.markday(proxy: proxy, day: self.day, color: .green)
                    //self.markday(proxy: proxy, day: self.daysFrom(isoDate: "2020-03-06T00:00:00+0000", date: Date()), color: .green)
                    
                    
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
                            self.values.death.enumerated().map({ (v) -> CGPoint in
                                CGPoint(x: Double(v.offset) * Double(proxy.size.width) / Double(self.size - 1), y: Double(proxy.size.height) - v.element * Double(proxy.size.height)/self.max)
                            })
                        )
                        path.addLine(to: .init(x: proxy.size.width, y: proxy.size.height))
                    }.foregroundColor(Color.red.opacity(0.3))//.stroke(Color.red, style: StrokeStyle.init(lineWidth: 1, lineCap: .square, lineJoin: .bevel, miterLimit: 0, dash: [10, 10], dashPhase: 0))
                    
                    Group {
                    // susceptible
                    Path { (path) in
                        path.move(to: .init(x: 0, y: proxy.size.height))
                        path.addLines(
                            self.values.susceptible.enumerated().map({ (v) -> CGPoint in
                                CGPoint(x: Double(v.offset) * Double(proxy.size.width) / Double(self.size - 1), y: Double(proxy.size.height) - v.element * Double(proxy.size.height)/self.max)
                            })
                        )
                    }.stroke(lineWidth: 1).foregroundColor(Color.green)
                    
                    
                    // real SK cases 
                    Path { (path) in
                        path.move(to: .init(x: 0, y: proxy.size.height))
                        path.addLines(
                            sk_rd.enumerated().map({ (v) -> CGPoint in
                                CGPoint(x: Double(v.offset) * Double(proxy.size.width) / Double(self.size - 1), y: Double(proxy.size.height) - v.element * Double(proxy.size.height)/self.max)
                            })
                        )
                    }.stroke(lineWidth: 1).foregroundColor(Color.primary)
                    }
                    
                }
            }
        }
    }
}


struct PlotInfectionRate: View {
    let values: (susceptible: [Double], infectious: [Double], isolated: [Double], hospitalized: [Double], infectionrate: [Double], identified: [Double], death: [Double], mortalityRate: [Double])
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
                    
                    // im
                    Path { (path) in
                        path.move(to: .init(x: 0, y: proxy.size.height))
                        let im = zip(self.values.identified, self.values.identified[1...]).map { v -> Double in
                            v.1 / v.0
                        }
                        let enumeration = im[14...].enumerated()
                        let points = enumeration.map({ (v) -> CGPoint in
                            CGPoint(x: Double(v.offset + 14) * Double(proxy.size.width) / Double(self.values.infectionrate.count - 1), y: Double(proxy.size.height) - (v.element - 0.75) * Double(proxy.size.height)/self.max)
                        })
                            
                        path.addLines(points)
                    }.stroke(lineWidth: 1).foregroundColor(Color.yellow)
                    
                    /*
                    // mortality
                    Path { (path) in
                        let enumeration = self.values.mortalityRate.enumerated()
                        let v = enumeration.compactMap { (e) -> (Int, Double)? in
                            if (e.element == Double.infinity) || e.offset < 14 {
                                return nil
                            } else {
                                return e
                            }
                        }
                        let points = v.map({ (v) -> CGPoint in
                            CGPoint(x: Double(v.0) * Double(proxy.size.width) / Double(self.values.death.count - 1), y: Double(proxy.size.height) - (v.1) * Double(proxy.size.height) / 10)
                        })
                        
                        path.move(to: .init(x: 0, y: proxy.size.height))
                        path.addLines(points)
                    }.stroke(lineWidth: 1).foregroundColor(Color.primary)
                    */
                }
            }
        }
    }
}


// sk data
let _sk_rd: [Double] = [
1,
3,
5,
7,
8.5,
10,
21,
32,
44,
61,
72,
97,
105,
123,
137,
178,
185,
204,
216,
226,
269,
292,
314 - 2,
336 - 2,
363 - 4,
400 - 4,
426 - 4,
450 - 6,
471 - 9,
485 - 9,
534 - 10,
581 - 10,
682 - 18,
701 - 25,
715 - 25,
728 - 25,
742 - 25,
769 - 31 - 0 * 76
]

// sk data, based on new total recovered
let sk_rd: [Double] = [
1,
3 - 0,
5 - 1,
7 - 1,
8.5 - 1,
10 - 1,
21 - 3,
32 - 4,
44 - 6,
61 - 8,
72 - 10,
97 - 13,
105 - 15,
123 - 17,
137 - 19,
178 - 25,
185 - 26,
204 - 38,
216 - 30,
226 - 31,
269 - 37,
292 - 41,
314 - 44,
336 - 47,
363 - 51,
400 - 56,
426 - 59,
450 - 63,
471 - 66,
485 - 57,
534 - 74,
581 - 81,
682 - 95,
701 - 98,
715 - 99,
728 - 101,
742 - 103,
769 - 107,
835 - 107,
863 - 113,
977 - 155,
]

