create table account(Account_Number int primary key auto_increment, Acc_Name varchar(30) not null, Balance numeric(10,2));



create table accountUpdate (Account_No int  not null,
Acc_Name varchar(30) not null,
changed_at timestamp,
trns_type varchar(10) not null,
before_Bal numeric(10,2) not null,
after_Bal numeric(10,2) not null, foreign key (Account_No) references account(Account_Number));



insert into account(Account_Number, Acc_Name, Balance ) values(1245,'Sunil',50000.00);
insert into account(Acc_Name, Balance ) values('vinith',30000.00);
insert into account(Acc_Name, Balance ) values('vikas',35000.00);
insert into account(Acc_Name, Balance ) values('rakesh',22000.00);

delimiter $$
create trigger withdrawal before update on account for each row
begin
if(old.Balance>new.Balance) then
insert into accountupdate(Account_No, Acc_Name, changed_at, trns_type, before_Bal, after_Bal)
values(old.Account_Number, old.Acc_Name, now(),'withdraw', old.Balance , new.Balance);
end if;
end $$

delimiter $$
create trigger deposit before update on account for each row
begin
if(old.Balance<new.Balance) then
insert into accountupdate(Account_No, Acc_Name, changed_at, trns_type, before_Bal, after_Bal)
values(old.Account_Number, old.Acc_Name, now(),'deposit', old.Balance , new.Balance);
end if;
end $$

drop trigger deposit

update account set Balance = (Balance+6200) where Account_Number = 1246;
update account set Balance = (Balance-3400) where Account_Number = 1245;

delimiter $$
create procedure transaction(in tr_type varchar(10), out sum_Balance numeric(10,2))
begin 
select  sum(after_Bal) into sum_Balance from accountupdate where trns_type = tr_type and hour(changed_at) = (hour(now())-1) ;
end $$

call transaction('deposit' , @sum_depo);
select @sum_depo;

delimiter $$
create procedure transaction1(in tr_type varchar(10), in timer int, out sum_Balance numeric(10,2))
begin 
select  sum(after_Bal) into sum_Balance from accountupdate where trns_type = tr_type and hour(changed_at) = timer;
end $$

call transaction2('deposit' , 12, @sum_depo);
select @sum_depo;


delimiter $$
create procedure transaction2(in tr_type varchar(10), in timer int, out sum_Balance numeric(10,2))
begin 
if tr_type = 'deposit' then
select sum(after_Bal-before_Bal)  into sum_Balance from accountupdate where trns_type = tr_type and hour(changed_at) = timer;
end if;
end $$
drop procedure transaction3;

delimiter $$
create procedure transaction3(in tr_type varchar(10), in timer int, out sum_Balance numeric(10,2))
begin 
if tr_type = 'withdraw' then
select sum(before_Bal-after_Bal)  into sum_Balance from accountupdate where trns_type = tr_type and hour(changed_at) = timer;
end if;
end $$

call transaction3('withdraw' , 12, @sum_depo);
select @sum_depo;

