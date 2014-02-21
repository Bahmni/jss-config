insert into event_records(create_uid, create_date, write_date, write_uid, category, uuid, 
    title, timestamp, object, uri) select 1, now(), now(), 1, 'sale_order', 
    uuid_generate_v4(), 'sale_order', now(), a.content, '' 
from (select concat('{', 
    '"id":"', order_id, '",',
    '"orderDate":"', order_date, '",',
    '"externalId":"', external_id, '",',
    '"customerId":"', customer_id, '",',
    '"saleOrderItems":', '[', string_agg(product_info, ','), ']',
    '}') as content
from
    (
    select so.id as order_id, so.create_date as order_date, so.external_id as external_id, res_partner.ref as customer_id,
    concat('{',
        '"productUuid":"' , p.uuid, '",' ,
        '"numberOfDays":"' , s.product_number_of_days, '",',
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
    where res_partner.ref is not null
    ) as foo
group by order_id, order_date, external_id, customer_id) a;