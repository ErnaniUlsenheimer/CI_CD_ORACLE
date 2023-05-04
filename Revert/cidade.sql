declare
   c int;
begin
   select count(*) into c from user_tables where table_name = upper('cidade');
   if c = 1 then
      execute immediate 'drop table cidade';
   end if;
end;