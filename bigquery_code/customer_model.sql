create or replace model `customer_model_final_project.customer_dnn`
OPTIONS (
    model_type='dnn_regressor',
    input_label_cols=['ride_count']
) AS
SELECT
    ride_date,
    ride_count
from
    `customer_model_final_project.test_data_customer`;



-- evaluate
select * from
  ml.evaluate(model `customer_model_final_project.customer_arima`,
  (select ride_date, ride_count
    from `customer_model_final_project.val_data_customer`));