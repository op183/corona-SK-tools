# corona-SK-tools
corona SK tools

Vizualizácia SIR modelu v SK

SIR model definuje

  <B>beta</B>
  
    pravdepodobnosť šírenia infekcie (0.4)

  <B>gamma</B>
  
    pravdepodobnosť imunizácie (1/6) (stredná doba šírenia infekcie)
    
  <B>kappa</B>
  
    pravdepodobnosť zachytenia infekčného jedinca aktívnym vyhľadávaním (stratégia hygienikov)
    
   <B>lambda</B>
   
    zníženie pravdepodobnosti šírenia infekcie plošnými opatreniami (aka "mobilita", rúška, zastavená výroba atď.)
    


Túto teóriu potvrdzuje aj článok ku ktorému som sa dnes dostal https://www.worldpop.org/events/COVID_NPI
Model a jeho správanie a závery ktoré z neho vyvodzujem sú veľmi podobné ako https://exchange.iseesystems.com/public/isee/covid-19-simulator/index.html#page1

ale najmä https://www.epicx-lab.com/uploads/9/6/9/4/9694133/inserm-covid-19_report_lockdown_idf-20200412.pdf kde parameter pa reprezentuje rovnaký typ intervencie ako kappa v mojom "toy modeli".

https://github.com/op183/corona-SK-tools/blob/master/corona/Screenshot%202020-04-19%20at%2012.01.16.png


Model zatiaľ pre riešenie používa dvojfázové riešenie, v prvej fáze je spočítaný SIR model pomocou RK4 (runge kutta 4), v druhej fáze je spozdenie pozitívne testovaných modelované eulerovou metódou, pričom pozitívne testovaní so spozdením 0 sú aktívne vyhladní hygienikmi (contact trecking) s pravdepodobnosťou kappa, so spozdením sú pozitívne testovaní infektovaní jedinci so symptomatickým priebehom infekcie.

TODO: https://github.com/op183/corona-SK-tools/blob/master/Delay-Differential_Equations_with_Constant_Lags.pdf može výpočet modelu spresniť aj zjednodušiť.
