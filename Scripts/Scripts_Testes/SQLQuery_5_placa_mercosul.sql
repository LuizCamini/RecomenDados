use [2096]
GO
select PlacaVeiculo,PlacaVeiculoMercosul from Veiculos
GO

alter table Veiculos add PlacaVeiculoMercosul varchar(8)
GO


CREATE PROCEDURE AtualizaPlacaMercosul (@Placa as varchar(8))
as
begin
    set nocount on;
declare 
    @placamercosul varchar(8)
    ,@placa2 varchar(8)

Set @placa2 = (    
select  
    case 
        when SUBSTRING(PlacaVeiculo,6,1) = 0 THEN UPPER(SUBSTRING(PlacaVeiculo,1,5)) + 'A'  + SUBSTRING(PlacaVeiculo,7,2) 
        when SUBSTRING(PlacaVeiculo,6,1) = 1 THEN UPPER(SUBSTRING(PlacaVeiculo,1,5)) + 'B'  + SUBSTRING(PlacaVeiculo,7,2) 
        when SUBSTRING(PlacaVeiculo,6,1) = 2 THEN UPPER(SUBSTRING(PlacaVeiculo,1,5)) + 'C'  + SUBSTRING(PlacaVeiculo,7,2) 
        when SUBSTRING(PlacaVeiculo,6,1) = 3 THEN UPPER(SUBSTRING(PlacaVeiculo,1,5)) + 'D'  + SUBSTRING(PlacaVeiculo,7,2) 
        when SUBSTRING(PlacaVeiculo,6,1) = 4 THEN UPPER(SUBSTRING(PlacaVeiculo,1,5)) + 'E'  + SUBSTRING(PlacaVeiculo,7,2) 
        when SUBSTRING(PlacaVeiculo,6,1) = 5 THEN UPPER(SUBSTRING(PlacaVeiculo,1,5)) + 'F'  + SUBSTRING(PlacaVeiculo,7,2) 
        when SUBSTRING(PlacaVeiculo,6,1) = 6 THEN UPPER(SUBSTRING(PlacaVeiculo,1,5)) + 'G'  + SUBSTRING(PlacaVeiculo,7,2) 
        when SUBSTRING(PlacaVeiculo,6,1) = 7 THEN UPPER(SUBSTRING(PlacaVeiculo,1,5)) + 'H'  + SUBSTRING(PlacaVeiculo,7,2) 
        when SUBSTRING(PlacaVeiculo,6,1) = 8 THEN UPPER(SUBSTRING(PlacaVeiculo,1,5)) + 'I'  + SUBSTRING(PlacaVeiculo,7,2) 
        when SUBSTRING(PlacaVeiculo,6,1) = 9 THEN UPPER(SUBSTRING(PlacaVeiculo,1,5)) + 'J'  + SUBSTRING(PlacaVeiculo,7,2) END AS PLACA_MERCOSUL
from Veiculos where PlacaVeiculo = @Placa)

set @placamercosul = @Placa2

update Veiculos set PlacaVeiculoMercosul = @placamercosul where PlacaVeiculo = @Placa

end

go

exec AtualizaPlacaMercosul 'abc-1020'