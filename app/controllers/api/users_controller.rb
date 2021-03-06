module Api
  class UsersController < ApplicationController
    before_action :set_user, only: [:show, :update, :destroy]
    before_action :authenticate_api_user!, except: :approve

    # GET /users
    def index
      if params[:approved] == 'false'
        @users = User.where(approved: false)
      else
        @users = User.all
      end
      render json: @users
    end

    # GET /users/1
    def show
      render json: @user
    end

    # PATCH/PUT /users/1
    def update
      if @user == current_api_user
        if @user.update(user_params)
          render json: @user
        else
          render json: @user.errors, status: :unprocessable_entity
        end
      else
        render json: {message: 'You can only update yourself!'}, status: :forbidden
      end
    end

    def approve
      @user = User.find_by_uuid(params[:uuid])
      if @user
        @user.approved = true
        @user.save!
        render json: @user
      else
        render json: {message: 'We ain\'t got that user'}, status: :not_found
      end
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:name, :email, :nickname, :password)
    end
  end
end
