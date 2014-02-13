update sample set
    entered_date = res.corrected_date
from (
  select 
  s.id, LEAST(MIN(a.lastupdated), MIN(r.lastupdated), s.lastupdated)
from sample s
join sample_item si on si.samp_id = s.id
join analysis a on a.sampitem_id = si.id
left join result r on r.analysis_id = a.id
group by s.id, s.entered_date    
) as res (sample_id, corrected_date) 
where id = res.sample_id;