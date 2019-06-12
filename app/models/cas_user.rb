# A user of the application
class CasUser < ActiveRecord::Base
  validates :cas_directory_id, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true

  def self.find_or_create_from_auth_hash(auth)
		where(cas_directory_id: auth[:uid]).first
  end
  
  def admin?
    admin
  end
end
