module Api
  class MatchesController < ApplicationController
    before_action :set_match, only: [:show, :update, :destroy]
    before_action :authenticate_api_user!, only: [:create, :update, :destroy]
    before_action :validate_current_user_in_match, only: [:update, :destroy, :create]

    # GET /matches
    def index
      @matches = Match.all
      render json: @matches
    end

    # GET /matches/1
    def show
      render json: @match
    end

    # POST /matches
    def create
      @match = Match.new(match_params)
      player1 = User.find_by(id: params[:player1], approved: true)
      player2 = User.find_by(id: params[:player2], approved: true)
      @match.users = [ player1, player2 ]
      winner = Winner.new
      if player1.id == params[:winner].to_i
        winner.user = player1
      else
        winner.user = player2
      end
      @match.winner = winner

      if @match.save
        update_elo
        update_rankings(player1, player2)
        render json: @match, status: :created, location: api_match_url(@match)
      else
        render json: @match.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /matches/1
    def update
      if @match.update(match_params)
        render json: @match
      else
        render json: @match.errors, status: :unprocessable_entity
      end
    end

    # DELETE /matches/1
    def destroy
      @match.destroy
    end

    private
    # Use callbacks to share common setup or constraints between actions.
    def set_match
      @match = Match.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def match_params
      params.fetch(:match, {})
    end

    def update_elo
      User.where(approved: true).each do |user|
        user.rating = 1000
        user.save!
      end

      elo_players = Hash.new
      Match.all.each do |match|
        winner = match.winner.user
        loser = match.winner.user == match.users.first ? match.users.second : match.users.first
        if elo_players[winner.id].nil?
          winner_elo_player = Elo::Player.new(rating: 1000)
          elo_players[winner.id] = winner_elo_player
        else
          winner_elo_player = elo_players[winner.id]
        end

        if elo_players[loser.id].nil?
          loser_elo_player = Elo::Player.new(rating: 1000)
          elo_players[loser.id] = loser_elo_player
        else
          loser_elo_player = elo_players[loser.id]
        end

        winner_elo_player.wins_from(loser_elo_player)
      end

      elo_players.each do |user_id, elo_player|
        user = User.find_by(id: user_id, approved: true)
        user.rating = elo_player.rating
        user.save!
      end

    end

    def update_rankings(player1, player2)
      player1.rankings << Ranking.create!(rating: player1.rating)
      player2.rankings << Ranking.create!(rating: player2.rating)
    end

    def validate_current_user_in_match
      if [params[:player1], params[:player2]].include?(current_api_user.id) || current_api_user.admin?
        #noop
      else
        render json: {message: 'Son, you got a panty on your head!'}, status: :unauthorized
      end
    end

  end
end
