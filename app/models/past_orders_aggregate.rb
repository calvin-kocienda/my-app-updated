class PastOrdersAggregate < ApplicationRecord

	has_one_attached :damage_report
	has_one_attached :explanation
	def self.import(file)
		csv_text = File.read(file.path, encoding:"ISO-8859-1", liberal_parsing: true)
		table = CSV.parse(csv_text)
		companynames = table[0][1..]
		puts table.length()
		@currentime = Time.now.utc
		for item in 1..table.length() - 1
			for name in 0..companynames.length() - 1
				companyname = companynames[name]
				itemname = table[item][0]
				count = table[item][name+1]
				#puts FoodAvailable.where(["companyname = ? and itemname = ?", companyname, itemname]).count == 0
				if PastOrdersAggregate.where(["companyname = ? and itemname = ?", companyname, itemname]).count == 0 && count != nil
					foodavailable_hash = PastOrdersAggregate.new
					foodavailable_hash.companyname = companyname
					foodavailable_hash.itemname = itemname
					foodavailable_hash.itemcount = count
					foodavailable_hash.updated_at = @currentime.day
					foodavailable_hash.save
				elsif PastOrdersAggregate.where(["companyname = ? and itemname = ?", companyname, itemname]).count == 0 && count == nil
					break
				else
					foodavailable_item = PastOrdersAggregate.where(["companyname = ? and itemname = ?", companyname, itemname]).first
					countstring = count.to_s
					foodstring = foodavailable_item.itemcount.to_s
					if countstring != foodstring
						foodavailable_item.update_attribute(:itemcount, count)
					end
				end
				
			end
		end
		
	end
	
	def self.to_csv
		aggregate = PastOrdersAggregate.all
		companynumberlist = ["Delivery Date: " + Date.today.to_s, "", "", ""]
		companynames = aggregate.distinct.pluck(:companyname)
		foodnames = aggregate.distinct.pluck(:itemname)
		# for i in 0..3
			# companynames.unshift(" ")
		# end
		companynames.unshift("Grand Total")
		companynames.unshift("Product Name")
		companynames.unshift("Product Code")
		companynames.unshift("NO")
		CSV.generate(headers: true) do |csv|
			
			for i in 1..companynames.length() - 4
				companynumberlist.push(i.to_s)
			end
			csv << companynumberlist
			csv << companynames
			
			
			for food in 0..foodnames.length() - 1
				inputs = [(food+1).to_s, rand(10000..12000), foodnames[food]]
				totalamount = 0
				for company in 3..companynames.length() - 1
					ordercounts = aggregate.where(["companyname = ? and itemname = ?", companynames[company], foodnames[food]])
					puts "This is ordercounts size: " + ordercounts.length().to_s 
					if ordercounts.count == 0
						inputs.push("")
					else
						ordercounts.each do |order|
							inputs.push(order.itemcount)
							totalamount = totalamount + order.itemcount
						end
					end
					puts "THIS IS TOTALAMOUNT: " + totalamount.to_s
				end
				inputs[3] = totalamount.to_s
				totalamount = 0
				puts "This is inputs: " + inputs.to_s
				csv << inputs
				inputs.clear()
			end
		end
	end	
end
