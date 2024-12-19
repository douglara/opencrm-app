class DealBuilder
  def initialize(user, params, contact_search_if_exists = false)
    @params = params
    @user = user
    @contact_search_if_exists = contact_search_if_exists
  end

  def build
    @deal = Deal.new(deal_params(@params).merge(created_by_id: @user.id))
    build_contact if @deal.contact.blank?
    @deal
  end

  def perform
    build
    @deal
  end

  private

  def build_contact
    @contact = ContactBuilder.new(@user, @params[:contact_attributes], @contact_search_if_exists).perform
    @deal.contact = @contact
  end

  def deal_params(params)
    params.permit(
      :name, :status, :stage_id, :contact_id,
      contact_attributes: %i[id full_name phone email],
      custom_attributes: {}
    )
  end
end
