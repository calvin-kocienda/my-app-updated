class UsersController < ApplicationController

  skip_before_action :authorized, only: [:new, :create]
  
  def new
    @user = User.new
	@all_companies = Company.all
	@company_to_user = @user.companies_to_user.build
  end

  def create
    @user = User.create(params.require(:user).permit(:username, :password))
    session[:user_id] = @user.id
	@user.update_attribute(:isadmin, 0)
	@user.update_attribute(:approved, false)
	params[:companies][:id].each do |company|
		if company != nil
			#@user.companies_to_user.build(company_id: company)	
			new_entry = CompaniesToUser.new(user_id: @user.id, company_id: company)
			new_entry.save
		end
	end
    redirect_to '/order_screen#landing_screen'
  end
end
