
EXEC dbo.GenerateRandomValues
	@rows = 10000,
	@attrib_name = 'A;B;C', -- zdefiniowane nazwy kolumn
	@attrib_min_value = '100.99; 100.99; 100.99', -- min wartoœæ zakresu
	@attrib_max_value = '999.99; 999.99; 999.99', -- max wartoœæ zaresu
	@create_table = 0 -- @create_table = 0 -> wyœwietlenie danych | @create_table = 1 -> zapis danych do tabeli dbo.random_values

EXEC dbo.GenerateRandomValues
	@rows = 10,
	@attrib_name = 'A;B;C',
	@attrib_min_value = '100.99; 100.99; 100.99',
	@attrib_max_value = '999.99; 999.99; 999.99',
	@create_table = 1 -- @create_table = 0 -> wyœwietlenie danych | @create_table = 1 -> zapis danych do tabeli dbo.random_values

SELECT * FROM dbo.random_values