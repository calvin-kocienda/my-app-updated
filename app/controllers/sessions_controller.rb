class SessionsController < ApplicationController

  skip_before_action :authorized, only: [:new, :create, :index]
  
  def new
  end

  def create

		@user = User.find_by(username: params[:username])
		if @user && @user.authenticate(params[:password])
			session[:user_id] = @user.id 
			redirect_to root_path
		else
			redirect_to '/login', notice: "Your username or password is incorrect."
		end


  end

  def index
    test1 = User.where(username: "test1").first
	test1.update_attribute(:approved, true)
  end

  def login
  end
  
  def logout
	session[:user_id] = nil
	current_user = session[:user_id]
	@session = session[:user_id]
	redirect_to '/welcome'
  end

  def page_requires_login
  end
  
end