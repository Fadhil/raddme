class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  has_one :friendship, :dependent => :destroy

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :fullname, :family, :given, :prefix
  validates_presence_of :fullname
  
  def friends
    User.where(:id => friend_ids)
  end

  def friend_ids
    friendship.nil? ? [] : friendship.friend_ids
  end
end
