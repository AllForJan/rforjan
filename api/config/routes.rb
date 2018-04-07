Rails.application.routes.draw do
  get 'echo/ping'

  get 'diel/info'

  get 'entity/info'
  get 'entity/distances'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
