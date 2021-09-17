class ItemsInCart < ApplicationRecord

	def self.to_csv
		attributes = %w{Food_Item: Number_Purchased:}
		#values = ItemsInCart.where(userid: session_id)
		CSV.generate(headers: true) do |csv|
			csv << attributes
			all.each do |value|
				csv << [value.itemname, value.itemcount]
			end
		end
	end

end
