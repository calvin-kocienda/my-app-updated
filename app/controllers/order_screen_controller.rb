require 'csv'
require 'sendgrid-ruby'
include SendGrid

class OrderScreenController < ApplicationController
  before_action :remove_empty_query_params
  #after_action :add_to_session_history
  helper_method :calculate_value_of_num_field
  def landing_screen
	@foodincart = ItemsInCart.where(["userid = ? and display = ?", session[:user_id], true])
	@num_items_in_cart = calculate_value_of_num_food_in_cart()
	delete_display_false_items()
  end

  def index


	@userid = session[:user_id]
	flag = false
	#session[:current_sort] = "All"
	@fooditems = Fooditem.all
	@companies = Company.all
	#@companies_for_user = CompaniesToUser.where(user_id: @userid)
	#@company_menu_items = []
	#@companies_for_user.each do |company|
	#	@company_menu_items.push(@companies.where(id:company.company_id).first.companyname)
	#end
	puts "THIS IS COMPANIES FOR USER: " + @companies_for_user.to_s

	
	
	#PastOrdersUser.delete_all
	#PastOrdersAggregate.delete_all

	
	if request.query_parameters[:sort] != nil && request.query_parameters[:sort] == "Fruit_All"
		@fooditems = Fooditem.where(category: "Fruit")
		session[:current_sort] = "Fruit_All"
	elsif request.query_parameters[:sort] != nil && request.query_parameters[:sort] == "Fruit_Fruit"
		@fooditems = Fooditem.where(["category = ? and subcategory = ?", "Fruit", "Fruit"])
		session[:current_sort] = "Fruit_Fruit"
	elsif request.query_parameters[:sort] != nil && request.query_parameters[:sort] == "Fruit_Juice"
		@fooditems = Fooditem.where(["category = ? and subcategory = ?", "Fruit", "Juice"])
		session[:current_sort] = "Fruit_Juice"
	elsif request.query_parameters[:sort] != nil && request.query_parameters[:sort] == "Fruit_Other"
		@fooditems = Fooditem.where(["category = ? and subcategory = ?", "Fruit", "Other"])
		session[:current_sort] = "Fruit_Other"
	elsif request.query_parameters[:sort] != nil && request.query_parameters[:sort] == "Vegetable_All"
		@fooditems = Fooditem.where(category: "Vegetable")
		session[:current_sort] = "Vegetable_All"
	elsif request.query_parameters[:sort] != nil && request.query_parameters[:sort] == "Vegetable_Root"
		@fooditems = Fooditem.where(["category = ? and subcategory = ?", "Vegetable", "Root"])
		session[:current_sort] = "Vegetable_Root"
	elsif request.query_parameters[:sort] != nil && request.query_parameters[:sort] == "Vegetable_Legume"
		@fooditems = Fooditem.where(["category = ? and subcategory = ?", "Vegetable", "Legume"])
		session[:current_sort] = "Vegetable_Legume"
	elsif request.query_parameters[:sort] != nil && request.query_parameters[:sort] == "Vegetable_Other"
		@fooditems = Fooditem.where(["category = ? and subcategory = ?", "Vegetable", "Other"])
		session[:current_sort] = "Vegetable_Other"
	elsif request.query_parameters[:sort] != nil && request.query_parameters[:sort] == "Other_All"
		@fooditems = Fooditem.where(category: "Other")
		session[:current_sort] = "Other_All"
	elsif request.query_parameters[:sort] != nil && request.query_parameters[:sort] == "Other_Fish"
		@fooditems = Fooditem.where(["category = ? and subcategory = ?", "Other", "Fish"])
		session[:current_sort] = "Other_Fish"
	elsif request.query_parameters[:sort] != nil && request.query_parameters[:sort] == "Other_Drink"
		@fooditems = Fooditem.where(["category = ? and subcategory = ?", "Other", "Drink"])
		session[:current_sort] = "Other_Drink"
	elsif request.query_parameters[:sort] != nil && request.query_parameters[:sort] == "Other_Cookie"
		@fooditems = Fooditem.where(["category = ? and subcategory = ?", "Other", "Cookie"])
		session[:current_sort] = "Other_Cookies"
	elsif request.query_parameters[:sort] != nil && request.query_parameters[:sort] == "All_All"
		@fooditems = Fooditem.all
		session[:current_sort] = "All_All"
	end
	
	
	@foodincart = ItemsInCart.where(["userid = ? and display = ?", @userid, true])
	@foodincartcosts = @foodincart.select("itemcost")
	@foodintempcart = TempCart.where(user_id: session[:user_id])
	@numitems = Fooditem.count
	@currentime = Time.now.utc
	@doeschinadisplay = true#(@currentime.hour >= 12 && @currentime.hour < 19) 


	

	request.query_parameters.each do |key, value|
		if request.query_parameters.keys.include? "commit"
			flag = true
		end	
	
		if key == "i"
			@foodincart.each do |iteritem|
				cart_item = Fooditem.where(id:iteritem.itemid).first
				newcount = cart_item.count + iteritem.itemcount
				cart_item.update_attribute(:count, newcount)
				@foodincart.delete(iteritem)
			end
			@totalprice = 0
		end
		
	
		
		if flag == true and  key.to_s.include? "add_to_cart"
		 	if value[0] != "" && value[0].to_i > 0
				puts "THIS IS KEY: " + key
				puts "THIS IS KEY SPLICE: " + key.to_s[11..]
				id_num = key.to_s[12..].to_i
				puts "THIS IS ID NUM: " + id_num.to_s
				food_item = Fooditem.where(id:id_num).first
				itemcheck = @foodincart.where(itemid: food_item.id).first
				newcount = food_item.count - value[0].to_i
				if newcount >= 0
					if @foodincart.where(itemid: food_item.id).count > 0
						newvalue = itemcheck.itemcount + value[0].to_i
						@foodincart.where(itemid: food_item.id).first.update_attribute(:itemcount, newvalue)
					else
						@item_added_to_cart = ItemsInCart.new(userid: @userid, itemid: food_item.id, itemcount: value[0].to_i, itemname: food_item.item, price: food_item.price2, companyname: food_item.company, display: true)
						@item_added_to_cart.save
					end
					food_item.update_attribute(:count, newcount)
				else
					flash[:error] = "There is not enough of this item left in stock"
				end
			else
				puts "Goes inside flash block"
				flash[:error] = "You cannot add a negative number of an item to your cart."	
			end
			@foodintempcart.delete_all
		end
		
		if key == "plus_one" && flag == false
			itemcheck = @foodintempcart.where(item_id: value.to_i).first
			if itemcheck != nil
				itemcheck.update_attribute(:itemcount, itemcheck.itemcount + 1)
			else
				id_num = value[0..].to_i
				food_item = Fooditem.where(id:id_num).first
				@item_added_to_temp = TempCart.new(user_id: session[:user_id], item_id: food_item.id, itemcount: 1)
				@item_added_to_temp.save
			end
		end
	end

	
	if request.query_parameters[:company_name] != nil
		puts "THIS IS COUNT " + @fooditems.where(company: params[:company_name]).count.to_s
		
		@fooditems = @fooditems.where(company: params[:company_name])
	end

	iter = 0
	@totalprice = 0
	flag = false
	@foodincart.each do |key|
		@totalprice = @totalprice + (key.price * key.itemcount)
	end
	session.to_hash.each do |key|
		puts "THIS IS SESSION CONTENT: " + key.to_s
	end

	#@fooditems = @fooditems.where(show:true, company:@company_menu_items)
	@num_items_in_cart = calculate_value_of_num_food_in_cart()
  end
  
  def checkout
  	@foodincart = ItemsInCart.where(["userid = ? and display = ?", session[:user_id], true])
	@totalprice = 0
	@foodincart.each do |key|
		@totalprice = @totalprice + (key.price * key.itemcount)
	end
	@num_items_in_cart = calculate_value_of_num_food_in_cart()
	get_associated_company_ids = CompaniesToUser.where(user_id:session[:user_id]).distinct.pluck(:company_id)
	@companynames = []
	get_associated_company_ids.each do |key|
		@companynames.push(Company.where(id:key).first.companyname)
	end
	add_to_session_history(page: "checkout")
  end
  
  def import
	
	PastOrdersAggregate.import(params[:file])
	redirect_to '/past_orders_aggregate'
  end
  
  
  def import_food_items
	Fooditem.import(params[:file])
	redirect_to root_path
  end
 
    def export
	@itemsincart = ItemsInCart.where(["userid = ? and display = ?", session[:user_id], true])
	@userid = session[:user_id]
	@pastordersuser = PastOrdersUser.all
	@pastordersaggregate = PastOrdersAggregate.all
	
	@itemsincart.each do |key|
		number_for_past_orders_user = 0
		if @pastordersaggregate.where(["userid = ? and itemname = ? and created_at > ? and companyname = ?", @userid, key.itemname, 24.hours.ago, params[:company_order]]).count == 0
			 @item_added_to_aggregate_history = PastOrdersAggregate.new(userid: @userid, username: current_user.username, companyname: params[:company_order],  itemcount: key.itemcount, itemname: key.itemname)
			 if @item_added_to_aggregate_history.save
				 puts "Saved!"
			 else
				 render :new
			 end
			 number_for_past_orders_user = @item_added_to_aggregate_history.id
		 else
			 aggregate_item = PastOrdersAggregate.where(["userid = ? and itemname = ?", @userid, key.itemname]).first
			 aggregate_item.update_attribute(:itemcount, aggregate_item.itemcount + key.itemcount)
			 number_for_past_orders_user = aggregate_item.id
		 end
		 
		#puts "THIS IS NUMBER_FOR_PAST_ORDERS_USER: " + number_for_past_orders_user.to_s
		#puts "THIS IS THE ACTUAL POA ID: " + @item_added_to_aggregate_history.id.to_s
		
		if @pastordersuser.where(["userid = ? and itemid = ? and created_at > ? and companyname = ?", @userid, key.itemid, 24.hours.ago, params[:company_order]]).count == 0
			@item_added_to_user_history = PastOrdersUser.new(userid: @userid, itemid: key.itemid, itemcount: key.itemcount, itemname: key.itemname, itemcost: key.price, companyname: params[:company_order], poanum:number_for_past_orders_user)

			if @item_added_to_user_history.save
				
				puts "Saved!"
			else
				render :new
			end
		
		 else
			 user_item = PastOrdersUser.where(["userid = ? and itemid = ?", @userid, key.itemid]).first
			 user_item.update_attribute(:itemcount, user_item.itemcount + key.itemcount)
		 end

		#key.destroy
		key.update_attribute(:display, false)
		@num_items_in_cart = calculate_value_of_num_food_in_cart()
		number_for_past_orders_user = 0
	end 
  end
   def export_csv
  	@itemsincart = ItemsInCart.where(["userid = ? and display = ?", session[:user_id], false])
  	respond_to do |format|
		format.html
		format.csv { send_data @itemsincart.to_csv, filename: "fooditems-#{Date.today}.csv" }
	end
	@itemsincart.delete_all
  end
  
  def export_aggregate_csv
    @currentime = Time.now.utc
	@aggregate_orders = PastOrdersAggregate.where('updated_at > ?', 24.hours.ago)
	puts "THIS IS AGGREGATE ORDERS: " + @aggregate_orders.first.itemname
	
	respond_to do |format|
		format.html
		format.csv {send_data @aggregate_orders.to_csv, filename: "aggregate_orders_from_-#{Date.today}.csv"}
	end
  end
  
  def select_screen
	
  end
  
  def modify
  	@foodincart = ItemsInCart.where(["userid = ? and display = ?", session[:user_id], true])
	@fooditems = Fooditem.all
	@categories = ["Fruit", "Vegetable", "Other"]
	@fooditem = Fooditem.first
	@num_items_in_cart = calculate_value_of_num_food_in_cart()
	request.query_parameters.each do |key, value|
		if key == "show"
			getitem = @fooditems.find(value[0].to_i)
			newvalue = !getitem.show
			getitem.update_attribute(:show, newvalue)
		end
		if key == "delete"
			getitem = @fooditems.find(value[0].to_i)
			getitem.delete
		end
		if key.include? "change_price"
			id_num = key.to_s[12..].to_i
			getitem = @fooditems.find(id_num)
			getitem.update_attribute(:price2, value[0].to_d)
		end
		if key.include? "categoryy"
			puts "THIS IS KEY: " + key.to_s
			id_num = key.to_s[9..].to_i
			puts "THIS IS ID_NUM:  " + id_num.to_s
			getitem = @fooditems.find(id_num)
			puts "THIS IS GETITEM: " + getitem.item
			getitem.update_attribute(:category, value[0..])
			puts "THIS IS NEW CATEGORY: " + getitem.category
		end
		if key.include? "stock"
			id_num = key.to_s[5..].to_i
			getitem = @fooditems.find(id_num)
			getitem.update_attribute(:count, value[0].to_i)
		end
		if key.include? "subcategory"
			id_num = key.to_s[11..].to_i
			getitem = @fooditems.find(id_num)
			getitem.update_attribute(:subcategory, value)
		end
	end

  end
  
  def past_orders_user
  	@foodincart = ItemsInCart.where(["userid = ? and display = ?", session[:user_id], true])
	@past_orders_user = PastOrdersUser.where(userid: session[:user_id])
	@num_items_in_cart = calculate_value_of_num_food_in_cart()
  		if params[:past_orders_user] != nil
		params[:past_orders_user].each do |key, value|
			if key.include? "damage"
				id_num = key[6..].to_i
				getitem = @past_orders_user.where(id:id_num).first
				getitem.damage_report.attach(value)
				getpoa = PastOrdersAggregate.where(id:getitem.poanum).first
				getpoa.damage_report.attach(value)
			elsif key.include? "exp"
				id_num = key[3..].to_i
				getitem = @past_orders_user.where(id:id_num).first
				getitem.explanation.attach(value)
				getpoa = PastOrdersAggregate.where(id:getitem.poanum).first
				getpoa.explanation.attach(value)
			end
		end

	end
  end
  
  def past_orders_aggregate
  	@foodincart = ItemsInCart.where(["userid = ? and display = ?", session[:user_id], true])
	@currentime = Time.now.utc
	puts "THIS IS THE CURRENT TIMEZONE: " + @currentime.utc.to_s
	company_to_display = request.query_parameters[:company_name]
	if company_to_display == "All" || company_to_display == nil
		@past_orders_aggregate = PastOrdersAggregate.all
	else
		@past_orders_aggregate = PastOrdersAggregate.where(companyname:company_to_display)
	end
	
	#if request.query_parameters[:confirm_order] != nil 
	#	puts "Made it inside past orders"
	#	PastOrdersAggregate.find(request.query_parameters[:confirm_order].to_i).update_attribute(:status, "Confirmed")
	#else request.query_parameters[:cancel_order] != nil 
	#	puts "Made it inside past orders"
	#	PastOrdersAggregate.find(request.query_parameters[:cancel_order].to_i).update_attribute(:status, "Cancelled")
	#end
	@companies = Company.all
	@companynames = @companies.distinct.pluck(:companyname)
	#@companynames.unshift("All")
	session[:aggregate_company_name] = company_to_display
	# @companies_for_user = CompaniesToUser.where(user_id: session[:user_id])
	# @company_menu_items = []
	# @companies_for_user.each do |company|
		# @company_menu_items.push(@companies.where(id:company.company_id).first.companyname)
	# end
	@num_items_in_cart = calculate_value_of_num_food_in_cart()
	if params[:past_orders_aggregate] != nil
		params[:past_orders_aggregate].each do |key, value|
			if key.include? "damage"
				id_num = key[6..].to_i
				getitem = @past_orders_aggregate.where(id:id_num).first
				getitem.damage_report.attach(value)

			elsif key.include? "exp"
				id_num = key[3..].to_i
				getitem = @past_orders_aggregate.where(id:id_num).first
				getitem.explanation.attach(value)
			end
		end

	end


  end
  

  def show_past_orders_aggregate_image
	@image = PastOrdersAggregate.find(params[:poaid])
  end
  def show_past_orders_aggregate_explanation
	@image = PastOrdersAggregate.find(params[:expid])
  end

  def show_past_orders_user_image
	@image = PastOrdersUser.find(params[:poaid])
  end
  def show_past_orders_user_explanation
	@image = PastOrdersUser.find(params[:expid])
  end


  def newarrivals
	@fooditems = Fooditem.where('updated_at > ?', 24.hours.ago)
	@foodincart = ItemsInCart.where(["userid = ? and display = ?", session[:user_id], true])
	remove_empty_query_params()
	flag = false
	@foodintempcart = TempCart.where(user_id: session[:user_id])

	request.query_parameters.each do |key, value|
	
		if request.query_parameters.keys.include? "commit"
			flag = true
		end
		if key == "i"
			@foodincart.each do |iteritem|
				@foodincart.delete(iteritem)
			end
			@totalprice = 0
		end
		
		if key == "plus_one" && flag == false
			itemcheck = @foodintempcart.where(item_id: value.to_i).first
			if itemcheck != nil
				itemcheck.update_attribute(:itemcount, itemcheck.itemcount + 1)
			else
				id_num = value.to_i

				food_item = Fooditem.where(id:id_num).first
				#itemcheck = foodincart.where(itemid: food_item.id).first
				@item_added_to_temp = TempCart.new(user_id: session[:user_id], item_id: food_item.id, itemcount: 1)
				@item_added_to_temp.save	
			end
		end
		if flag == true and key.to_s.include? "add_to_cart"
			if value[0] != "" && value[0].to_i > 0

				id_num = key.to_s[12..].to_i

				food_item = Fooditem.where(id:id_num).first
				itemcheck = @foodincart.where(itemid: food_item.id).first
				if @foodincart.where(itemid: food_item.id).count > 0
					newvalue = itemcheck.itemcount + value[0].to_i
					@foodincart.where(itemid: food_item.id).first.update_attribute(:itemcount, newvalue)
				else
					@item_added_to_cart = ItemsInCart.new(userid: session[:user_id], itemid: food_item.id, itemcount: value[0].to_i, itemname: food_item.item, price: food_item.price2, companyname: food_item.company, display: true)
					@item_added_to_cart.save
				end
			else

				flash[:error_newarrival] = "You cannot add a negative number of an item to your cart."	
			end
			@foodintempcart.delete_all
		end

	end
	flag = false
	@num_items_in_cart = calculate_value_of_num_food_in_cart
	add_to_session_history(page: "search")
  end

  def search
	
  	@foodincart = ItemsInCart.where(["userid = ? and display = ?", session[:user_id], true])
	remove_empty_query_params()
	flag = false
	@foodintempcart = TempCart.where(user_id: session[:user_id])
	if params[:search].blank?  
		redirect_to session[:history][-1] and return
	else
		@parameter = params[:search].downcase  
		@results = Fooditem.all.where("lower(item) LIKE :search", search: "%#{@parameter}%") 
	end

	request.query_parameters.each do |key, value|
	
		if request.query_parameters.keys.include? "commit"
			flag = true
		end
		if key == "i"
			@foodincart.each do |iteritem|
				@foodincart.delete(iteritem)
			end
			@totalprice = 0
		end
		
		if key == "plus_one" && flag == false
			itemcheck = @foodintempcart.where(item_id: value.to_i).first
			if itemcheck != nil
				itemcheck.update_attribute(:itemcount, itemcheck.itemcount + 1)
			else
				id_num = value.to_i

				food_item = Fooditem.where(id:id_num).first
				#itemcheck = foodincart.where(itemid: food_item.id).first
				@item_added_to_temp = TempCart.new(user_id: session[:user_id], item_id: food_item.id, itemcount: 1)
				@item_added_to_temp.save	
			end
		end
		if flag == true and key.to_s.include? "add_to_cart"
			if value[0] != "" && value[0].to_i > 0

				id_num = key.to_s[12..].to_i

				food_item = Fooditem.where(id:id_num).first
				itemcheck = @foodincart.where(itemid: food_item.id).first
				if @foodincart.where(itemid: food_item.id).count > 0
					newvalue = itemcheck.itemcount + value[0].to_i
					@foodincart.where(itemid: food_item.id).first.update_attribute(:itemcount, newvalue)
				else
					@item_added_to_cart = ItemsInCart.new(userid: session[:user_id], itemid: food_item.id, itemcount: value[0].to_i, itemname: food_item.item, price: food_item.price2, companyname: food_item.company, display: true)
					@item_added_to_cart.save
				end
			else

				flash[:error] = "You cannot add a negative number of an item to your cart."	
			end
			@foodintempcart.delete_all
		end

	end
	flag = false
	@num_items_in_cart = calculate_value_of_num_food_in_cart
	add_to_session_history(page: "search")
  end
  def landing_screen_modify
  end
  
  def landing_screen_fruit
    remove_empty_query_params()
	flag = false
	@foodincart = ItemsInCart.where(["userid = ? and display = ?", session[:user_id], true])
	@foodintempcart = TempCart.where(user_id: session[:user_id])
	@fruit = Fooditem.where(["category = ? and subcategory = ? and show = ?", "Fruit", "Fruit", true])
	@juices = Fooditem.where(["category = ? and subcategory = ? and show = ?", "Fruit", "Juice", true])
	@other = Fooditem.where(["category = ? and subcategory = ? and show = ?", "Fruit", "Other", true])
	foodincart = ItemsInCart.where(["userid = ? and display = ?", session[:user_id], true])
	puts "THIS IS ITEMSINCART COUNT: " + foodincart.count.to_s
	request.query_parameters.each do |key, value|
	
		if request.query_parameters.keys.include? "commit"
			flag = true
		end
		if key == "i"
			@foodincart.each do |iteritem|
				cart_item = Fooditem.where(id:iteritem.itemid).first
				newcount = cart_item.count + iteritem.itemcount
				cart_item.update_attribute(:count, newcount)
				@foodincart.delete(iteritem)
			end
			@totalprice = 0
		end
		
		if key == "plus_one" && flag == false
			itemcheck = @foodintempcart.where(item_id: value.to_i).first
			if itemcheck != nil
				itemcheck.update_attribute(:itemcount, itemcheck.itemcount + 1)
			else
				id_num = value.to_i
				puts "THIS IS ID_NUM: " + id_num.to_s
				food_item = Fooditem.where(id:id_num).first
				#itemcheck = foodincart.where(itemid: food_item.id).first
				@item_added_to_temp = TempCart.new(user_id: session[:user_id], item_id: food_item.id, itemcount: 1)
				@item_added_to_temp.save	
			end
		end
		if flag == true and key.to_s.include? "add_to_cart"
			if value[0] != "" && value[0].to_i > 0
				puts "THIS IS KEY: " + key
				puts "THIS IS KEY SPLICE: " + key.to_s[11..]
				id_num = key.to_s[12..].to_i
				puts "THIS IS ID NUM: " + id_num.to_s
				food_item = Fooditem.where(id:id_num).first
				itemcheck = @foodincart.where(itemid: food_item.id).first
				newcount = food_item.count - value[0].to_i
				
				if newcount >= 0
					
					if @foodincart.where(itemid: food_item.id).count > 0
						newvalue = itemcheck.itemcount + value[0].to_i
						@foodincart.where(itemid: food_item.id).first.update_attribute(:itemcount, newvalue)
					else
						@item_added_to_cart = ItemsInCart.new(userid: session[:user_id], itemid: food_item.id, itemcount: value[0].to_i, itemname: food_item.item, price: food_item.price2, companyname: food_item.company, display: true)
						@item_added_to_cart.save
					end
					food_item.update_attribute(:count, newcount)
				else
					flash[:error] = "There is not enough of this item left in stock"
				end
			else
				puts "Goes inside flash block"
				flash[:error] = "You cannot add a negative number of an item to your cart."	
			end
			@foodintempcart.delete_all
		end

	end
	flag = false
	@num_items_in_cart = calculate_value_of_num_food_in_cart
  end
  def landing_screen_vegetable
    remove_empty_query_params()
	flag = false
	@foodincart = ItemsInCart.where(["userid = ? and display = ?", session[:user_id], true])
	@foodintempcart = TempCart.where(user_id: session[:user_id])
	@root = Fooditem.where(["category = ? and subcategory = ? and show = ?", "Vegetable", "Root", true])
	@legume = Fooditem.where(["category = ? and subcategory = ? and show = ?", "Vegetable", "Legume", true])
	@other = Fooditem.where(["category = ? and subcategory = ? and show = ?", "Vegetable", "Other", true])
	request.query_parameters.each do |key, value|
	
		if request.query_parameters.keys.include? "commit"
			flag = true
		end
		if key == "i"
			@foodincart.each do |iteritem|
				@foodincart.delete(iteritem)
			end
			@totalprice = 0
		end
		
		if key == "plus_one" && flag == false
			itemcheck = @foodintempcart.where(item_id: value.to_i).first
			if itemcheck != nil
				itemcheck.update_attribute(:itemcount, itemcheck.itemcount + 1)
			else
				id_num = value.to_i
				puts "THIS IS ID_NUM: " + id_num.to_s
				food_item = Fooditem.where(id:id_num).first
				#itemcheck = foodincart.where(itemid: food_item.id).first
				@item_added_to_temp = TempCart.new(user_id: session[:user_id], item_id: food_item.id, itemcount: 1)
				@item_added_to_temp.save	
			end
		end
		if flag == true and key.to_s.include? "add_to_cart"
			if value[0] != "" && value[0].to_i > 0
				puts "THIS IS KEY: " + key
				puts "THIS IS KEY SPLICE: " + key.to_s[11..]
				id_num = key.to_s[12..].to_i
				puts "THIS IS ID NUM: " + id_num.to_s
				food_item = Fooditem.where(id:id_num).first
				itemcheck = @foodincart.where(itemid: food_item.id).first
				newcount = food_item.count - value[0].to_i
				if newcount >= 0
					if @foodincart.where(itemid: food_item.id).count > 0
						newvalue = itemcheck.itemcount + value[0].to_i
						@foodincart.where(itemid: food_item.id).first.update_attribute(:itemcount, newvalue)
					else
						@item_added_to_cart = ItemsInCart.new(userid: session[:user_id], itemid: food_item.id, itemcount: value[0].to_i, itemname: food_item.item, price: food_item.price2, companyname: food_item.company, display: true)
						@item_added_to_cart.save
					end
					food_item.update_attribute(:count, newcount)
				else
					flash[:error] = "There is not enough of this item left in stock"
				end
			else
				puts "Goes inside flash block"
				flash[:error] = "You cannot add a negative number of an item to your cart."	
			end
			@foodintempcart.delete_all
		end

	end
	flag = false
	@num_items_in_cart = calculate_value_of_num_food_in_cart()
	puts "THIS IS THE AMOUNT OF FOOD IN CART: " + @num_items_in_cart.to_s
  end
  def landing_screen_other
    remove_empty_query_params()
	flag = false
	@foodincart = ItemsInCart.where(["userid = ? and display = ?", session[:user_id], true])
	@foodintempcart = TempCart.where(user_id: session[:user_id])
	@fish = Fooditem.where(["category = ? and subcategory = ? and show = ?", "Other", "Fish", true])
	@drink = Fooditem.where(["category = ? and subcategory = ? and show = ?", "Other", "Drink", true])
	@cookie = Fooditem.where(["category = ? and subcategory = ? and show = ?", "Other", "Cookie", true])
	request.query_parameters.each do |key, value|
	
		if request.query_parameters.keys.include? "commit"
			flag = true
		end
		if key == "i"
			@foodincart.each do |iteritem|
				@foodincart.delete(iteritem)
			end
			@totalprice = 0
		end
		
		if key == "plus_one" && flag == false
			itemcheck = @foodintempcart.where(item_id: value.to_i).first
			if itemcheck != nil
				itemcheck.update_attribute(:itemcount, itemcheck.itemcount + 1)
			else
				id_num = value.to_i
				puts "THIS IS ID_NUM: " + id_num.to_s
				food_item = Fooditem.where(id:id_num).first
				#itemcheck = foodincart.where(itemid: food_item.id).first
				@item_added_to_temp = TempCart.new(user_id: session[:user_id], item_id: food_item.id, itemcount: 1)
				@item_added_to_temp.save	
			end
		end
		if flag == true and key.to_s.include? "add_to_cart"
			if value[0] != "" && value[0].to_i > 0
				puts "THIS IS KEY: " + key
				puts "THIS IS KEY SPLICE: " + key.to_s[11..]
				id_num = key.to_s[12..].to_i
				puts "THIS IS ID NUM: " + id_num.to_s
				food_item = Fooditem.where(id:id_num).first
				itemcheck = @foodincart.where(itemid: food_item.id).first
				newcount = food_item.count - value[0].to_i
				if newcount >= 0
					if @foodincart.where(itemid: food_item.id).count > 0
						newvalue = itemcheck.itemcount + value[0].to_i
						@foodincart.where(itemid: food_item.id).first.update_attribute(:itemcount, newvalue)
					else
						@item_added_to_cart = ItemsInCart.new(userid: session[:user_id], itemid: food_item.id, itemcount: value[0].to_i, itemname: food_item.item, price: food_item.price2, companyname: food_item.company, display: true)
						@item_added_to_cart.save
					end
					food_item.update_attribute(:count, newcount)
				else
					flash[:error] = "There is not enough of this item left in stock"
				end
			else
				puts "Goes inside flash block"
				flash[:error] = "You cannot add a negative number of an item to your cart."
			end
			@foodintempcart.delete_all
		end

	end
	flag = false
	@num_items_in_cart = calculate_value_of_num_food_in_cart()
  end
  
  def cart
	delete_display_false_items()
	@foodincart = ItemsInCart.where(["userid = ? and display = ?", session[:user_id], true])
	@totalprice = 0
	if request.query_parameters[:i] != nil
		if request.query_parameters[:item] != nil
			@foodincart.where(id: request.query_parameters[:item]).first.delete
		else
			@foodincart.each do |iteritem|
				@foodincart.delete(iteritem)
			end
			@totalprice = 0
			return
		end


	end
	@foodincart.each do |key|
		@totalprice = @totalprice + (key.price * key.itemcount)
	end
	@num_items_in_cart = @foodincart.count
	add_to_session_history(page: "cart")
  end
  
  def approve_user
	@users = User.where(approved: false)
	if params[:approve] != nil
		find_user = User.where(id: params[:approve]).first
		find_user.update_attribute(:approved, true)
		flash[:approve_user_flash] = "User Approved!"
	elsif params[:deny] != nil
		find_user = User.where(id: params[:deny]).first
		#puts "THIS IS ID: " + find_user.id
		User.where(id:find_user.id).first.delete
		flash[:approve_user_flash] = "User Deleted!"
	end
  end

   def test_screen
        remove_empty_query_params()
		@fooditems = Fooditem.all
   end

   def faq_screen
   		@foodincart = ItemsInCart.where(["userid = ? and display = ?", session[:user_id], true])
		@num_items_in_cart = calculate_value_of_num_food_in_cart()
		delete_display_false_items()
   end
  
   def calculate_value_of_num_field(item_id)
		item = TempCart.where(["user_id = ? and item_id = ? and created_at > ?", session[:user_id], item_id, 24.hours.ago])
		if item.count == 0
			return 0
		end
		return item.first.itemcount
   end
   
   def calculate_value_of_num_food_in_cart
		foodincart = ItemsInCart.where(["userid = ? and display = ?", session[:user_id], true])
		puts "THIS IS THE SIZE OF FOODINCART: " + foodincart.count.to_s
		if foodincart != nil
			return foodincart.count
		end
		return 0
   end
   
   def add_to_session_history(page)
		if request.referrer.to_s.include? "172.104.174.221/" + page[:page].to_s
			puts "Does nothing"
		else
			session[:history] ||= []
			session[:history].push(request.referrer)

		end
		if session[:history].size > 1
			session[:history].shift
		end
		request.session.each do |key, value|
			puts "SESSION " + key.to_s + ": " + value.to_s
		end
   end
   
   def delete_display_false_items
		@foodincart = ItemsInCart.where(["userid = ? and display = ?", session[:user_id], false])
		@foodincart.each do |item|
			item.delete
		end
   end
  
end



