drop table if exists sale_order_events_temp;

select concat('{', 
    '"id":"', order_id, '",',
    '"order_date":"', order_date, '",',
    '"external_id":"', external_id, '",',
    '"customer_id":"', customer_id, '",',
    '"sale_order_items":', '[', string_agg(product_info, ','), ']',
    '}') as content
into sale_order_events_temp
from
    (
    select so.id as order_id, so.create_date as order_date, so.external_id as external_id, res_partner.ref as customer_id,
    concat('{',
        '"product_uuid":"' , p.uuid, '",' ,
        '"number_of_days":"' , s.product_number_of_days, '",',
        '"dosage":"', s.product_dosage, '",', 
        '"unit":"', pu.name, '",', 
        '"quantity":"', s.product_uom_qty, '"',
        '}') as product_info
    from sale_order_line s
    join sale_order so on so.id = s.order_id
    join product_product p on s.product_id = p.id
    join product_template pt on pt.id = p.product_tmpl_id
    join product_category pc on pc.id = pt.categ_id
    join product_category parent_pc on parent_pc.id = pc.parent_id and parent_pc.name = 'Drug'
    join res_partner on res_partner.id = partner_id
    join product_uom pu on pu.id = s.product_uom 
    ) as foo
group by order_id, order_date, external_id, customer_id;

ALTER TABLE sale_order_events_temp ADD COLUMN id SERIAL;
UPDATE sale_order_events_temp SET id = nextval(pg_get_serial_sequence('sale_order_events_temp','id'));

CREATE OR REPLACE FUNCTION insert_sale_order_event_records()
    RETURNS integer AS
$BODY$
DECLARE
    sale_order_count integer;
    sale_order_start_id integer;
    title_value integer;
    i integer;
BEGIN
    select id into sale_order_start_id from sale_order_events_temp order by id limit 1;
    SELECT count(*)+sale_order_start_id into sale_order_count from sale_order_events_temp;
    select title into title_value from event_records where category = 'sale_order';
    i := id;
    WHILE (i <= sale_order_count)
    loop
        title_value = title_value + 1;
        insert into event_records values (
            1, now(), now(), 1, 'sale_order', 
            uuid_generate_v4(), title_value, now(), 
            (select content from sale_order_events_temp where id = i)
            , '');
    end loop;
    RETURN i;
END;
$BODY$
LANGUAGE plpgsql VOLATILE