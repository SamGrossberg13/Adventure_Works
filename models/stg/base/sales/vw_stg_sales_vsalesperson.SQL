select *
from {{ source('sales', 'VSALESPERSON') }}