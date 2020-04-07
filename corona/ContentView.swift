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
    @State var kappaColor = Color.primary
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
                        Text(String(format: "%.4f", model.kappa))
                            .frame(width: 100)
                            .foregroundColor(kappaColor)
                        
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
                        Text(model.kappaSaturation ? String(format: "%.1f", model.activeSearchSaturation) : "unlimited").frame(width: 100)
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
                
                PlotInfectionRate(values: model.result, max: 0.6)
                    .border(Color.secondary.opacity(0.1)).padding()
                Text("Infection rate 0.7 ... 1.3").padding(.bottom)
                
            }
            List {
                Text("Intervention")
                Button(action: {
                    self.model.kappa = 0.0
                    self.model.lambda = 1.0
                    self.model.kappaSaturation = false
                    self.kappaColor = Color.primary
                    
                }, label: {
                    Text("Zero")
                })
                Button(action: {
                    self.model.kappa = 0.0
                    self.model.lambda = 0.55
                    self.model.kappaSaturation = false
                    self.kappaColor = Color.primary

                }, label: {
                    Text("IZP")
                })
                Button(action: {
                    self.model.kappa = 0.041
                    self.model.lambda = 0.7
                    self.model.activeSearchSaturation = 1000.0
                    self.kappaColor = Color.primary

                }, label: {
                    Text("Current")
                })
                Button(action: {
                    self.model.kappa = 0.1
                    self.model.lambda = 0.9
                    self.model.activeSearchSaturation = 1000.0
                    self.kappaColor = Color.primary

                }, label: {
                    Text("Economic")
                })
                Button(action: {
                    self.model.kappa = 0.1776
                    self.model.lambda = 1.0
                    self.model.activeSearchSaturation = 5000.0
                    self.model.kappaSaturation = true
                    self.kappaColor = Color.green

                }, label: {
                    Text("Ideal").foregroundColor(Color.green)
                })
                Button(action: {
                    self.model.kappa = 0.1775
                    self.model.lambda = 1.0
                    self.model.activeSearchSaturation = 5000.0
                    self.model.kappaSaturation = true
                    self.kappaColor = Color.orange

                }, label: {
                    Text("Disaster").foregroundColor(Color.orange)
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
