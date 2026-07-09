select *
from {{ source('person', 'PERSON') }}