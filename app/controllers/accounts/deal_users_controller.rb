class Accounts::DealUsersController < InternalController
  before_action :set_deal_user, only: %i[destroy]
  before_action :set_deal, only: %i[new]

  def destroy
    return unless @deal_user.destroy

    respond_to do |format|
      format.html do
        redirect_to account_deal_path(current_user.account, @deal_user.deal),
                    notice: t('flash_messages.deleted', model: users.model_name.human)
      end
      format.turbo_stream
    end
  end

  def new
    @deal_user = @deal.deal_users.new
  end

  def create
    @deal_user = DealUser.new(deal_users_params)
    if @deal_user.save
      respond_to do |format|
        format.html { redirect_to account_deal_path(@deal_user.account, @deal_user.deal) }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def select_user_search
    @users = if params[:query].present?
               current_user.account.users.where(
                 'full_name ILIKE :search', search: "%#{params[:query]}%"
               ).order(updated_at: :desc).limit(5)
             else
               current_user.account.users.order(updated_at: :desc).limit(5)
             end
  end

  private

  def deal_users_params
    params.require(:deal_user).permit(:user_id, :deal_id)
  end

  def set_deal
    @deal = current_user.account.deals.find(params[:deal_id])
  end

  def set_deal_user
    @deal_user = DealUser.find(params[:id])
  end
end
