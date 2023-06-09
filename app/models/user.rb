class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :colletion_items, dependent: :destroy
  has_many :products, through: :colletion_items

  ROLES = {
    admin: 'admin',
    user: 'user',
    stylist: 'stylist'
  }

  def admin?
    role == ROLES[:admin]
  end

  def stylist?
    role == ROLES[:stylist]
  end
end
