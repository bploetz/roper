FactoryGirl.define do
  factory :active_record_client, :class => Roper::ActiveRecord::Client do
    client_id "test"
    client_secret "test"
    client_name "Test"
  end
end
