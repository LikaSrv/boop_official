class Post < ApplicationRecord
  has_many :content_blocks, -> { order(:position) }, dependent: :destroy
  accepts_nested_attributes_for :content_blocks, allow_destroy: true, reject_if: :all_blank

  validates :title, :slug, :meta_title, :meta_description, :intro, :conclusion, presence: true
  validates :slug, uniqueness: true

  def to_param
    slug
  end
end
