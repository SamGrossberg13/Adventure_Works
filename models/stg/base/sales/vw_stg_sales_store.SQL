
select *
from {{ source('sales', 'STORE') }}