select *
from {{ source('purchasing', 'PURCHASEORDERDETAIL') }}