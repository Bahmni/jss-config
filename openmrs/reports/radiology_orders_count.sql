select concept_name.name, count(*) from orders, concept_name, order_type where
  order_type.name = 'Radiology Order'
  and orders.order_type_id = order_type.order_type_id
  and date(orders.date_created) between '#startDate#' and '#endDate#'
  and concept_name.concept_id = orders.concept_id
  and concept_name_type = 'FULLY_SPECIFIED'
GROUP BY concept_name.name;
