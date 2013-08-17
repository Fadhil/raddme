class User < ActiveRecord::Base
  extend FriendlyId
  friendly_id :url, :use => :slugged
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable #,trackable
  has_one :friendship, :dependent => :destroy

  # Setup accessible (or protected) attributes for your model
  #attr_accessible :email, :password, :password_confirmation, :remember_me, :fullname, :invite_token
  validates_presence_of :fullname, :url, if: :registered?

  before_validation :downcase_email
  after_create { |user| user.create_friendship }
  scope :unregistered, where("invite_token IS NOT NULL")
  scope :registered, where(invite_token: nil)
  scope :todays_imports, lambda{ where('unique_friend_token IS NOT NULL AND created_at >= ?', Date.today)}

  def friends
    User.where(id: friend_ids)
  end

  def friend_ids
    friendship.nil? ? [] : friendship.friend_ids
  end

  def self.dummy_create(new_email)
    new_password = SecureRandom::hex(4)
    new_invite_token = ActiveSupport::Base64::urlsafe_encode64(new_email+SecureRandom::hex(4))
    User.create!(email: new_email, password: new_password, password_confirmation: new_password, invite_token: new_invite_token)
  end

  def registered?
    self.invite_token.nil?
  end

  def register!
    self.update_attribute(:invite_token, nil)
    self.friends.each do |friend|
      UserMailer.exchanged(self, friend).deliver
    end
  end

  def add_friend(friend)
    transaction do
      self.friendship.append(friend)
      friend.friendship.append(self)
    end
  end

  def notify_friend(friend)
    if friend.registered?
      UserMailer.exchanged(self, friend).deliver
      UserMailer.exchanged(friend, self).deliver
      notice = "You've successfully exchanged contact"
    else
      UserMailer.exchanged_unregistered(self, friend).deliver
      notice = "You've shared contact with #{friend.email}. As soon as they login, you will receive their card"
    end
  end

  def shorter_notify_friend(friend)
    Rails.logger.info "Sending short friend notification\n"
    UserMailer.ex_short(self, friend).deliver
    UserMailer.ex_short(friend, self).deliver
  end

  def update_with_password(params={})
    params.delete(:current_password)
    self.update_without_password(params)
  end

  def gravatar_url
    "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(self.email.downcase.strip)}.png?r=pg&d=#{self.is_company? ? '404' : 'mm'}"
  end

  def vcard
    vcf = Vpim::Vcard::Maker.make2 do |maker|
      maker.add_name do |name|
        name.fullname = self.fullname if self.fullname
        name.given = self.is_company? ? '' : self.fullname.split.first if self.fullname
      end

      maker.add_email(self.email) do |mail|
        mail.location = 'work'
        mail.preferred = 'yes'
      end

      begin
        maker.add_photo do |photo|
          photo.image = open(gravatar_url).read
          photo.type = 'png'
        end
      rescue
      end

      maker.title = self.title if self.title
      maker.org = self.organization if self.organization

      maker.add_addr do |addr|
        addr.preferred = true
        addr.location = 'work'
        addr.street = self.street if self.street
        addr.locality = self.locality if self.locality
        addr.postalcode = self.postalcode if self.postalcode
        addr.country = self.country if self.country
      end if [self.street, self.locality, self.postalcode, self.country].any?

      maker.add_tel(self.phone_mobile) do |t|
        t.location = 'CELL'
      end unless self.phone_mobile.blank?

      maker.add_tel(self.phone_work) do |t|
        t.location = 'WORK'
        t.capability = 'VOICE'
      end unless self.phone_work.blank?

      maker.add_tel(self.phone_fax) do |t|
        t.location = 'WORK'
        t.capability = 'FAX'
      end unless self.phone_fax.blank?
    end

    vcf << Vpim::DirectoryInfo::Field.create( 'X-ABShowAs', 'COMPANY') if is_company?
    vcf
  end

  def self.parse_user_data(data)
    @parsed_file=CSV.parse(data)
    user_success_count = 0
    user_fail_count = 0
    @parsed_file.each  do |row|
      unless row[0] == 'Email' || row[0].blank?
        password = SecureRandom.hex(4)
        user = create_imported_user(row,password)
        if user.save
          user_success_count += 1
          UserMailer.welcome_new_user(user, password).deliver
        else
          user_fail_count += 1
        end
      end
    end

    "Successfully imported #{user_success_count} users. #{user_fail_count} users failed to be imported"
  end

  def self.find_by_email(mail)
    super(mail.downcase)
  end

  protected
  def downcase_email
    self.email.downcase! if self.email
  end

  def self.create_imported_user(row,password)
    
    user = find_or_create_by_email(email: row[0], 
                                    fullname: row[1], 
                                    title: row[2], 
                                    organization: row[3], 
                                    phone_mobile: row[4], 
                                    phone_work: row[5],
                                    phone_fax: row[6],
                                    url: row[1].downcase.gsub(/\W/,'_'),
                                    password: password,
                                    password_confirmation: password,
                                    unique_friend_token: generate_unique_friend_token)
    
    user
  end

  def self.generate_unique_friend_token
    random_number = (0..4).map{ rand(10)}.join.to_s

    while find_by_unique_friend_token(random_number) != nil
      random_number = (0..4).map{ rand(10)}.join.to_s
      Rails.logger.info "generating token\n"
    end
    random_number
  end

end
