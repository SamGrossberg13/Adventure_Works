select *
from {{ source('production', 'TRANSACTIONHISTORY') }}