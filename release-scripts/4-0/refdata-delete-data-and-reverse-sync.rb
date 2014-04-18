#!/usr/bin/ruby
require 'csv'
require 'securerandom'
require 'pg'

@host_name =  ARGV[0]

def open_conn(dbname)
  return PGconn.open(:host => @host_name, :dbname => dbname, :user => dbname)
end

@openelis_conn = open_conn("clinlims")
@openerp_conn = open_conn("openerp")
@refdata_conn = open_conn("reference_data")



def output(data) 
  puts(data)
  @refdata_conn.exec(data)
end

def delete_refdata
  output ("delete from drug;")
  output ("delete from panel_test;")
  output ("delete from panel;")
  output ("delete from test;")
  output ("delete from drug_category;")
  output ("delete from department;")
  output ("delete from product_unit_of_measure;")
  output ("delete from product_unit_of_measure_category;")
  output ("delete from sample;")
  output ("delete from test_unit_of_measure;")
end


def create_event_records(title, value)
    output ("insert into event_records (id, uuid, title, timestamp, object, category)
    values (nextval('event_records_id_seq'), '#{SecureRandom.uuid}', '#{title}', now(), 
      '/reference-data/#{title}/#{value}', 'reference_data');")
end

def install_uuid_extension
  openerp_postgres_conn = PGconn.open(:host => @host_name, :dbname => 'openerp', :user => 'postgres')  
  openerp_postgres_conn.exec("create extension if not exists \"uuid-ossp\";")
end


def update_product_uuid_in_openerp
  res = @openerp_conn.exec("update product_product set uuid = uuid_generate_v4() where uuid is null;")
  res = @openerp_conn.exec("update product_uom_categ set uuid = uuid_generate_v4() where uuid is null;")
  res = @openerp_conn.exec("update product_category set uuid = uuid_generate_v4() where uuid is null;")
  res = @openerp_conn.exec("update product_uom set uuid = uuid_generate_v4() where uuid is null;")
end 

def convert_depts
  res = @openelis_conn.exec("select uuid, name, description, sort_order from test_section where is_active = 'Y';")
  res.each do |dept|
    output ("insert into department (id, version, date_created, last_updated, name, description, is_active, sort_order)
       values ('#{dept['uuid']}', 0, now(), now(), '#{dept['name']}', '#{dept['description']}', true, '#{dept['sort_order']}');")
    create_event_records('department', dept['uuid'])
  end
end

def convert_sample
  res = @openelis_conn.exec("select description, is_active, sort_order, local_abbrev, uuid from type_of_sample;")
  res.each do |sample|
    active = sample['is_active'] == "t" ? true : false
    output ("insert into sample (id, version, date_created, last_updated, name, short_name, is_active, sort_order)
      values ('#{sample['uuid']}', 0, now(), now(), '#{sample['description']}', '#{sample['local_abbrev']}', '#{active}', '#{sample['sort_order']}' );")
    create_event_records('sample', sample['uuid'])
  end
end

def convert_panel_test
  res = @openelis_conn.exec("select er1.external_id as panel, er2.external_id as test from panel_item pi, external_reference er1, external_reference er2 where pi.panel_id = er1.item_id and pi.test_id = er2.item_id and er1.type = 'Panel' and er2.type = 'Test';")
  res.each do |panel_test|
    output ("insert into panel_test (panel_id, test_id) 
      values ('#{panel_test['panel']}', '#{panel_test['test']}');")
  end
end

def convert_product_unit_of_measure_category
  res = @openerp_conn.exec("select uuid as uuid, name as name from product_uom_categ;")
  res.each do |product_uom_cat|
    output ("insert into product_unit_of_measure_category(id, version, date_created, last_updated, name) 
      values('#{product_uom_cat['uuid']}', 0, now(), now(), '#{product_uom_cat['name']}') ;")
    create_event_records('product_unit_of_measure_category', product_uom_cat['uuid'])
  end
end

def convert_product_unit_of_measure
  res = @openerp_conn.exec("select pu.uuid as uuid, pu.name as name, pu.factor as factor, puc.uuid as category_id from product_uom pu, product_uom_categ puc where pu.category_id = puc.id and pu.active = true;")
  res.each do |product_uom|
    ratio = 1.0/product_uom['factor'].to_f
    output ("insert into product_unit_of_measure (id, version, date_created, last_updated, 
      name, category_id, is_active, ratio)
      values('#{product_uom['uuid']}', 0, now(), now(), '#{product_uom['name']}', 
        '#{product_uom['category_id']}', true, '#{ratio}');")
    create_event_records('product_unit_of_measure', product_uom['uuid'])
  end
end

def convert_drug
  res = @openerp_conn.exec("SELECT pp.uuid  AS uuid, 
       pt.name                    AS name, 
       COALESCE(pp.drug, pt.name) AS generic_name, 
       pp.default_code            AS short_name,
       pc.name                    AS form, 
       purchase_uom.uuid          AS purchase_unit_of_measure_id, 
       sale_uom.uuid              AS sale_unit_of_measure_id, 
       pp.manufacturer            AS manufacturer, 
       pt.standard_price          AS cost_price, 
       pt.list_price              AS sale_price, 
       pc.uuid                    AS category_id, 
       pp.active          AS is_active
FROM   product_template pt, 
       product_product pp, 
       product_category pc, 
       product_uom sale_uom, 
       product_uom purchase_uom 
WHERE  pt.categ_id IN (SELECT id 
                       FROM   product_category 
                       WHERE  parent_id = (SELECT id 
                                           FROM   product_category 
                                           WHERE  name = 'Drug')) 
       AND pt.id = pp.product_tmpl_id 
       AND pt.categ_id = pc.id 
       AND pt.uom_id = sale_uom.id 
       AND pt.uom_po_id = purchase_uom.id
       AND pp.id <> 2998;")
  res.each do |product|
    name = PGconn.escape_string(product['name'].strip)
    generic_name = PGconn.escape_string(product['generic_name'].strip)

    output ("insert into drug (id, version, date_created, last_updated, name, 
      generic_name, short_name, form_id, sale_unit_of_measure_id, purchase_unit_of_measure_id, 
      manufacturer, cost_price, sale_price, is_active, category_id)
      select '#{product['uuid']}', 0, now(), now(), '#{name}', 
        '#{generic_name}', '#{product['short_name']}', id, 
        '#{product['sale_unit_of_measure_id']}', '#{product['purchase_unit_of_measure_id']}', 
        '#{product['manufacturer']}', '#{product['cost_price']}', '#{product['sale_price']}', 
        '#{product['is_active']}', '#{product['category_id']}' from drug_form where name = '#{product['form']}';")
    create_event_records('drug', product['uuid'])
  end
end

def convert_drug_category
  res = @openerp_conn.exec("SELECT uuid, name FROM product_category WHERE parent_id = (SELECT id FROM product_category WHERE name = 'Drug');")
  res.each do |drug_category|
    output ("insert into drug_category(id, version, date_created, last_updated, name)
      values ('#{drug_category['uuid']}', 0, now(), now(), '#{drug_category['name']}')")
    create_event_records('drug_category', drug_category['uuid'])
  end
end

def get_price(uuid)
  res = @openerp_conn.exec("select pt.list_price  AS sale_price from product_product pp, product_template pt where pp.product_tmpl_id = pt.id and pp.uuid = '#{uuid}';");
  if res.values.size > 0
    return res.getvalue(0,0) 
  else
    return 0
  end
end

def get_result_type(test_id) 
  res = @openelis_conn.exec("select distinct tst_rslt_type from test_result where test_id = #{test_id};");
  if res.values.size > 0
    return res.getvalue(0,0)
  else 
    return 'N'
  end
end

def convert_panel
  res = @openelis_conn.exec("select er.external_id as uuid, p.name as name,
    p.description as description, tos.uuid as sample_id, p.sort_order as sort_order
    from panel p, external_reference er, sampletype_panel sp, type_of_sample tos
    where p.id = er.item_id and er.type = 'Panel' and sp.panel_id = p.id and
    sp.sample_type_id = tos.id;")
  res.each do |panel|
    sale_price = get_price(panel['uuid'])
    output ("insert into panel (id, version, date_created, last_updated, name, description, 
      sample_id, sale_price, is_active, sort_order) 
      values('#{panel['uuid']}', 0, now(), now(), '#{panel['name']}', '#{panel['description']}', 
      '#{panel['sample_id']}', #{sale_price}, true, '#{panel['sort_order']}');")
    create_event_records('panel', panel['uuid'])
  end
end

def quotify(str)
  return str.nil? ? "null" : "'#{str}'"
end


def convert_test
  res = @openelis_conn.exec("select er.external_id as uuid, t.name as name, 
      t.description as description, ts.uuid as department_id, tos.uuid as sample_id, 
      t.sort_order as sort_order, t.is_active as is_active, t.id as test_id, uom.uuid as test_unit_of_measure_id 
        from test t
        join external_reference er on t.id = er.item_id and er.type = 'Test'
        join sampletype_test st on st.test_id = t.id
        join type_of_sample tos on st.sample_type_id = tos.id 
        join test_section ts on t.test_section_id = ts.id
        left outer join unit_of_measure uom on t.uom_id = uom.id;")
  res.each do |test|
    sale_price = get_price(test['uuid'])
    result_type = get_result_type(test['test_id'])
    output ("insert into test(id, version, date_created, last_updated, name, 
      description, sale_price, department_id, sample_id, sort_order, is_active, 
      result_type, test_unit_of_measure_id)
      values ('#{test['uuid']}', 0, now(), now(), '#{test['name']}', 
    '#{test['description']}', #{sale_price}, '#{test['department_id']}', 
    '#{test['sample_id']}', #{test['sort_order']}, '#{test['is_active']}', 
    '#{result_type}', #{quotify(test['test_unit_of_measure_id'])});")
    create_event_records('test', test['uuid'])
  end
  @refdata_conn.exec("update test set result_type = 'Remark' where result_type = 'R';")
  @refdata_conn.exec("update test set result_type = 'Numeric' where result_type = 'N';")
  @refdata_conn.exec("update test set result_type = 'Dictionary' where result_type = 'D';")
end

def convert_test_unit_of_measure
  res = @openelis_conn.exec("select uuid, name from unit_of_measure;")
  res.each do |uom|
    output ("insert into test_unit_of_measure (id, version, date_created, last_updated, name, 
      is_active) values ('#{uom['uuid']}', 0, now(), now(), '#{uom['name']}', true);")
    create_event_records('test_unit_of_measure', uom['uuid'])
  end
end

install_uuid_extension
delete_refdata
update_product_uuid_in_openerp
convert_depts
convert_sample
convert_product_unit_of_measure_category 
convert_product_unit_of_measure 
convert_test_unit_of_measure
convert_drug_category
convert_drug
convert_test
convert_panel
convert_panel_test