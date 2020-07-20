# frozen_string_literal: true

# Define the permissions for users
class Ability
  include CanCan::Ability

  def initialize(user)
    if user.admin?
      can :manage, :all
    elsif user.user?
      can %i[index show], :all
      can :manage, DownloadUrl

      can :manage, ExportJob
      # Users can only download export jobs they own
      cannot :download, ExportJob
      can :download, ExportJob, cas_user_id: user.id

      can :manage, [Vocabulary, Individual, Type, Datatype] if user.in_group? :VocabularyEditors
    end
  end
end
