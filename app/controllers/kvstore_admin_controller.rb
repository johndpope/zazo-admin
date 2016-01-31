class KvstoreAdminController < ApplicationController
  def index
    @kvstores = Kvstore.all.page params[:page]
  end
end
