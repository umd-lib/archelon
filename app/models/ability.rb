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
      can :manage, [Vocabulary, Individual, Type] if user.in_group? :VocabularyEditors
    end
  end
end
