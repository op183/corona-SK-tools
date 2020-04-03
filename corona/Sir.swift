//
//  Sir.swift
//  corona
//
//  Created by Ivo Vacek on 02/04/2020.
//  Copyright © 2020 Ivo Vacek. All rights reserved.
//

import Foundation

protocol Rk4 {
    typealias State = [Double]
    func dsdt(_ state: State) -> State
    func state() -> State
}

extension Rk4 {
    // runge kutta 4 order default implementation
    func next(state: State) -> State {
        let s = state
        let k1 = dsdt(state)
        let k2 = dsdt(zip(s, k1).map { (s,k) in
            s + 0.5 * k
        })
        let k3 = dsdt(zip(s, k2).map { (s,k) in
            s + 0.5 * k
        })
        let k4 = dsdt(zip(s, k3).map { (s,k) in
            s + k
        })
        return s.indices.map { (i) -> Double in
            s[i] + 1.0 / 6.0 * (k1[i] + 2 * k2[i] + 2 * k3[i] + k4[i])
        }
    }
}

struct SIR: Rk4 {
    
    let susspectible: Double
    let infectious: Double
    let recovered: Double
    var population: Double {
        susspectible + infectious + recovered
    }
    
    let beta: Double
    let gamma: Double
    
    func dsdt(st: Double, it: Double) -> Double {
        -beta * st * it / population
    }
    
    func didt(st: Double, it: Double) -> Double {
        -dsdt(st: st, it: it) - gamma * it
    }
    
    // SIR model vector differencial required by default RK4 solver
    func dsdt(_ state: State) -> State {
        let ds = dsdt(st: state[0], it: state[1])
        let di = didt(st: state[0], it: state[1])
        return [ds, di]
    }
    
    func state() -> State {
        [susspectible, infectious]
    }
}


class SIRModel: ObservableObject {
    
    // covid "standasrt" parameters
    let beta = 0.4
    let gamma = 1.0 / 6.0
    var R0: String {
        String(format: "%.2f", beta * lambda / gamma)
    }
    
    let days = 200 // number of steps from initial state
    
    // this parameters best fit current Slovak covid situation
    // initial state of model with
    let susceptible = 5500000.0
    let infectious = 3000.0
    @Published var lambda = 0.7 // social distance, has effect on whole population
    @Published var kappa = 0.04 // infectious quarantine effectivity, has effect on infected population
    
    func solve() -> (susceptible: [Double], infectious: [Double], isolated: [Double], hospitalized: [Double], infectionrate: [Double]) {
        let sir = SIR(susspectible: susceptible, infectious: infectious, recovered: 0, beta: beta * lambda, gamma: gamma)
        // state <-> [susceptible, infectious]
        var state = [sir.state()]
        var infectionrate: [Double] = []
        var isolated: [Double] = []
        var hospitalized: [Double] = []
        
        _ = (0 ..< days).map { (i)  in
            let _s = state[i]
            var s_ = sir.next(state: _s)
            
            // a small proportion of infectious is identified and isolated by active screening and "massive" testing
            
            // malá časť infekčných je identifikovaná a izolovaná aktívnym vyhľadávaním a „masívnym“ testovaním
            // toto je, zdá sa, najefektívnejšia metôda, ktorá umožnuje zachovať vyššiu úroveň socialnych kontaktov
            // a teda menšie ekonomicke straty, alebo pri zachovaní súčastnej stratégie "obmedzenia mobility" podstatne znížiť
            // záťaž zdravotného systému.
            
            // model vykazuje značnú citlivosť na minimálne zmeny kappa a ukazuje že cieleným vyhľadávaním potenciálne
            // infikovaných a ich masívnym testovaním je možné sa epidémii brániť úspešnejšie, než znižovaním ekonomickej aktivyty
            
            
            isolated.append(s_[1] * kappa)
            // 25% need special care, rest stay in home quarantine
            hospitalized.append(isolated[i] * 0.25)
            
            
            // the rest stay in population and spread the infection
            s_[1] *= 1 - kappa
            state.append(s_)
            infectionrate.append(s_[1]/_s[1])
        }
        return (susceptible: state.map {$0[0]}, infectious: state.map {$0[1]}, isolated: isolated, hospitalized: hospitalized, infectionrate: infectionrate)
    }
    
    var result: (susceptible: [Double], infectious: [Double], isolated: [Double], hospitalized: [Double], infectionrate: [Double]) {
        solve()
    }
}


