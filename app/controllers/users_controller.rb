class UsersController < ApplicationController

def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        
         UserMailer.welcome_email(@user).deliver
         UserMailer.query_mail(@user).deliver

        format.html { redirect_to :back }
        #flash.now[:notice] = 'Thank you for your message. We will contact you soon!'
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
 end

  private
  
 def user_params
  params.require(:user).permit(:name, :email, :phone,:message)
end

end
