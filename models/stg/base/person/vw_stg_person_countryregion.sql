select *
from {{ source('person', 'COUNTRYREGION') }}