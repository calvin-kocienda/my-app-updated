class Fooditem < ApplicationRecord

	def self.import(file)
		csv_text = File.read(file.path, encoding:"ISO-8859-1", liberal_parsing: true)
		table = CSV.parse(csv_text)
		puts table.length()
		puts table

		for item in 1..table.length() - 1
			foodname = table[item][0]
			foodprice = table[item][1]
			foodchina = table[item][2]
			foodcategory = table[item][3]
			foodsubcategory = table[item][4]
			foodcompany = table[item][5]
			fooditems = Fooditem.order("price2 desc").all
			if fooditems.where(item: foodname).count == 0 
				fooditem_hash = Fooditem.new
				fooditem_hash.item = foodname
				fooditem_hash.price2 = foodprice
				fooditem_hash.china = foodchina
				fooditem_hash.show = true
				fooditem_hash.price = 1
				fooditem_hash.category = foodcategory
				fooditem_hash.subcategory = foodsubcategory
				fooditem_hash.company = foodcompany
				if Company.where(companyname: foodcompany).count == 0
					puts "Adding new company!"
					new_company = Company.new
					new_company.companyname = foodcompany
					new_company.save
				end
				fooditem_hash.save
			else
				foodchange = fooditems.where(item: foodname).first
				foodchange.price2 = foodprice
				foodchange.china = foodchina
				foodchange.category = foodcategory
				foodchange.subcategory = foodsubcategory
				foodchange.company = foodcompany
				if Company.where(companyname: foodcompany).count == 0
					puts "Adding new company!"
					new_company = Company.new
					new_company.companyname = foodcompany
					new_company.save
				end
			end
		end
	end


end
