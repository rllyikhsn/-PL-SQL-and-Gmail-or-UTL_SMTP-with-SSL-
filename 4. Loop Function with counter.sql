declare
    email varchar(20);
    cursor data_mhs
    is
        select
            nama,email
        from
            mahasiswa;
begin
    for mhs in data_mhs
    loop
        APEX_MAIL_P.mail('datakhusus40@gmail.com',mhs.email,'Subjek 1 1','Message satu satu kepada : ' ||mhs.nama,'datakhusus40@gmail.com','datakhusus40@gmail.com');
        dbms_output.put_line(mhs.email);
        mhs.email := '';
        dbms_output.put_line('data ini adalah' || mhs.email);
    end loop;
end;/