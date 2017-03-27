# A user of the application
class CasUser < ActiveRecord::Base
  validates :cas_directory_id, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true

  def admin?
    admin
  end
end
