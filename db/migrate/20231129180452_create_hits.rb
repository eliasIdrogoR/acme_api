class CreateHits < ActiveRecord::Migration[7.0]
  def change
    create_table :hits do |t|
      t.references :user, null: false, foreign_key: true
      t.string :endpoint

      t.timestamps
    end
  end
end
