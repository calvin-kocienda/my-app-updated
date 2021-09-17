class PastOrdersUser < ApplicationRecord
	has_one_attached :damage_report
	has_one_attached :explanation 
end
