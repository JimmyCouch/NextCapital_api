Nextcapital::Application.routes.draw do
  root 'application#home'
  get '/log_in' => 'application#log_in', as: :log_in
  post 'log_in' => 'application#log_in'
  get '/home' => 'application#home', as: :logged_in
  get '/submit_todo' => 'application#submit_checkbox'
  get '/log_out' => 'application#log_out'
  get '/new_todo' => 'application#new_todo'
  post '/submit_new_todo' => 'application#submit_new_todo'

end
