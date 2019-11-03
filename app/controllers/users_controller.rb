class UsersController < ApplicationController
  def index
    @users = User.all
  end
  
  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end
  
  def create 
    auth_hash = request.env["omniauth.auth"]
    
    user = User.find_by(uid: auth_hash[:uid], provider: "github")
    if user
      # User was found in the database
      flash[:success] = "Logged in as returning user #{user.name}"
    else
      # User doesn't match anything in the DB -> create a new user
      user = User.build_from_github(auth_hash)
      
      if user.save
        flash[:success] = "Logged in as new user #{user.name}"
      else
        # Couldn't save the user for some reason. If we
        # hit this it probably means there's a bug with the
        # way we've configured GitHub. Our strategy will
        # be to display error messages to make future
        # debugging easier.
        flash[:error] = "Could not create new user account: #{user.errors.full_messages}"
        return redirect_to root_path
      end
    end
    
    # If we get here, we have a valid user instance
    session[:user_id] = user.id
    return redirect_to root_path
  end
  
  def logout
    if session[:user_id]
      session[:user_id] = nil
      flash[:success] = "Successfully logged out!"
      return redirect_to root_path
    else
      flash[:error] = "How can you log out when you ain't even logged in to begin with?"
      return redirect_to root_path
    end
  end
  
end




### REPLACED BY GITHUB LOGIN
# def login_form
#   end

#   def login
#     username = params[:username]
#     if username and user = User.find_by(username: username)
#       session[:user_id] = user.id
#       flash[:status] = :success
#       flash[:result_text] = "Successfully logged in as existing user #{user.username}"
#     else
#       user = User.new(username: username)
#       if user.save
#         session[:user_id] = user.id
#         flash[:status] = :success
#         flash[:result_text] = "Successfully created new user #{user.username} with ID #{user.id}"
#       else
#         flash.now[:status] = :failure
#         flash.now[:result_text] = "Could not log in"
#         flash.now[:messages] = user.errors.messages
#         render "login_form", status: :bad_request
#         return
#       end
#     end
#     redirect_to root_path
#   end