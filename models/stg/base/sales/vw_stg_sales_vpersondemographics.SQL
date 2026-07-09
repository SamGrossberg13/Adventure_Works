select *
from {{ source('sales', 'VPERSONDEMOGRAPHICS') }}