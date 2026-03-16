class Device < ApplicationRecord
  belongs_to :artist
  has_many :favorites, dependent: :destroy
end
