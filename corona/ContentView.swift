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
    @State var day = 0
    @State var rateVisible = true
    
    var body: some View {
        HStack {
            VStack {
                HStack {
                    VStack {
                        Slider(value: $model.kappa, in: (0.0 ... 0.08), minimumValueLabel: Text("0").onTapGesture {
                                self.model.kappa -= 0.0001
                            if self.model.kappa < 0 {
                                self.model.kappa = 0
                            }
                            }, maximumValueLabel: Text("0.08").onTapGesture {
                                self.model.kappa += 0.0001
                                
                        }) {
                            Text("Kappa").frame(width: 150)
                        }
                        Text(String(format: "%.4f", model.kappa))
                            .frame(width: 100)
                            .foregroundColor(kappaColor)
                        
                        Slider(value: $model.activeSearchSaturation, in: (0.0 ... 10000.0), minimumValueLabel: Text("0").onTapGesture {
                            self.model.activeSearchSaturation -= 10
                            if self.model.activeSearchSaturation < 0 {
                                self.model.activeSearchSaturation = 0
                            }
                            }, maximumValueLabel: Text("10000.0").onTapGesture {
                                self.model.activeSearchSaturation += 10
                        }) {
                            Toggle("PCR Limit", isOn: $model.kappaSaturation)
                                .frame(width: 150)
                        }
                        HStack {
                            Text(model.kappaSaturation ? String(format: "%.1f (required testing capacity)", model.activeSearchSaturation) : "unlimited")
                            Spacer()
                            
                        }
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
                        
                        Slider(value: $model.icu, in: (0.0 ... 5000.0), minimumValueLabel: Text("0").onTapGesture {
                            self.model.icu -= 1
                            }, maximumValueLabel: Text("5000.0").onTapGesture {
                                self.model.icu += 1
                        }) {
                            //Text("ICU").frame(width: 150)
                            Toggle("ICU Limit", isOn: $model.icuSaturation)
                            .frame(width: 150)
                        }
                        HStack {
                            Text(model.icuSaturation ? String(format: "%.1f", model.icu) : "unlimited").frame(width: 100)
                            
                            Spacer()
                            
                            Stepper(onIncrement: {
                                self.day += 1
                            }, onDecrement: {
                                if self.day > 0 {
                                    self.day -= 1
                                }
                            }) {
                                Text("Day")
                            }
                            Stepper(onIncrement: {
                                self.day += 7
                            }, onDecrement: {
                                if self.day > 7 {
                                    self.day -= 7
                                }
                            }) {
                                Text("Week")
                            }
                        }
                        //Spacer()
                    }.frame(height: 100)
                    VStack {
                        Text("R0").font(.title)
                        Text("(kappa=0)").font(.footnote)
                        Text(model.R0)
                            .font(.title)
                            .frame(width: 80)
                        Spacer()
                        Spacer()
                        Button(action: {
                            let isoDate = "2020-03-06T00:00:00+0000"
                            let dateFormatter = ISO8601DateFormatter()
                            let ref = dateFormatter.date(from:isoDate)!
                            self.day = Calendar.current.dateComponents([.day], from: ref, to: Date()).day!
                        }) {
                            Text("Today")
                        }
                        
                    }.frame(height: 100)
                }
                .padding(.horizontal)
                .padding(.top)
                //Group {
                Plot(values: model.result, size: model.size, max: model.scale[model.scaleSelection], day: day)
                    .border(Color.secondary.opacity(0.1)).padding()
                
                Group {
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
                }.padding(.horizontal)
                
                if rateVisible {
                Group {
                    
                    PlotInfectionRate(values: model.result, max: 0.25, day: day)
                        .border(Color.secondary.opacity(0.1)).padding()
                    HStack {
                        Spacer()
                        Group {
                            Text("σ").font(.title).baselineOffset(5) + Text("\(self.model.latency)").baselineOffset(-5) + Text(" 0 ... 50").baselineOffset(7)
                        }.foregroundColor(.secondary)
                        Text("Active rate 0.875 ... 1.125").foregroundColor(.orange)
                        //Text("Morbidity 0 ... 10%")  removed from presentation due inacuracy
                        Spacer()
                        Text("Interverntion FIXED on day \(model.fixed ?? 0),")
                        Text("parameters predicted on day \(model.predicted ?? 0)")
                        Spacer()
                    }.padding(.bottom)
                }
                }
                
            }
            List {
                Text("Intervention")
                Button(action: {
                    self.model.kappa = 0.0
                    self.model.lambda = 1.0
                    //self.model.kappaSaturation = false
                    self.kappaColor = Color.primary
                    
                }, label: {
                    Text("Zero")
                })
                
                Button(action: {
                    self.model.kappa = 0.0
                    if let p = self.model.parameters.last {
                        self.model.lambda = p.lambdaISP
                    } else {
                        self.model.lambda = 0.55
                    }
                    //self.model.kappaSaturation = false
                    self.kappaColor = Color.primary
                    self.model.current = false

                }, label: {
                    Text("IZP")
                })
                Button(action: {
                    if let p = self.model.parameters.last {
                        self.model.kappa = p.kappa
                        self.model.lambda = p.lambda
                        //self.model.activeSearchSaturation = 450.0
                        //self.model.kappaSaturation = false
                        self.kappaColor = Color.primary
                    } else {
                        self.model.kappa = 0.0425
                        self.model.lambda = 0.7
                        //self.model.activeSearchSaturation = 450.0
                        self.kappaColor = Color.primary
                    }
                    self.model.current = true

                }, label: {
                    Text("Current").foregroundColor(self.model.current ? .green: nil)
                })
                
                
                
            }.frame(width: 100)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().frame(width: 400, height: 300, alignment: .center)
    }
}

// ui modification
