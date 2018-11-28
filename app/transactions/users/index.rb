module Users
  class Index < ApplicationTransaction
    try :users, catch: ActiveRecord::ActiveRecordError
    try :filter, catch: ActiveRecord::ActiveRecordError
    try :sort, catch: ActiveRecord::ActiveRecordError
    map :paginate

    private

    def users(*_args)
      ::User.all
    end

    def filter(users)
      users.filter_users(current_params[:filter_param])
    end

    def sort(users)
      users.sort_users(current_params[:sorted_by])
    end

    def paginate(users)
      users.paginate(page: current_params[:page], per_page: current_params[:number])
    end
  end
end
