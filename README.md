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

Model zatiaľ pre riešenie používa dvojfázové riešenie, v prvej fáze je spočítaný SIR model pomocou RK4 (runge kutta 4), v druhej fáze je spozdenie pozitívne testovaných modelované eulerovou metódou, pričom pozitívne testovaní so spozdením 0 sú aktívne vyhladní hygienikmi (contact trecking) s pravdepodobnosťou kappa, so spozdením sú pozitívne testovaní infektovaní jedinci so symptomatickým priebehom infekcie (indikovaní pre testovanie lekárom)

TODO: https://github.com/op183/corona-SK-tools/blob/master/Delay-Differential_Equations_with_Constant_Lags.pdf može výpočet modelu spresniť aj zjednodušiť.

https://github.com/op183/corona-SK-tools/blob/master/Screenshot%202020-04-25%20at%2015.55.40.png.pdf

Veľmi inšpiratívny prístup s rovnakou ídeou sa objavil v Solvable delay model for epidemic spreading: the case of Covid-19 in Italy https://github.com/op183/corona-SK-tools/blob/master/2003.13571.pdf

Spresniť odhad kappa a základých "fixných pravdepodobností" pre-asymptomatických, asymptomatických a symptomatických prípadov v populácii je možné na základe https://github.com/op183/corona-SK-tools/blob/master/science.abb6936.full.pdf

Podstatné pre pochopenie šírenia epidémie https://github.com/op183/corona-SK-tools/blob/master/2003.12028.pdf
