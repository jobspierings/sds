#applications controller
Admin.controllers :applications do

	#get :index do
    	#	@account = current_account
    	#	@apps = SharedDataApplication.by_account(:account => @account.id, :descending => true)
	#	render 'applications/index'
	#end
	
	get :new do
		@application = SharedDataApplication.new
		@contexts = SharedDataContext.all.collect!{|context|context.name}
		render 'applications/new'
	end
	
	post :create do
	    @application = SharedDataApplication.new
	    @application.name = params[:shared_data_application][:name]
	    @application.url = params[:shared_data_application][:url]
	    @application.redirect_url = params[:shared_data_application][:redirect_url]
	    @application.description = params[:shared_data_application][:description]
	    @application.public_key = params[:shared_data_application][:public_key]
	    @application.secret = SecureRandom.hex(11)

	    if(@application.save)
	    	puts "saved stage 1"
	    end

	    @application.account = current_account
	    if(@application.save)
	        puts "saved stage 2"
	    end

	    context = SharedDataContext.find_by_name params[:shared_data_application][:context]
	    if(context != nil)
	    	@application.shared_data_contexts << context
		puts "added context: #{context.name}"
	    end 
		puts "saving app for account:#{@application.account.name}"

	    if @application.save
	      puts "success"
	      flash[:notice] = 'Shared Data Application was successfully created.'
	      redirect url(:applications, :edit, :id => @application.id)
	    else
	      puts "fail"
	      flash[:error] = 'save unsuccesful'
	      render 'applications/new'
	    end
	end

        get :edit, :with => :id do
          @application = SharedDataApplication.get(params[:id])
	  @contexts = @application.shared_data_contexts.collect!{|c|c.name}
	  puts @application.secret
          render 'applications/edit'
        end
      
        put :update, :with => :id do
          @application = SharedDataApplication.get(params[:id])
	  #puts @application.account.name

	  @contexts = @application.shared_data_contexts.collect!{|c|c.name}

	  @application.name = params[:shared_data_application][:name]
	  @application.url = params[:shared_data_application][:url]
	  @application.redirect_url = params[:shared_data_application][:redirect_url]
	  @application.description = params[:shared_data_application][:description]
	  @application.public_key = params[:shared_data_application][:public_key]
	  @application.account = current_account
	  
	  if @application.update
            flash[:notice] = 'Shared Data Application was successfully updated.'
            redirect url(:applications, :edit, :id => @application.id)
          else
	    flash[:error] = "#{@application.errors.first}" 
            render 'applications/edit'
          end
        end

	delete :destroy, :with => :id do
	  context = SharedDataApplication.get(params[:id])
	  if context.destroy
	    flash[:notice] = 'Shared Data Application was successfully destroyed.'
	  else
	    flash[:error] = 'Unable to destroy Shared Data Application!'
	  end
	  redirect url(:developers, :index)
	end
end
