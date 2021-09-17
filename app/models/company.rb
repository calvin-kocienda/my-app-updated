class Company < ApplicationRecord
	
	has_many :companies_to_user
	has_many :users, :through => :companies_to_user

end
