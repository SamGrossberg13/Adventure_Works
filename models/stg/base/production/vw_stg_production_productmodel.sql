select *
from {{ source('production', 'PRODUCTMODEL') }}