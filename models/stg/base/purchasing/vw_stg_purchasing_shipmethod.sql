select *
from {{ source('purchasing', 'SHIPMETHOD') }}