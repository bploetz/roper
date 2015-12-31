FactoryGirl.define do
  factory :mongoid_client, :class => Roper::Mongoid::Client do
    client_id "test"
    client_secret "test"
    client_name "Test"
  end

  factory :mongoid_client_redirect_uri, :class => Roper::Mongoid::ClientRedirectUri do
    uri
  end

  factory :mongoid_authorization_code, :class => Roper::Mongoid::AuthorizationCode do
    code { FactoryGirl.generate(:token) }
    expires_at (DateTime.now + 5.minutes)
  end

  factory :mongoid_access_token, :class => Roper::Mongoid::AccessToken do
    token { FactoryGirl.generate(:token) }
  end

  factory :mongoid_refresh_token, :class => Roper::Mongoid::RefreshToken do
    token { FactoryGirl.generate(:token) }
  end

  factory :mongoid_jwt_issuer, :class => Roper::Mongoid::JwtIssuer do
    issuer { FactoryGirl.generate(:issuer) }
  end

  factory :mongoid_jwt_issuer_key, :class => Roper::Mongoid::JwtIssuerKey do
    algorithm "HS256"
    hmac_secret "shhhh!"
  end
end
