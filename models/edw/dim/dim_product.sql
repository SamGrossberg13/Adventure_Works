{{ config(materialized='table') }}
{{ config(unique_key=["product_sk"]) }}

select
    product_sk,
    product_id_bk,
    product_name,
    product_number,
    make_flag,
    finished_goods_flag,
    product_color,
    product_size,
    product_weight,
    product_line,
    product_class,
    product_style,
    standard_cost,
    list_price,

    product_subcategory_id,
    product_subcategory_name,

    product_category_id,
    product_category_name,

    product_model_id,
    product_model_name,

    days_to_manufacture
from {{ ref('vw_elt_staging_production_dim_product') }}