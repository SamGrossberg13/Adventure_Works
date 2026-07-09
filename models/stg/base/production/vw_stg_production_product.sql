select *
from {{ source('production', 'PRODUCT') }}