class FriendshipsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:create_from_tokens]
  before_filter :get_user, only: [:create]
  before_filter :get_user_by_email_add, only: [:create_from_tokens]
  before_filter :get_user_by_mobile_no, only: [:create_from_sms]
  before_filter :get_friend, only: [:create]
  rescue_from ActiveRecord::RecordInvalid, with: :email_not_valid
  layout false, only: [:test]
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
    unique_friend_tokens = params[:plain].gsub(/\s+/, "").split(',').to_a
    last_item_index = unique_friend_tokens.size - 1
    #the last item includes all the other crap - signatures, whatever, so we only take the first 5 chars of that item
    unique_friend_tokens[last_item_index] = unique_friend_tokens[last_item_index][0,5]
    friends = User.where('unique_friend_token in (?)', unique_friend_tokens)
    Rails.logger.info "The reply: #{params[:plain]}\n"
    Rails.logger.info "Friend Tokens: #{unique_friend_tokens}\n"
    Rails.logger.info "The user: #{@user.email}\n"
    Rails.logger.info "The friends: #{friends.email}\n"
    friends.each do |friend|
      @user.add_friend(friend)
      @user.shorter_notify_friend(friend)
      Rails.logger.info "#{friend.email}\n"
    end
    respond_to do |format|
      format.html { render text: "Booyakasha"}
    end
  end

  def create_from_sms
    unique_friend_tokens = params[:MESSAGE]
    if unique_friend_tokens
      unique_friend_tokens = params[:MESSAGE].gsub('wmn','').gsub('%20','').gsub('%2E','').gsub(/\s+/, "").split(',').to_a
    end
    @message_id = params[:MESG_ID]
    @mobile_no = params[:MOBILE_NO]
    @resp_code = 'ok'
    unless unique_friend_tokens.blank? || @mobile_no.blank? || @user.nil?
      last_item_index = unique_friend_tokens.size - 1
      #the last item includes all the other crap - signatures, whatever, so we only take the first 5 chars of that item
      unique_friend_tokens[last_item_index] = unique_friend_tokens[last_item_index][0,5]
      friends = User.where('unique_friend_token in (?)', unique_friend_tokens)
      Rails.logger.info "The reply: #{params[:plain]}\n"
      Rails.logger.info "Friend Tokens: #{unique_friend_tokens}\n"
      friends.each do |friend|
        unless friend.nil?
          @user.add_friend(friend)
          @user.shorter_notify_friend(friend)
        end
      end
    end
    respond_to do |format|
      format.html { render text: "CPID=312&MESG_ID=#{@message_id}&RESP_CODE=OK", status: 200 }
    end
  end
  def get_user
    @user = User.find_by_id(params[:user][:id])
    raise ActiveRecord::RecordNotFound unless @user
  end

  def get_user_by_email_add
    email = extract_email(params[:headers]['From'])
 
    @user = User.find_by_email(email)
    Rails.logger.info "User found with email #{email}: #{@user}"
    raise ActiveRecord::RecordNotFound unless @user
  end

  def get_user_by_mobile_no
    Rails.logger.info "The params: #{params.inspect}"
    mobile_no = params[:MOBILE_NO]
    if mobile_no
      mobile_no = mobile_no.gsub(/\s+/,'')
    end
    @user = User.where('phone_mobile = ?',mobile_no).first
    Rails.logger.info "User found with mobile_no #{mobile_no}: #{@user}"
    #raise ActiveRecord::RecordNotFound unless @user
  end

  def extract_email(full_email_add)
    clean_email_start = full_email_add.index("<") + 1
    clean_email_end = full_email_add.index(">") - 1
    clean_email = full_email_add[clean_email_start..clean_email_end]
    Rails.logger.info clean_email
    clean_email
  end

  def get_friend
    @friend = User.find_by_email(params[:user][:email])
    unless @friend
      @friend = User.dummy_create(params[:user][:email])
    end
  end

  def test
    @user = User.first
 
  end

  def test_result
    respond_to do |format|
      format.js { render 'test_result'}
    end
  end

  def email_not_valid
    redirect_to public_user_path(@user), alert: "Your email is invalid dude"
  end
end
