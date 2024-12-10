class RemoveUserAndProfessionalFromReviews < ActiveRecord::Migration[7.1]
  def change
    remove_reference :reviews, :user, null: false, foreign_key: true
    remove_reference :reviews, :professional, null: false, foreign_key: true
  end
end
