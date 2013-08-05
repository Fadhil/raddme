class UserMailer < ActionMailer::Base
  default from: "just@radd.me"

  def exchanged_unregistered(user, friend)
    setup_mail(user, friend)
  end

  def exchanged(user, friend)
    setup_mail(user, friend)
  end

  def setup_mail(user, friend)
    @user = user
    @friend = friend
    attachments["#{user.friendly_id}.vcf"] = user.vcard.to_s
    mail(to: friend.email, reply_to: user.email, subject: "Here's #{@user.fullname} details on Radd.me")
  end

  def welcome_new_user(user,password)
    @user = user
    @password = password
    mail(to: user.email, subject: "You've been registered on radd.me")
  end
end
