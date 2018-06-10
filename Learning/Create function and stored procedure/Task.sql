
/*
	Utwórz funkcjê, która zwróci koszt zamówienia wyliczony jako œrednia wartoœæ wszystich produktów jakiego dotyczy zamówienie.
	
	Nazwij funkcjê: dbo.ufnGetTotalCosts

	Na przyk³ad jeœli zamówienie o id 100 ma 5 produktów to wynikiem funkcji ma byæ skalarna wartoœæ - œrednia wszystkich 5 produktów 
	(kolumna ListPrice w tabeli Production.Product).

	Przyk³ady poprawnych wyników funkcji dla kilku SalesOrderID
	SalesOrderID	TotalCosts
		43697		3578,27
		43698		3399,99
		43700		782,99

	Funkcja powinna zwróciæ wartoœæ o typie MONEY
*/

/*
	Napisz procedurê sk³adowan¹, która wykona nastêpuj¹ce czynnoœci:

	1. Dodanie nowej kolumny do tabeli Sales.SalesOrderHeader o nazwie TotalCosts z typem MONEY
	2. Kolumna mo¿e przyj¹æ tylko wartoœci wiêksze od 0
	3. Procedura ma siê wykonaæ z jednym parametrem: SalesOrderID z typem INT
	4. Po dodaniu kolumny do tabeli ma siê zaktualizowaæ wiersz TotalCosts jako wykonanie fukncji dbo.ufnGetTotalCosts
	5. Na koñcu procedura ma wyœwietliæ zaktualizowany wiersz:
		
		Kolumny w zestawieniu:
			- SalesOrderId
			- TotalCosts
		
	
UWAGA!
	1. Procedura ma w sobie operacjê DDL, wiêc nale¿y pamiêtaæ, ¿e wykonanie procedury po raz X zwróci b³¹d
		,poniewa¿ nie mo¿emy za ka¿dym razem dodawaæ nowej kolumny o takiej samej nazwie do tej samej tabeli.
	2. Procedura powinna obs³u¿yæ ten przypadek. Moja propozycja 2 rozwi¹zañ:
		2a. Przed dodaniem kolumny usun¹æ kolumnê jeœli istnieje - jest jedna konstrukcja do tego typu operacji ( DROP COLUMN IF EXISTS )
			UWAGA! zadzia³a tylko w wersji >= 2016
		2b. Bardziej klasyczne rozwi¹zanie polegaj¹ce na sprawdzeniu w tabelach systemowych czy istnieje kolumna TotalCosts w tabeli Sales.SalesOrderHeader.
			Do tego konstrukcja IF, jeœli istnieje to nic nie rób, a jeœli nie to utwórz.

*/
