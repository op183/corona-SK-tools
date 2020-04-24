//
//  Utility.swift
//  corona
//
//  Created by Ivo Vacek on 21/04/2020.
//  Copyright © 2020 Ivo Vacek. All rights reserved.
//

import Foundation

func factorial(n: Int) -> Double {
    if n < 1 { return 1.0 }
    return Double((1 ... n).reduce(1, *))
}

func probabilityDistribution(n: Int, p: Double) -> [Double] {
    if n < 0 { return [] }
    return (0 ... n).map { (i) -> Double in
        factorial(n: n) / factorial(n: i) / factorial(n: n - i) * pow(p, Double(i)) * pow(1 - p, Double(n - i))
    }
}

func latency(distribution: [Double], apply: () -> Double ) -> Double {
    apply()
}
