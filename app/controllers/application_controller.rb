class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :authenticate, :except => [:log_in]

  def authenticate
  	if session[:api_token].nil?
  		render "application/log_in"
  	end
  end

  def log_in
  	  email = params[:email]
  	  pw = params[:password]
  	  hash = {:email => email, :password => pw}
      make_request("Post",hash,"/users/sign_in", "log_in")
  	  redirect_to logged_in_path
  end

  def home
  	api_token = session[:api_token]
  	id = session[:id]
    hash = {:api_token => api_token, :id => id}
    url = "/users/#{id}/todos.json?api_token=#{api_token}"
    make_request("Get", nil, url, "get_todos")
  end

  def submit_checkbox 
    tag_ids = params[:tag_ids]
    api_token = session[:api_token]
    id = session[:id]
    if !tag_ids.nil?

        tag_ids.each { |i| 
          parameter = eval(tag_ids[i.to_i])
          hash = {:api_token => api_token, :todo => {:description =>  parameter["description"], :is_complete => true}}
          make_request("Put", hash, "/users/#{id}/todos/#{parameter["id"]}", "submit_checkbox")
        }
    end

      redirect_to logged_in_path

  end

  def log_out
    session[:id] = nil
    session[:api_token] = nil
    render "application/log_in"
  end

  def new_todo

  end

  def submit_new_todo
    id = session[:id]
    hash = {:api_token => session[:api_token], :todo => {:description => params[:todo]["desc"]}}
    make_request("Post", hash, "/users/#{id}/todos", "submit_new_todo")
    redirect_to root_path
  end

  def make_request(type, hash, url,action)
    uri = URI.parse("http://recruiting-api.nextcapital.com")
    # uri = URI.parse("http://localhost:2000")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(url) if type == "Post"
    request = Net::HTTP::Get.new(url) if type == "Get"
    request = Net::HTTP::Put.new(url) if type == "Put"
    request.add_field('Content-Type', 'application/json')
    request.body = JSON.generate(hash) if type == "Post" || type == "Put"
    response = http.request(request)
    if action == "log_in"
        obj = JSON.parse(response.body)
        session[:api_token] = obj["api_token"]
        session[:id] = obj["id"]
    elsif action == "get_todos"
        @obj = JSON.parse(response.body).sort_by { |hash| hash["description"].downcase }
    end
  end
end
