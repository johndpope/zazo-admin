module User::UserScopeMethods
  def search(query)
    query_param = "%#{query}%"
    where 'first_name LIKE ? OR last_name LIKE ? OR mobile_number LIKE ?', query_param, query_param, query_param
  end
end
