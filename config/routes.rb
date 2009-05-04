ActionController::Routing::Routes.draw do |map|
  map.resources :backup_jobs

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
