class WebsiteController < ApplicationController
  def index
    @token = nil
  end

  def donate
    donate_service = DonationService.new(params)
    donate_service.process

    if donate_service.charge&.paid
      flash.notice = t(".success", amount: donate_service.formatted_amount)
      redirect_to root_path
    else
      @token = donate_service.token
      flash.now.alert = donate_service.errors.to_sentence
      render :index
    end
  end
end
