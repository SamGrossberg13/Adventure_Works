
select *
from {{ source('sales', 'SALESTERRITORY') }}