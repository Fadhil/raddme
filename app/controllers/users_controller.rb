class UsersController < ApplicationController
  before_filter :authenticate_user!, except: [:show, :import, :generate_users]
  before_filter :get_user, only: [:show]
  before_filter :http_authenticate, only: [:import]

  def show
  end

  def edit
  end

  def update
    if current_user.update_attributes(params[:user])
      current_user.register!
      redirect_to public_user_path(current_user)
    else
      render :edit
    end
  end

  def get_user
    begin
      @user = User.find(params[:id])
    rescue
      redirect_to root_path, alert: "Sorry, can't find that user"
    end
  end

  def http_authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == "big" && password == "boss"
    end
  end
  
  def import

  end

  def generate_users

    if params[:import].present?
      file = params[:import][:file]
      data = file.read
      extension = file.content_type
    end

    unless extension == 'text/csv'
      redirect_to import_path, notice: 'You must upload a CSV file.'
    else
      status = User.parse_user_data(data)
      redirect_to import_path, notice: status
    end

  end

end
