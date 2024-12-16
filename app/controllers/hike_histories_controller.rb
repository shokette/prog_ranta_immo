class HikeHistoriesController < ApplicationController
    before_action :get_members

    def index
        @hike = Hike.find_by(id: params[:hike_id])
        @results = HikeHistory.where(hike_id: params[:hike_id])
                              .joins(:member)
                              .select('hike_histories.*, members.name as member_name')
                              .order(hiking_date: :desc)
    end

    def destroy
        @hike_history = HikeHistory.find(params[:id])
        @hike_history.destroy
        redirect_to hikes_path, notice: 'Historique de randonnée supprimé avec succès.'
    end

    def update
        @hike_history = HikeHistory.find(params[:id])

        if @hike_history.update(hike_history_params)
            redirect_to hikes_path, notice: 'Historique de randonnée mis à jour avec succès.'
        else
            @hikes = Hike.order(:trail_name)
            flash.now[:alert] = 'Veuillez corriger les erreurs ci-dessous.'
            render :edit, status: :unprocessable_entity
        end
    rescue ActionController::ParameterMissing
        flash.now[:alert] = 'Données de formulaire invalid es.'
    end

    def new
        @hike_history = HikeHistory.new
        @hikes = Hike.order(:trail_name)
    end

    def edit
        @hike_history = HikeHistory.find(params[:id])
        @hikes = Hike.order(:trail_name)
    end

    def create
        @hike_history = HikeHistory.new(hike_history_params)

        if @hike_history.save
            redirect_to hikes_path, notice: 'Randonnée ajoutée à l\'historique avec succès.'
        else
            @hikes = Hike.order(:trail_name)
            flash.now[:alert] = 'Veuillez corriger les erreurs ci-dessous.'
            render :new, status: :unprocessable_entity
        end
    rescue ActionController::ParameterMissing
        flash.now[:alert] = 'Données de formulaire invalides.'
        @hikes = Hike.order(:trail_name)
        @hike_history = HikeHistory.new
        render :new, status: :unprocessable_entity
    end

    private

    def get_members
        @members = Member.all.where(role_id: 1).order(:name)
    end

    def hike_history_params
        params.require(:hike_history).permit(
            :hiking_date,
            :departure_time,
            :day_type,
            :carpooling_cost,
            :hike_id,
            :openrunner_ref,
            :member_id
        )
    end
end