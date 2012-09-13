class AddLastLoginIp < ActiveRecord::Migration
	def change
		add_column :users, :last_login_ip, :string
	end
end

