FactoryGirl.define do
  factory :active_record_client, :class => Roper::ActiveRecord::Client do
    client_id "test"
    client_secret "test"
    client_name "Test"
  end

  sequence :uri do |n|
    "http://www.example.com/#{n}"
  end

  factory :active_record_client_redirect_uri, :class => Roper::ActiveRecord::ClientRedirectUri do
    uri
  end
end
