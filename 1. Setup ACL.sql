-- create acl
begin
        dbms_network_acl_admin.create_acl (
                acl             => 'gmail.xml',
                description     => 'Normal Access',
                principal       => 'CONNECT',
                is_grant        => TRUE,
                privilege       => 'connect',
                start_date      => null,
                end_date        => null
        );
end;
/
-- add priviliege to acl
begin
  dbms_network_acl_admin.add_privilege ( 
  acl       => 'gmail.xml',
  principal    => 'SYS',
  is_grant    => TRUE, 
  privilege    => 'connect', 
  start_date    => null, 
  end_date    => null); 
end;
/
-- assign host, port to acl
begin
  dbms_network_acl_admin.assign_acl (
  acl => 'gmail.xml',
  host => 'localhost',
  lower_port => 25,
  upper_port => 25);
end;
/
