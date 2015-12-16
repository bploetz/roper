FactoryGirl.define do
  sequence :uri do |n|
    "http://www.example.com/#{n}"
  end

  sequence :token do |n|
    "#{n}"
  end

  factory :active_record_client, :class => Roper::ActiveRecord::Client do
    client_id "test"
    client_secret "test"
    client_name "Test"
  end

  factory :active_record_client_redirect_uri, :class => Roper::ActiveRecord::ClientRedirectUri do
    uri
  end

  factory :active_record_authorization_code, :class => Roper::ActiveRecord::AuthorizationCode do
    code { FactoryGirl.generate(:token) }
    expires_at (DateTime.now + 5.minutes)
  end

  factory :active_record_access_token, :class => Roper::ActiveRecord::AccessToken do
    token { FactoryGirl.generate(:token) }
  end

  factory :active_record_refresh_token, :class => Roper::ActiveRecord::RefreshToken do
    token { FactoryGirl.generate(:token) }
  end
end
