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
    
    var lambda: Double
    
    func dsdt(st: Double, it: Double) -> Double {
        -beta * st * it / population * lambda
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

struct Parameters {
    let day: Int
    let lambda: Double
    let lambdaISP: Double
    let kappa: Double
}

class SIRModel: ObservableObject {
    
    // covid "standart" SIR  parameters
    let beta = 0.4
    let gamma = 1.0 / 6.0
    var R0: String {
        String(format: "%.2f", beta * lambda / gamma)
    }
    
    let scale = [5000000.0, 3000000, 1000000.0, 500000, 300000, 100000, 50000, 30000, 10000, 5000, 3000, 1000]
    @Published var scaleSelection = 8
    
    let days = [500, 300, 200, 150, 100, 50] // number of steps from initial state
    @Published var daysSelection = 2
    
    // this parameters best fit current Slovak covid situation
    // initial state of model with
    let susceptible = 5500000.0
    let infectious = 220.0
    
    @Published var current = true
    // apply parameters (lambda, lambdaISP, kappa) BEFORE day
    //
    var parameters: [Parameters] = [Parameters(day: 6, lambda: 0.753, lambdaISP: 0.67, kappa: 0.0450), // fix (prve opatrenia) 0 ... 6
                                    Parameters(day: 19, lambda: 0.753, lambdaISP: 0.61, kappa: 0.0450), // fix (rúška)  6 ... 19
                                    Parameters(day: 32, lambda: 0.608, lambdaISP: 0.524, kappa: 0.0380), // fix 06/04 karantena 19 ... 32
                                    
                                    Parameters(day: 47, lambda: 0.578, lambdaISP: 0.468, kappa: 0.0477), // tmp ??? fix, uvolnenie 32 ... 47
        // pd dni 47 sa spustila 1. relaxacná fáza, odhad parametrov 0.667, 0.544, 0.045 založený na A(i)/A(i-1) cca 1.05 (5% denný nárast
        // bude možné spresniť za 14 dní
        //
        Parameters(day: 63, lambda: 0.667, lambdaISP: 0.544, kappa: 0.045),
        //
    ]
    
    var fixed: Int? {
        let i = parameters.count - 1
        return i < 0 ? nil : parameters[i].day
    }
    
    var predicted: Int? {
        let i = parameters.count - 2
        return i < 0 ? nil : parameters[i].day
    }
    
    @Published var lambda = 0.67 // social distance, has effect on whole population
    @Published var kappa = 0.045 // infectious quarantine effectivity, has effect on infected population
    @Published var activeSearchSaturation = 2000.0
    @Published var kappaSaturation = false
    @Published var icu = 1500.0
    @Published var icuSaturation = false
    
    let latency = 9 // odhad postavený na spodnej hranici intervalu prahu testovatelnosti + stredná doba imunizácie
    
    var size = 0
    
    func logisticMorbidity(indicated: Double, icu: Double) -> Double {
        // value << limit => value
        // value > limit => limit
        // k parameter
        let icu = icuSaturation ? icu : 10000
        // healt care efectivity koefficient (reduce morbidity with perfect healt care)
        // if value << limit
        // n = 0 ..... natural probability of death reduce by 100%
        // n = 1 ..... natural probability of death reduce by 50%
        // n = 10 .... natural probability of death reduce by 10%
        
        // if value >=limit, natural probability of death is not reduces anymore
        let a = 0.5 // probability of hospitality
        let b = 0.1 // reported natural morbidity without healt care
        let n = 0.05 // controls efektivity of healt care
        let p = pow(1.005, indicated * 0.1)
        let k = pow(1.005, icu * 1.4)
        let r = (p / (p + k) + n) / (1 + n)    // logistic function 0 if value << limit, 1 if value > limit
        return r * indicated * a * b
    }
    
    func solve() -> (susceptible: [Double], infectious: [Double], isolated: [Double], hospitalized: [Double], infectionrate: [Double], identified: [Double], death: [Double], sigma: [Double]) {
        var sir = SIR(susspectible: susceptible, infectious: infectious, recovered: 0, beta: beta, gamma: gamma, lambda: 1.15)
        // state <-> [susceptible, infectious]
        var state = [sir.state()]
        var infectionrate: [Double] = [0]
        var isolated: [Double] = [0]
        var hospitalized: [Double] = [0]
        var mortality: [Double] = [0.0]
        var death: [Double] = [0.0]
        var cases: [Double] = [0.0]
                
        var iterator = parameters.makeIterator()
        var p = iterator.next()
        var index = 0
        var _lambda = 1.0
        var _kappa = 0.0
        var Kappa = 0.0

        _ = (0 ..< days[daysSelection]).map { (i)  in
            
            if let p = p, i < p.day {
                //print(p.day, index)
                _lambda = current ? p.lambda : p.lambdaISP
                _kappa = current ? p.kappa : 0
            } else {
                
                if let _p = iterator.next() {
                    index += 1
                    p = _p
                    _lambda = current ? _p.lambda : _p.lambdaISP
                    _kappa = current ? _p.kappa : 0
                } else {
                    _lambda = lambda
                    _kappa = kappa
                }
            }
            
            let _s = state[i]
            var s_ = sir.next(state: _s)
            // update lambda
            // modeluje nábeh opatrení na obmedzenie social distance (latencia cca 14 dní)
            //if sir.lambda > _lambda {
                sir.lambda -= (sir.lambda - _lambda) * 0.33
            Kappa -= (Kappa - _kappa) * 0.33
            //}
            
            // a small proportion of infectious is identified and isolated by active screening and "massive" testing
            
            // malá časť infekčných je identifikovaná a izolovaná aktívnym vyhľadávaním a „masívnym“ testovaním
            // toto je, zdá sa, najefektívnejšia metôda, ktorá umožnuje zachovať vyššiu úroveň socialnych kontaktov
            // a teda menšie ekonomicke straty, alebo pri zachovaní súčastnej stratégie "obmedzenia mobility" podstatne znížiť
            // záťaž zdravotného systému.
            
            // model vykazuje značnú citlivosť na minimálne zmeny kappa a ukazuje že cieleným vyhľadávaním potenciálne
            // infikovaných a ich masívnym testovaním je možné sa epidémii brániť úspešnejšie, než znižovaním ekonomickej aktivyty
            
            // K dôkladnej analýze a fungovania aktívneho vyhľadávania na Slovensku (to má na starosti úrad hlavného hygienika)
            // by umožnila spresniť akýkoľvek odhad, ale s pravdepodobnosťou blížiacou sa istote je možné konštatovať, že
            // aj pri 100% účinnosti týchto postupov systém (nikde na svete) nedokáže odhaliť ani 20% šíriteľov. Berúc do úvahy aj ďalšie
            // parametre a štatistiky z nástupu pandémie inde vo sveten je možné regresnými metódami určiť že pri testovaní pacientov s klinický
            // príznakmi je možné spoľahlivosť vyhladávania v rôznych krajinách odhadovať od 0 do max 10%.
            
            // ako je možné, že aj pri 0% efektivite sa prípad infekcie dostane do štatistík? je to tým, že infikovaný pacient asi v 20%
            // skôr či neskôr musí vyhľadať zdravotú starostlivosť. V tom momente je testovaný a zároveň v izolácii.
            
            // to, že po povolení testovania aj samoplátcom sa pomer medzi pozitívne a nehgatívne testovamnými dnes u nás hýbe medzi
            // 1 a 2 %, je len dočasné a nie je spôsobené pozitívnym trendom, ale tým, že takíto "pacienti" neboli určení na základe
            // aktívneho vyhľadávania, ale z iniciatívy "pacientov".
            
            // akákoľvek dnes prijaté opatrenie sa prejaví so spozdením jeden až dva týždne.
            
            // model IZP aktívne vyhľadávanie neberie vôbec do úvahy, na druhej strane efektivita aktívneho vyhľadávania u nás predstavuje
            // odhadom asi 4%.
            
            // napriek tomu má na spomalenie šírenia zásadný význam, pretože vahľadáva pacientov "čerstvo" nakazených.
                        
            
            // parameter "activeSearchSaturation" predstavuje kapacitné možnosti hygienikov, na Slovenku je ju možné odhadnúť z počiatku inefcie
            // u nás, kde pri pomere nakazení / testovaní jeden deň dosiahla limitnú hranicu 10%, pri 40 tich pozitívnych indikáciaách,
            // z čoho je možné odhadnúť limit na približne 200 indikácií pri aktívnom vyhľadaní 2000 indikovaných pre testovanie. model umožnije tento parameter nastaviť v rozsahu 0 ... 5000
            // horná hranica je zvolená ako príklad Severnej Koreje a u nás by to pri dnešnom rozsahu prestavovalo asi 50 tisíc testov denne.
            
            // slovenská realita vykazuje na základ dát od začiatku epidémie kappa 4% a saturáciu 200, kappa sa s postupom pandémie príliš
            // meniť nebude pokiaľ by sa zachovala dnešná trajektória nárastu (cca 7% denne)
            
            
            // TODO  hard limit should be replaced with soft limiting funcion
            let det = min(s_[1] * Kappa, kappaSaturation ? activeSearchSaturation : susceptible)
            
            // 25% need special care, rest stay in home quarantine
            // + 10% of infectious with 3 days latency
            var l = 0.0
            if i > latency {
                l = state[i - latency][1] * 0.2
            }
            hospitalized.append(det * 0.25 + l)
            //if i == 32 {
            //    isolated.append(det + 60 * 6.5) // odchyt kolony na hranici pred velkou nocou
            //} else {
                isolated.append(det)
            //}
            
            // the rest stay in population and spread the infection
            //s_[1] *= 1 - kappa
            s_[1] -= det
            state.append(s_)
            infectionrate.append(s_[1]/_s[1])
        }
        size = state.count
        let identified = zip(isolated, hospitalized).map { (v) -> Double in
            max(v.0, v.1)
        }
        
        hospitalized[1...].enumerated().forEach { (v) in
            let c = cases[v.offset]
            cases.append(c + v.element)
        }
        
        mortality = state.map { (v) -> Double in
            let r = logisticMorbidity(indicated: v[1] * 0.08, icu: icu)
            return r
        }
        
        mortality[1...].enumerated().forEach { (v) in
            let ld = death[v.offset]
            death.append(ld + v.element)
        }
        
        
        return (susceptible: state.map {$0[0]}, infectious: state.map {$0[1]}, isolated: isolated, hospitalized: hospitalized, infectionrate: infectionrate, identified: identified, death: death, sigma: [])
    }
    
    var result: (susceptible: [Double], infectious: [Double], isolated: [Double], hospitalized: [Double], infectionrate: [Double], identified: [Double], death: [Double], sigma: [Double]) {
        var r = solve()
        var e2: [Double] = [0.0]
        for i in 1 ..< sk_rd.count {
            let _e2 = pow((r.identified[i] - sk_rd[i]), 2.0)
            e2.append(_e2)
        }
        var s: [Double] = [0.0]
        for i in 1 ..< e2.count {
            let j = max(i - latency, 0)
            let _s = sqrt(e2[j ... i].reduce(0.0, +) / Double(i))
            
            s.append(_s)
        }
        r.sigma = s
        return r
    }
}

// some mirror modification due to UI

