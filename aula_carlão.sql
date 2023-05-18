-- aula do dia 11-05-2023
drop table logteste;

create table logteste
(nrlog number primary key, 
 Dttrans date not null, 
 Usuario varchar2(20) not null, 
 Tabela varchar2(30),
 Opera char(1) check (opera in('I','A','E')),
 Linhas Number(5) not Null check(linhas >=0));
 
 --  Criando uma sequência automática para ser usada como PK na tabela de Log.

drop sequence seqlog;
create sequence seqlog;

select seqlog.currval from dual;

select seqlog.nextval from dual;


insert into TB_produto values (6,'Caneta','CX', 5.00,30);
  
-- Criando o Trigger (toda vez que deletar um produto grava log)
   
Create or Replace trigger EliminaProduto
before delete on tb_produto
for each row
begin
  insert into logteste values(seqlog.nextval,sysdate,user,'produto','E',1);
end Eliminaproduto;

delete tb_produto
where codproduto = 6;

select * from logteste

--
Exemplo 2: Este gatilho não permite que os usuários atualizem ou eliminem registros de pacientes antes das 7:00 da manhã e depois das 14:00
*/
Create or Replace Trigger ChecaHora
before update or delete on paciente
begin
  if to_number(to_char(sysdate,'HH24')) not between 7 and 9 then
    raise_application_error(-20400,'Alterações não permitidas');
  end if;
end ChecaHora;
/
select * from paciente;

update paciente
set datanasc = '10/02/1990'
where codpaciente = 1;

-- Exemplo 3
CREATE or replace TRIGGER Troca_data
BEFORE INSERT ON Tb_pedido
FOR EACH ROW
BEGIN
      :NEW.prazo_entrega := SYSDATE + 15;

END;

Para testar execute: 

 insert into tb_pedido values (998,'30/10/2021',31,5)

select * from tb_pedido;

-- alterando o trigger paraexibir o codigo do produto excluido

Create or Replace trigger EliminaProduto2
before delete on tb_produto
for each row
begin
  insert into logteste values(seqlog.nextval,sysdate,user,'produto='||:old.codproduto,'E',1);
end Eliminaproduto;

delete logteste;

insert into TB_produto values (9,'Caneta bic','CX', 5.00,30);

delete tb_produto
where codproduto = 9;

select * from logteste;

ALTER TRIGGER EliminaProduto DISABLE; 

-- exercício

2. Escreva um trigger que ao alterar o prazo de entrega de um pedido. 
Grave na tablog o prazo antigo, prazo novo e o nome do cliente.

create sequence seqtab;

create table tablog
( numLog number primary key,
  datalog  date,
  usuario  varchar2(15),
  tabela   varchar2(15),
  oldcampo varchar2(50),
  newcampo varchar2(50),
  campo1   varchar2(30));


drop table tablog

create or replace trigger TR_alteraPrazo
before update of prazo_entrega on tb_pedido
for each row
declare
Vnome tb_cliente.nomecliente%type;
begin

SELECT nomecliente into vnome
from tb_cliente
WHERE tb_cliente.codcliente = :old.codCliente;


insert into tablog values (seqtab.nextval,sysdate,user,'Pedido',:old.prazo_entrega,:new.prazo_entrega,Vnome);

end;

show errors;

SELECT * FROM tb_pedido; 

UPDATE tb_pedido
set prazo_entrega = sysdate +3
where numpedido = 9;

select * from tb_item_pedido;

insert into tb_item_pedido values (8, 11, 15, 10.00);

select count(*) from tb_pedido
where codcliente = 31;

select codcliente from tb_pedido
where numpedido = 7;

select * from tb_item_pedido;

--1-

CREATE OR REPLACE TRIGGER insere_item
BEFORE INSERT ON tb_item_pedido
FOR EACH ROW
  DECLARE
    Vcodcliente tb_pedido.codcliente%type;
    Vtotal number;
  BEGIN
  
    SELECT codcliente INTO Vcodcliente FROM tb_pedido WHERE numpedido = :new.numpedido;
    SELECT COUNT(*) into Vtotal FROM tb_pedido WHERE codcliente = vcodcliente;
    
    if Vtotal >= 2 then
      :new.pco_unit := :new.pco_unit - (:new.pco_unit * 0.15);
    end if;
  END ;
  
show errors;

-- 2-

  create table tablog2(
  datalog date,
  mesg varchar(50),
  campo1 varchar(50),
  campo2 varchar(50)
  );

CREATE OR REPLACE TRIGGER altera_endereco
BEFORE UPDATE OF endereco ON tb_cliente
FOR EACH ROW 
  BEGIN
  
    insert into tablog2 values (sysdate, 'Observar mudança de endereço: ' ||:old.codcliente, :old.endereco, :new.endereco);
  
  END altera_endereco;
  
  select * from tablog2;
  
  update tb_cliente
  set endereco = 'genovia'
  where codcliente = 32;
  
show errors;
