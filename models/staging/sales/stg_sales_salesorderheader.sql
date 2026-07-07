select *
from {{ source('sales', 'SALESORDERHEADER') }}