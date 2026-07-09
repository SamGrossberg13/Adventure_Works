select *
from {{ source('person', 'STATEPROVINCE') }}