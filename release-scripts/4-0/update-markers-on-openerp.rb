#!/usr/bin/ruby
require 'pg'

@host_name =  ARGV[0]

def open_conn(dbname)
  return PGconn.open(:host => @host_name, :dbname => dbname, :user => dbname)
end

@openelis_conn = open_conn("clinlims")
@openerp_conn = open_conn("openerp")

pageCount = @openelis_conn.exec("select ceil(count(*)/5.0) as value from event_records where category = 'patient';").first
puts(pageCount)
lastReadEntry = @openelis_conn.exec("select concat('tag:atomfeed.ict4h.org:', uuid) as value from event_records where id = (select max(id) from event_records where category = 'patient');").first
puts(lastReadEntry)
@openerp_conn.exec("insert into markers(create_uid, create_date, write_date, write_uid, last_read_entry_id, feed_uri_for_last_read_entry, feed_uri) values (1, now(), now(), 1, '#{lastReadEntry['value']}', 'http://localhost:8080/openelis/ws/feed/patient/#{pageCount['value']}', 'http://localhost:8080/openelis/ws/feed/patient/recent' )")