//
//  ContentView.swift
//  corona
//
//  Created by Ivo Vacek on 02/04/2020.
//  Copyright © 2020 Ivo Vacek. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var model = SIRModel()
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Slider(value: $model.kappa, in: (0.0 ... 0.1), minimumValueLabel: Text("0"), maximumValueLabel: Text("0.1")) {
                        Text("Kappa")
                    }
                    Text(String(format: "%.3f", model.kappa)).frame(width: 100)
                    Slider(value: $model.lambda, in: (0.0 ... 1.0), minimumValueLabel: Text("0"), maximumValueLabel: Text("1.0")) {
                        Text("Lambda")
                    }
                    Text("R0: \(model.R0)").frame(width: 100)
                }.padding(.horizontal)
                Plot(values: model.result.infectious, max: 1000000)
                    .border(Color.secondary.opacity(0.1)).padding()
                Text("x: 0 ... 200 days, y: 0 ... 1 milion cases) ").padding(.bottom, 5)
            }
            List {
                Text("Intervention")
                Button(action: {
                    self.model.kappa = 0.0
                    self.model.lambda = 1.0
                }, label: {
                    Text("Zero")
                })
                Button(action: {
                    self.model.kappa = 0.04
                    self.model.lambda = 0.7
                }, label: {
                    Text("Current")
                })
                Button(action: {
                    self.model.kappa = 0.1
                    self.model.lambda = 0.9
                }, label: {
                    Text("Economic")
                })
                Spacer()
            }.frame(width: 100)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().frame(width: 400, height: 300, alignment: .center)
    }
}
