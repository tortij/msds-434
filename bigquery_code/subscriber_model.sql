create or replace model `subscriber_model_final_project.subscriber_dnn`
OPTIONS (
    model_type='dnn_regressor',
    input_label_cols=['ride_count']
) AS
SELECT
    ride_date,
    ride_count
from
    `subscriber_model_final_project.test_data_subscriber`;


-- evaluate

select * from
  ml.evaluate(model `subscriber_model_final_project.subscriber_arima_model`,
  (select ride_date, ride_count
    from `subscriber_model_final_project.val_data_subscriber`));
