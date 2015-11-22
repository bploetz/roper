Roper::Engine.routes.draw do
  get 'authorize', to: 'authorization#authorize'
  post 'approve_authorization', to: 'authorization#approve_authorization'
  post 'deny_authorization', to: 'authorization#deny_authorization'
  post 'token', to: 'access_token#token'
end
