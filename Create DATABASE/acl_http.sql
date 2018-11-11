begin
  dbms_network_acl_admin.append_host_ace(
    host       => 'image.tmdb.org',
    lower_port => 80,
    upper_port => 80,
    ace        => xs$ace_type(
      privilege_list => xs$name_list('http'),
      principal_name => 'cb',
      principal_type => xs_acl.ptype_db
    )
  );
end;
