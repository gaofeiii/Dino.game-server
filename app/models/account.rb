class Account < ActiveRecord::Base
	has_secure_password

	validates :username,  :presence => true,
                        :uniqueness => { :case_sensitive => false }
end