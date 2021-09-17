class User < ApplicationRecord

	has_secure_password

	has_many :companies_to_user
	has_many :companys, :through => :companies_to_user

end
