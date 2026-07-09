select *
from {{ source('purchasing', 'PURCHASEORDERHEADER') }}