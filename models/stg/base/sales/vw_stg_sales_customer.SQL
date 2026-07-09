
select *
from {{ source('sales', 'CUSTOMER') }}