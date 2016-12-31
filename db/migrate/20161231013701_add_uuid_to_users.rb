class AddUuidToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :uuid, :uuid
  end
end
