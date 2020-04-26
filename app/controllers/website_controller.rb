class WebsiteController < ApplicationController
  def index
    @token = nil
  end

  def donate
    charity_service = CharityService.new(params)
    charity_service.process

    if charity_service.charge&.paid
      flash.notice = t(".success", amount: charity_service.formatted_amount)
      redirect_to root_path
    else
      @token = charity_service.token
      flash.now.alert = charity_service.errors.to_sentence
      render :index
    end
  end
end
