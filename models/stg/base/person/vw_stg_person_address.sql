select *
from {{ source('person', 'ADDRESS') }}