class FriendshipsController < ApplicationController
  before_filter :get_user, only: [:create, :create_from_tokens]
  before_filter :get_friend, only: [:create]
  rescue_from ActiveRecord::RecordInvalid, with: :email_not_valid
  def create
    @user.add_friend(@friend)
    @user.notify_friend(@friend)

    if request.xhr?
      head :ok
    else
      redirect_to public_user_path(@user), notice: notice
    end
  end

  def create_from_tokens
    unique_friend_tokens = params[:reply_plain].split(',').to_a
    friends = User.where('unique_friend_token in (?)', unique_friend_tokens)

    friends.each do |friend|
      @user.add_friend(friend)
      @user.notify_friend(friend)
    end

    if request.xhr?
      head :ok
    else
      redirect_to public_user_path(@user), notice: notice
    end
  end

  def get_user
    @user = User.find_by_id(params[:user][:id])
    raise ActiveRecord::RecordNotFound unless @user
  end

  def get_friend
    @friend = User.find_by_email(params[:user][:email])
    unless @friend
      @friend = User.dummy_create(params[:user][:email])
    end
  end

  def email_not_valid
    redirect_to public_user_path(@user), alert: "Your email is invalid dude"
  end
end
