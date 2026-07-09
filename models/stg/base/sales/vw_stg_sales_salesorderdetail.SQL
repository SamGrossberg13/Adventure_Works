
select *
from {{ source('sales','SALESORDERDETAIL') }}
