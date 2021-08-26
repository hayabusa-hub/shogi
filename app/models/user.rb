class User < ApplicationRecord
  
  # relationship
  has_one :match, dependent: :destroy
  
  # validation
  validates :name,     presence: true,
                       length: {maximum: 30}
  validates :email,    presence: true,
                       length: {maximum: 255},
                       uniqueness: true
  validates :password, presence: true,
                       length: {minimum: 6}
                       
  # 保存直前のアクションを設定
  before_save {self.email.downcase!}
    
  # セキュアなパスワードを使用する
  has_secure_password
    
  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
end
