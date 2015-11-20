Roper::Engine.routes.draw do
  get 'authorize', to: 'authorization#authorize'
  post 'token', to: 'access_token#token'
end
