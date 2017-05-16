class Api::V1::PinsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :validate_user_and_token
  def index
    if @valid_keys
      render json: Pin.all.order('created_at DESC')
    else
      head 401
    end
  end

  def create
    if @valid_keys
      pin = Pin.new(pin_params)
      if pin.save
        render json: pin, status: 201
      else
        render json: { errors: pin.errors }, status: 422
      end
    else
      head 401
    end
  end

  private
    def pin_params
      params.permit(:title, :image_url).merge(user_id: @user.id)
    end

    def validate_user_and_token
      #validar si el email existe
      @valid_keys = false
      if request.headers["X-User-Email"] && request.headers["X-Api-Token"]
        @user = User.find_by(email: request.headers["X-User-Email"])  
        token_is_valid?(@user) if @user
      end
      puts @valid_keys
    end

    def token_is_valid?(user)
      @valid_keys = true if request.headers["X-Api-Token"] == user.api_token
    end

end