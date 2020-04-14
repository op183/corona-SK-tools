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
