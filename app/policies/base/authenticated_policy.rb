class Base::AuthenticatedPolicy < ApplicationPolicy
  def index?
    user.persisted?
  end

  def show?
    user.persisted?
  end

  def create?
    user.persisted?
  end

  def update?
    user.persisted?
  end

  def destroy?
    user.persisted?
  end

  class Scope < Scope
    def resolve
      user.persisted? ? scope.all : scope.none
    end
  end
end
