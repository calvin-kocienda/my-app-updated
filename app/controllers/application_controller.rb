class ApplicationController < ActionController::Base
    before_action :authorized
    helper_method :logged_in?
    helper_method :current_user
	helper_method :find_store_history_index
    #after_action :store_history
    
    def current_user   
        User.find_by(id: session[:user_id])
    end

    def logged_in?
        # byebug
        !current_user.nil? && current_user.approved == true
    end

    def authorized
        redirect_to '/welcome' unless logged_in?
    end
	 
	# def store_history
		# session[:history] ||= []
		# if session[:history].size > 3
			# for i in 0..session[:history].size - 3
				# session[:history].shift
			# end
		# end
		# session[:history] << request.url
		# request.session.each do |key, value|
			# puts "SESSION " + key.to_s + ": " + value.to_s
		# end
	# end
	
	def find_store_history_index
		if session[:history][-1].include? "cart"
			puts "THIS IS F_S_H_I OUTPUT: " + "2"
			return 2
		end
		puts "THIS IS F_S_H_I OUTPUT: " + "1"
		return 1
	end
	
	def remove_empty_query_params
		# Rewrites /projects?q=&status=failing to /projects?status=failing
		require 'addressable/uri'
		original = request.original_url
		parsed = Addressable::URI.parse(original)
		return unless parsed.query_values.present?
		queries_with_values = parsed.query_values.reject { |_k, v| v == "0" || v.blank?}
		if queries_with_values.blank?
			parsed.omit!(:query)
		else parsed.query_values = queries_with_values
		end
		redirect_to parsed.to_s unless parsed.to_s == original
    end
	 
	def add_to_cart
		foodincart = ItemsInCart.where(userid: session[:user_id])
		puts "THIS IS ITEMSINCART COUNT: " + foodincart.count.to_s
		query_param = request.query_parameters[:plus_one]
		if query_param != nil
			puts "THIS IS QUERY_PARAM: " + query_param
			puts "Makes it here!"
			itemcheck = foodincart.where(itemid: query_param.to_i).first
			#puts "THIS IS ITEMCHECK: " + itemcheck.itemname.to_s
			if itemcheck != nil
				itemcheck.update_attribute(:itemcount, itemcheck.itemcount + 1)
			else
				id_num = query_param.to_i
				puts "THIS IS ID_NUM: " + id_num.to_s
				food_item = Fooditem.where(id:id_num).first
				itemcheck = foodincart.where(itemid: food_item.id).first
				@item_added_to_cart = ItemsInCart.new(userid: session[:user_id], itemid: food_item.id, itemcount: 1, itemname: food_item.item, price: food_item.price2)
				@item_added_to_cart.save
			end
		end
	end
end