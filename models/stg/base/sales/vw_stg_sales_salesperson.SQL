
select *
from {{ source('sales', 'SALESPERSON') }}