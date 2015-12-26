FactoryGirl.define do
  sequence :uri do |n|
    "http://www.example.com/#{n}"
  end

  sequence :token do |n|
    "#{n}"
  end
end
