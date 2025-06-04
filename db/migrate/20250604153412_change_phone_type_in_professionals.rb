class ChangePhoneTypeInProfessionals < ActiveRecord::Migration[7.1]
  def up
    change_column :professionals, :phone, :string
  end

  def down
    change_column :professionals, :phone, :integer, using: 'phone::integer'
  end
end
