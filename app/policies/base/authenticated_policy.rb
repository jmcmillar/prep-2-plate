class Base::AuthenticatedPolicy < ApplicationPolicy
  def index?
    user.active_for_authentication?
  end

  def show?
    user.active_for_authentication?
  end

  def create?
    user.active_for_authentication?
  end

  def update?
    user.active_for_authentication?
  end

  def destroy?
    user.active_for_authentication?
  end

  class Scope < Scope
    def resolve
      user.active_for_authentication? ? scope.all : scope.none
    end
  end
end
