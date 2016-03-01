class Mixpanel::ImportUsers < Mixpanel::ImportBase
  attr_reader :users

  def do
    users.map { |u| import_user u.mkey, Mixpanel::Data::User.new(user: u).data }
  end

  private

  def set_additional_params(params)
    @users = Array params[:users]
  end
end
