module Api
  class RankingsController < ApplicationController
    before_action :set_ranking, only: [:update, :destroy]

    # GET /rankings
    def index
      @rankings = User.where(approved: true).order(:rating => :desc)
      render json: @rankings
    end

    # GET /rankings/1
    def show
      user = User.find_by(id: params[:id], approved: true)
      if user
        rankings = user.rankings
        render json: rankings
      else
        render json: {message: 'User not found'}, status: :not_found
      end
    end

    # POST /rankings
    def create
      @ranking = Ranking.new(ranking_params)

      if @ranking.save
        render json: @ranking, status: :created, location: api_ranking_url(@ranking)
      else
        render json: @ranking.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /rankings/1
    def update
      if @ranking.update(ranking_params)
        render json: @ranking
      else
        render json: @ranking.errors, status: :unprocessable_entity
      end
    end

    # DELETE /rankings/1
    def destroy
      @ranking.destroy
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_ranking
      @ranking = Ranking.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def ranking_params
      params.require(:ranking).permit(:rating)
    end
  end
end
