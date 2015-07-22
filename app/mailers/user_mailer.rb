class UserMailer < ActionMailer::Base
  default from: "info@codestains.com"

  def welcome_email(user)
    @user = user
    #attachments["garb.jpg"] = File.read("#{Rails.root}/public/assets/garb.jpg")
    mail(to: @user.email, subject: 'Welcome to Codestains')
  end

   def query_mail(user)
  	@user=user
    mail(:to => "info@codestains.com", :subject => "Getting Quote")
   end
end
