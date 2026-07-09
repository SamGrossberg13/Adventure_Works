select *
from {{ source('production', 'PRODUCTSUBCATEGORY') }}