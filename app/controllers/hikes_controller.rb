class HikesController < ApplicationController

    def index
        @results = fetch_hikes
        @results = @results.sort_by { |hike| hike.last_hiking_date || Date.new(1, 1, 1) }.reverse
    end

    def refresh_from_openrunner
        @hike = Hike.find(params[:id])
        @hike.update(updating: true)
        UpdateHikeFromOpenrunnerJob.perform_later(@hike)

        # Redirection avec les paramètres de recherche
        redirect_back_options = { notice: "Mise à jour des données depuis OpenRunner en cours..." }

        # Si on a un paramètre de recherche, on le conserve
        redirect_back_options = {
            notice: "La randonnée \"#{@hike.trail_name}\" est en cours de mise à jour depuis OpenRunner..."
        }

        # Gestion des paramètres de redirection
        if params[:search].present?
            redirect_back_options[:search] = params[:search]
        elsif params[:redirect_path].present?
            redirect_back_options[:redirect_path] = params[:redirect_path]
        else
            redirect_back_options[:search] = nil
        end

        # Redirection avec les options
        redirect_back(fallback_location: hikes_path, **redirect_back_options)
    end

    def new
        @hike = Hike.new
        @hike_path = HikePath.new
    end

    def edit
        @hike = Hike.find(params[:id])
        @hike_path = @hike.hike_path
    end

    def update
        @hike = Hike.find(params[:id])
        @hike_path = @hike.hike_path || HikePath.new(hike_id: @hike.id)
        params[:hike][:coordinates] = "" if params[:hike][:coordinates] == "[]"
        if @hike.update(hike_params) and @hike_path&.update(coordinates: params[:hike][:coordinates])
            redirect_to hikes_path, notice: 'Parcours mis à jour avec succès.'
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def create
        @hike = Hike.new(hike_params)
        @hike_path = HikePath.new(coordinates: params[:hike][:coordinates])
        if @hike.save
            @hike_path.hike_id = @hike.id
            @hike_path.save
            redirect_to hikes_path, notice: 'Parcours ajouté avec succès.'
        else
            render :new, status: :unprocessable_entity, params: { hike: @hike, coordinates: params[:coordinates] }
        end
    end

    def fetch_openrunner_details
        details = OpenrunnerFetchService.fetch_details(params[:openrunner_ref])

        if details[:error]
            render json: { error: details[:error] }, status: :unprocessable_entity
        else
            render json: details
        end
    end

    def destroy
        @hike = Hike.find_by(id: params[:id])
        @hike.destroy
        redirect_to hikes_path, notice: 'Parcours supprimé avec succès.'
    end

    private

    def hike_params
        params_with_converted_distance = params.require(:hike).permit(
            :number,
            :difficulty,
            :starting_point,
            :trail_name,
            :carpooling_cost,
            :distance_km,
            :elevation_gain,
            :elevation_loss,
            :altitude_min,
            :altitude_max,
            :openrunner_ref,
        )

        if params_with_converted_distance[:distance_km].present?
            params_with_converted_distance[:distance_km].gsub!(',', '.')
        end

        params_with_converted_distance
    end

    def fetch_hikes
        Hike.with_latest_history
            .then { |scope| apply_search(scope) }
            .order_by_latest_date
            .distinct
            .includes(:hike_histories, :hike_path, latest_history: :member)
    end

    def apply_search(scope)
        params[:search].present? ? scope.search_by_term(params[:search]) : scope
    end
end