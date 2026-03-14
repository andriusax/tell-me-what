class User < ApplicationRecord
  has_many :chats
  has_many :messages, through: :chats
  has_many :favorites
  has_many :devices, through: :favorites
  has_many :artists, through: :devices

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable
end
