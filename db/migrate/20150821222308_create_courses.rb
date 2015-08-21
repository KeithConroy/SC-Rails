class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :title
      t.references :organization, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
