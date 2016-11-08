class CreateChats < ActiveRecord::Migration
  def change
    create_table :chats do |t|
      t.string :comment

      t.timestamps null: false
    end
  end
end
