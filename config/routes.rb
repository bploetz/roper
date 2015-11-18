Roper::Engine.routes.draw do
  post 'token', to: 'authorization#token'
end
