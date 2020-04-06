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
    //@State var max = [5000000.0, 1000000.0, 500000, 300000, 100000, 50000, 30000, 10000, 5000, 3000, 1000]
    //@State var sel = 1
    //@State var days = [300, 200, 100, 30]
    //@State var daysSel = 1
    var body: some View {
        HStack {
            VStack {
                
                HStack {
                    VStack {
                        Spacer()
                        Spacer()
                        Slider(value: $model.kappa, in: (0.0 ... 0.2), minimumValueLabel: Text("0").onTapGesture {
                            self.model.kappa -= 0.0001
                            if self.model.kappa < 0 {
                                self.model.kappa = 0
                            }
                            }, maximumValueLabel: Text("0.2").onTapGesture {
                                self.model.kappa += 0.0001
                                
                        }) {
                            Text("Kappa").frame(width: 150)
                        }
                        Text(String(format: "%.4f", model.kappa)).frame(width: 100)
                        
                        Slider(value: $model.activeSearchSaturation, in: (0.0 ... 5000.0), minimumValueLabel: Text("0").onTapGesture {
                            self.model.activeSearchSaturation -= 1
                            if self.model.activeSearchSaturation < 0 {
                                self.model.activeSearchSaturation = 0
                            }
                            }, maximumValueLabel: Text("5000.0").onTapGesture {
                                self.model.activeSearchSaturation += 1
                        }) {
                            Toggle("Kappa saturation", isOn: $model.kappaSaturation)
                            //Text("Kappa saturation").frame(width: 150)
                        }
                        Text(String(format: "%.1f", model.activeSearchSaturation)).frame(width: 100)
                    }.frame(height: 100)
                    VStack {
                        Slider(value: $model.lambda, in: (0.0 ... 1.2), minimumValueLabel: Text("0").onTapGesture {
                            self.model.lambda -= 0.001
                            }, maximumValueLabel: Text("1.2").onTapGesture {
                                self.model.lambda += 0.001
                        }) {
                            Text("Lambda").frame(width: 150)
                        }
                        Text(String(format: "%.3f", model.lambda)).frame(width: 100)
                        Spacer()
                    }.frame(height: 100)
                    Text("R0: \(model.R0)").frame(width: 100)
                }.padding(.horizontal)
                
                Plot(values: model.result, max: model.scale[model.scaleSelection] /*max[sel]*/)
                    .border(Color.secondary.opacity(0.1)).padding()
                //Text("x: 0 ... 200 days, y: 0 ... 1 milion cases) ").padding(.bottom, 5)
                Picker(selection: $model.scaleSelection, label: Text("Population x 10000").frame(width: 200)) {
                    ForEach(0 ..< model.scale.count) { (i) in
                        Text(String(format: "%.1f", self.model.scale[i]/10000.0)).tag(i)
                    }
                }.pickerStyle(SegmentedPickerStyle())
                Picker(selection: $model.daysSelection, label: Text("Days from 06/03/2020").frame(width: 200)) {
                    ForEach(0 ..< model.days.count) { (i) in
                        Text("\(self.model.days[i])").tag(i)
                    }
                }.pickerStyle(SegmentedPickerStyle())
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
                    self.model.kappa = 0.0
                    self.model.lambda = 0.55
                }, label: {
                    Text("IZP")
                })
                Button(action: {
                    self.model.kappa = 0.041
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
