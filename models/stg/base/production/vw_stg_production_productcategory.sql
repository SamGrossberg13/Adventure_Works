select *
from {{ source('production', 'PRODUCTCATEGORY') }}