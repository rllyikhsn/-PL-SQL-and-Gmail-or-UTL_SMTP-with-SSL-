create or replace package apex_mail_p
is
   g_smtp_host      varchar2 (256)     := 'localhost';
   g_smtp_port      pls_integer        := 1925;
   g_smtp_domain    varchar2 (256)     := 'gmail.com';
   g_mailer_id constant varchar2 (256) := 'Mailer by Oracle UTL_SMTP';
   -- send mail using UTL_SMTP
   procedure mail (
      p_sender in varchar2
    , p_recipient in varchar2
    , p_subject in varchar2
    , p_message in varchar2
    , p_cc in varchar2
    , p_bcc in varchar2
   );
end;
/

CREATE OR REPLACE package body SYS.apex_mail_p
is
   -- Write a MIME header
   procedure write_mime_header (
      p_conn in out nocopy utl_smtp.connection
    , p_name in varchar2
    , p_value in varchar2
   )
   is
   begin
      utl_smtp.write_data ( p_conn
                          , p_name || ': ' || p_value || utl_tcp.crlf
      );
   end;
   procedure mail (
      p_sender in varchar2
    , p_recipient in varchar2
    , p_subject in varchar2
    , p_message in varchar2
    , p_cc in varchar2
    , p_bcc in varchar2
   )
   is
      l_conn           utl_smtp.connection;
      nls_charset    varchar2(255);
   begin
      -- get characterset
      select value
      into   nls_charset
      from   nls_database_parameters
      where  parameter = 'NLS_CHARACTERSET';
      -- establish connection and autheticate
      l_conn   := utl_smtp.open_connection (g_smtp_host, g_smtp_port);
      utl_smtp.ehlo(l_conn, g_smtp_domain);  
      utl_smtp.command(l_conn, 'auth login');
      utl_smtp.command(l_conn,utl_encode.text_encode('xxxx@gmail.com', nls_charset, 1));
      utl_smtp.command(l_conn, utl_encode.text_encode('xxxxpassword', nls_charset, 1));
      -- set from/recipient
      utl_smtp.command(l_conn, 'MAIL FROM: <'||p_sender||'>');
      utl_smtp.command(l_conn, 'RCPT TO: <'||p_recipient||'>');
      -- write mime headers
      utl_smtp.open_data (l_conn);
      write_mime_header (l_conn, 'From', p_sender);
      write_mime_header (l_conn, 'To', p_recipient);
      write_mime_header (l_conn, 'Subject', p_subject);
      write_mime_header (l_conn, 'CC', p_cc);
      write_mime_header (l_conn, 'BCC', p_bcc);
      write_mime_header (l_conn, 'Content-Type', 'text/plain');
      write_mime_header (l_conn, 'X-Mailer', g_mailer_id);
      utl_smtp.write_data (l_conn, utl_tcp.crlf);
      -- write message body
      utl_smtp.write_data (l_conn, p_message);
      utl_smtp.close_data (l_conn);
      -- end connection
      utl_smtp.quit (l_conn);
   exception
      when others
      then
         begin
           utl_smtp.quit(l_conn);
         exception
           when others then
             null;
         end;
         raise_application_error(-20000,'Failed to send mail due to the following error: ' || sqlerrm);   
   end;
end;
/
