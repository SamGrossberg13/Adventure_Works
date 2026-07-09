select *
from {{ source('purchasing', 'VENDOR') }}