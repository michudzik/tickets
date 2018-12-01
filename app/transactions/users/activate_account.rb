module Users
  class ActivateAccount < ApplicationTransaction
    try :assign_object, catch: ActiveRecord::RecordNotFound
    check :same_user
    try :activate, catch: ActiveRecord::ActiveRecordError

    private

    def assign_object(id)
      ::User.find(id)
    end

    def same_user(user)
      !user.same_user?(current_user.id)
    end

    def activate(user)
      user.unlock_access!
      user
    end
  end
end
