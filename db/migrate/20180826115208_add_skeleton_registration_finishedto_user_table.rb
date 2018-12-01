class AddSkeletonRegistrationFinishedtoUserTable < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :skeleton_user_registration_finished,:bool
  end
end
