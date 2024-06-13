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
                       length: {minimum: 6},
                       allow_nil: true
                       
  # 保存直前のアクションを設定
  before_save {self.email.downcase!}
    
  # セキュアなパスワードを使用する
  has_secure_password
  
  # トークンの生成
  attr_accessor :remember_token
    
  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
  
  # ランダムなトークンを生成する
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(self.remember_token))
  end
  
  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(remember_token)
    if remember_digest.nil?
      return false
    end
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
  
  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end
end
