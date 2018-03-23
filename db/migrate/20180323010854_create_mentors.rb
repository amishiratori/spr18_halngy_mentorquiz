class CreateMentors < ActiveRecord::Migration[5.1]
  def change
    create_table :mentors do |t|
      t.string :picture
      t.string :choice1
      t.string :choice2
      t.string :choice3
      t.integer :answer
    end
  end
end
