Roper::Engine.routes.draw do
  post 'authorize', to: 'authorization#authorize'
  post 'token', to: 'access_token#token'
end
